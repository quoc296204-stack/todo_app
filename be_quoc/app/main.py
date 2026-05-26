from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes import auth_routes, habits_routes, tasks_routes, ai_routes
from app.db.database import engine, Base
import uvicorn

myapp = FastAPI(title="Digital Curator API")

# Quét các model đã import ở trên và tạo bảng nếu chưa có
Base.metadata.create_all(bind=engine)

# Cho phép Flutter kết nối (CORS)
myapp.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Kết nối router auth, tasks, habits theo cấu trúc chuẩn của bạn
myapp.include_router(auth_routes.router)
myapp.include_router(tasks_routes.router)
myapp.include_router(habits_routes.router)
myapp.include_router(ai_routes.router, prefix="/api", tags=["Internal AI Engine"])

@myapp.get("/")
def root():
    return {"message": "API đang chạy mượt mà!"}

# Ép FastAPI in ra toàn bộ URL hợp lệ khi khởi động để kiểm soát path api 
# @myapp.on_event("startup")
# def print_all_routes():
#     print("\n=== SƠ ĐỒ ĐƯỜNG DẪN API HIỆN CÓ CỦA HỆ THỐNG ===")
#     for route in myapp.routes:
#         print(f"Phương thức: {route.methods} --> Đường dẫn: {route.path}")
#     print("================================================\n")

# Chạy server
if __name__ == "__main__":
    uvicorn.run("main:myapp", host="0.0.0.0", port=8000, reload=True)