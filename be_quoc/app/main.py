<<<<<<< HEAD
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
# from app.models import user_models, habit_models, task_models 
from app.api.routes import auth_routes, habits_routes, tasks_routes, ai_routes
from app.db.database import engine, Base
=======
from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
import uvicorn
import firebase_admin
from firebase_admin import credentials, auth

<<<<<<< HEAD
# 🔴 ĐÃ XÓA dòng import lỗi 'from be_quoc import app' ở đây để hết lỗi ModuleNotFoundError

myapp = FastAPI(title="Digital Curator API")

# Quét các model đã import ở trên và tạo bảng nếu chưa có
=======
# Import từ project của bạn
from app.models import user_models, habit_models, task_models 
from app.api.routes import auth_routes, habits_routes, tasks_routes, ai_routes
from app.db.database import engine, Base

# 1. Khởi tạo FastAPI
myapp = FastAPI(title="Digital Curator API")

# 2. Khởi tạo Firebase Admin
# Khối try-except giúp tránh lỗi "ValueError: The default Firebase app already exists" khi reload server
try:
    cred = credentials.Certificate("firebase-adminsdk.json")
    firebase_admin.initialize_app(cred)
    print("Đã khởi tạo Firebase Admin thành công!")
except ValueError:
    pass # Bỏ qua nếu app đã được khởi tạo

# 3. Tạo bảng database (SQLAlchemy)
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
Base.metadata.create_all(bind=engine)

# 4. Cấu hình CORS
myapp.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

<<<<<<< HEAD
# Kết nối router auth, tasks, habits theo cấu trúc chuẩn của bạn
=======
# 5. Cấu hình Firebase Security (Bảo mật cho các API cần đăng nhập)
security = HTTPBearer()

def verify_firebase_token(creds: HTTPAuthorizationCredentials = Depends(security)):
    token = creds.credentials
    try:
        # Gửi token lên Firebase để xác minh
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token không hợp lệ hoặc đã hết hạn",
            headers={"WWW-Authenticate": "Bearer"},
        )

# 6. Gắn các Router
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
myapp.include_router(auth_routes.router)
myapp.include_router(tasks_routes.router)
myapp.include_router(habits_routes.router)
myapp.include_router(ai_routes.router, prefix="/api", tags=["Internal AI Engine"])

<<<<<<< HEAD
myapp.include_router(ai_routes.router, prefix="/api", tags=["Internal AI Engine"])

=======
# 7. Các Endpoint kiểm tra hệ thống
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
@myapp.get("/")
def root():
    return {"message": "API đang chạy mượt mà!"}

<<<<<<< HEAD
# Ép FastAPI in ra toàn bộ URL hợp lệ khi khởi động để bạn kiểm soát
# @myapp.on_event("startup")
# def print_all_routes():
#     print("\n=== SƠ ĐỒ ĐƯỜNG DẪN API HIỆN CÓ CỦA HỆ THỐNG ===")
#     for route in myapp.routes:
#         print(f"Phương thức: {route.methods} --> Đường dẫn: {route.path}")
#     print("================================================\n")
=======
# API test bảo mật Firebase: Cần có token mới vào được
@myapp.get("/api/test-firebase-auth")
def test_secure_data(user: dict = Depends(verify_firebase_token)):
    return {
        "message": "Firebase Token chuẩn!",
        "uid": user.get("uid"),
        "email": user.get("email")
    }

# 8. Ép FastAPI in ra toàn bộ URL hợp lệ khi khởi động
@myapp.on_event("startup")
def print_all_routes():
    print("\n=== SƠ ĐỒ ĐƯỜNG DẪN API HIỆN CÓ CỦA HỆ THỐNG ===")
    for route in myapp.routes:
        print(f"Phương thức: {route.methods} --> Đường dẫn: {route.path}")
    print("================================================\n")
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a

# Chạy server
if __name__ == "__main__":
    uvicorn.run("main:myapp", host="0.0.0.0", port=8000, reload=True)