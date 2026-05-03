from fastapi import APIRouter, HTTPException
from app.schemas.user_schema import UserCreate, UserLogin
from app.services import auth_service


router = APIRouter()

@router.post("/register")
def register(user_in: UserCreate):
    # Nhận dữ liệu từ RegisterPage và xử lý[cite: 1]
    return auth_service.register_user_logic(user_in)

@router.post("/login")
def login(user_in: UserLogin):
    return auth_service.login_user_logic(user_in)
    # if not result:
    #     raise HTTPException(status_code=401, detail="Email hoặc mật khẩu không chính xác")
    # return result