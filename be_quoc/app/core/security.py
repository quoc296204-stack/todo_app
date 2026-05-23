from passlib.context import CryptContext
from fastapi import HTTPException, status
from fastapi.security import HTTPBearer

# 1. Khởi tạo CryptContext cho việc băm mật khẩu
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# 2. Các hàm hỗ trợ băm và kiểm tra mật khẩu
def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password):
    return pwd_context.hash(password)

# 3. Cấu hình bảo mật cơ bản (HTTPBearer)
# Bạn vẫn có thể giữ cái này nếu sau này muốn dùng JWT để xác thực
security = HTTPBearer()