from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.user_models import User
from app.core.security import get_password_hash, verify_password
from app.schemas.user_schema import UserCreate, UserLogin, PasswordChange

# 1. Logic Đăng ký (Bỏ số điện thoại)
def register_user_logic(db: Session, user_data: UserCreate):
    # Bước 1: Kiểm tra email tồn tại bằng SQLAlchemy ORM
    db_user = db.query(User).filter(User.email == user_data.email).first()
    if db_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail="Email này đã được đăng ký!"
        )

    # Bước 2: Kiểm tra mật khẩu khớp (Validation tầng Service)
    if user_data.password != user_data.confirm_password:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST, 
            detail="Mật khẩu xác nhận không khớp!"
        )

    # Bước 3: Mã hóa mật khẩu
    hashed_pwd = get_password_hash(user_data.password)

    # Bước 4: Tạo đối tượng User và lưu vào DB
    new_user = User(
        full_name=user_data.full_name,
        email=user_data.email,
        password=hashed_pwd
        # Đã bỏ phone_number
    )
    
    try:
        db.add(new_user)
        db.commit() # Lưu thực tế xuống MySQL
        db.refresh(new_user)
        return {"status": 201, "message": "Đăng ký thành công!", "user_id": new_user.id}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Lỗi database: {str(e)}")

# 2. Logic Đăng nhập
def login_user_logic(db: Session, login_data: UserLogin):
    # Tìm user trong DB bằng email
    user = db.query(User).filter(User.email == login_data.email).first()

    # Kiểm tra user và mật khẩu
    if not user or not verify_password(login_data.password, user.password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, 
            detail="Email hoặc mật khẩu không chính xác"
        )

    return {
        "success": True,
        "message": "Đăng nhập thành công",
        "user": {
            "id": user.id,
            "email": user.email,
            "full_name": user.full_name
        }
    }

# 3. Logic Đổi mật khẩu
# Thêm vào app/services/auth_service.py

def change_password_logic(db: Session, user_id: int, data: PasswordChange):
    # 1. Tìm user theo ID bằng ORM
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Không tìm thấy người dùng")

    # 2. Kiểm tra mật khẩu cũ (Sử dụng Verify từ core)
    if not verify_password(data.old_password, user.password):
        raise HTTPException(status_code=400, detail="Mật khẩu cũ không chính xác")

    # 3. Mã hóa và cập nhật mật khẩu mới
    user.password = get_password_hash(data.new_password)
    
    db.commit() # SQLAlchemy tự hiểu đây là lệnh UPDATE MySQL
    return {"status": 200, "message": "Thay đổi mật khẩu thành công"}