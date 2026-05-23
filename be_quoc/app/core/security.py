from passlib.context import CryptContext

# pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# def get_password_hash(password: str):
#     return pwd_context.hash(password)

# def verify_password(plain_password, hashed_password):
#     return pwd_context.verify(plain_password, hashed_password)

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from firebase_admin import auth

# Khởi tạo trạm kiểm soát Bearer Token
security = HTTPBearer()

def verify_firebase_token(creds: HTTPAuthorizationCredentials = Depends(security)):
    token = creds.credentials
    try:
        # Giải mã token bằng Firebase Admin
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        # DÒNG MỚI: Báo động đỏ ra terminal để biết nguyên nhân thực sự!
        # DÒNG MỚI: Báo động đỏ ra terminal để biết nguyên nhân thực sự!
        print(f"\n[LỖI FIREBASE TOKEN]: {e}\n") 
        print(f"\n[LỖI FIREBASE TOKEN]: {e}\n") 
        
        
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token không hợp lệ hoặc đã hết hạn",
            headers={"WWW-Authenticate": "Bearer"},
        )
