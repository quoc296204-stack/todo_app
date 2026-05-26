from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from app.models.user_models import User
from app.core.security import get_password_hash, verify_password
from app.schemas.user_schema import UserCreate, UserLogin, PasswordChange, UserUpdate

# ==========================================
# 1. LOGIC ĐĂNG KÝ
# ==========================================
def register_user_logic(db: Session, user_in: UserCreate):
    # Kiểm tra email đã có trong DB của bạn chưa
    existing_user = db.query(User).filter(User.email == user_in.email).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Email đã tồn tại trong hệ thống")
        
    # TẠO USER VỚI MẬT KHẨU ĐÃ ĐƯỢC BĂM (Đã sửa lỗi FIREBASE_AUTH)
    new_user = User(
        email=user_in.email,
        full_name=user_in.full_name,
        password=get_password_hash(user_in.password) 
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    return {"message": "Đăng ký thành công", "id": new_user.id}

# ==========================================
# 2. LOGIC ĐĂNG NHẬP
# ==========================================
def login_user_logic(db: Session, user_in: UserLogin):
    # Tìm user theo Email
    user = db.query(User).filter(User.email == user_in.email).first()
    
    # KIỂM TRA CẢ EMAIL VÀ MẬT KHẨU (Bảo mật bắt buộc khi không dùng Firebase)
    if not user or not verify_password(user_in.password, user.password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, 
            detail="Email hoặc mật khẩu không chính xác"
        )

    # Trả về thông tin cho Flutter
    return {
        "message": "Đăng nhập thành công",
        "id": user.id,
        "user": {
            "id": user.id,
            "email": user.email,
            "full_name": getattr(user, 'full_name', user.email)
        }
    }

# ==========================================
# 3. LOGIC ĐỔI MẬT KHẨU
# ==========================================
def change_password_logic(db: Session, user_id: int, data: PasswordChange):
    # Tìm user theo ID bằng ORM
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Không tìm thấy người dùng")

    # Kiểm tra mật khẩu cũ (Sử dụng Verify từ core)
    if not verify_password(data.old_password, user.password):
        raise HTTPException(status_code=400, detail="Mật khẩu cũ không chính xác")
        
    # Mã hóa và cập nhật mật khẩu mới
    user.password = get_password_hash(data.new_password)
    db.commit() # SQLAlchemy tự hiểu đây là lệnh UPDATE MySQL
    return {"status": 200, "message": "Thay đổi mật khẩu thành công"}

# ==========================================
# 4. LOGIC HỒ SƠ NGƯỜI DÙNG (PROFILE)
# ==========================================
def get_user_profile(db: Session, user_id: int):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return {"name": user.full_name, "email": user.email}

def update_profile_logic(db: Session, user_id: int, user_update: UserUpdate):
    # Tìm user trong Database
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Không tìm thấy người dùng")

    # ĐỒNG BỘ DỮ LIỆU (MAPPING)
    if user_update.name is not None:
        user.full_name = user_update.name      
    if user_update.phone is not None:
        user.phone_number = user_update.phone  
    if user_update.birthday is not None:
        user.birthday = user_update.birthday   
    if user_update.gender is not None:
        user.gender = user_update.gender      
    if user_update.job is not None:
        user.job_title = user_update.job       
    if user_update.bio is not None:
        user.bio = user_update.bio             
        
    # Lưu vào Database
    try:
        db.commit()
        db.refresh(user)
    except Exception as e:
        db.rollback()
        print(f"Lỗi DB: {e}") # In ra terminal để dễ debug nếu có lỗi
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Lỗi khi lưu vào Database")
        
    return {"message": "Cập nhật hồ sơ thành công!"}