from fastapi import APIRouter, HTTPException, Depends, status
from sqlalchemy.orm import Session
from app.db.database import get_db_connection as get_db
from app.schemas.user_schema import UserCreate, UserLogin, PasswordChange
from app.services import auth_service

# Thống nhất prefix để Swagger không bị lỗi nhân đôi đường dẫn
router = APIRouter(prefix="/api/auth", tags=["auth"])

@router.post("/register")
def register(user_in: UserCreate, db: Session = Depends(get_db)):
    # Luôn truyền 'db' vào service để xử lý
    return auth_service.register_user_logic(db, user_in)

@router.post("/login")
def login(user_in: UserLogin, db: Session = Depends(get_db)):
    return auth_service.login_user_logic(db, user_in)

@router.put("/change-password/{user_id}")
def change_password(user_id: int, req: PasswordChange, db: Session = Depends(get_db)):
    # Logic đổi mật khẩu giờ đã nằm gọn trong service
    return auth_service.change_password_logic(db, user_id, req)