from unittest.mock import Base

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.models import user_models, habit_models, task_models 
from app.api.routes import auth_routes, habits_routes, tasks_routes
from app.db.database import engine, Base
import uvicorn

myapp = FastAPI(title="Digital Curator API")

# Lệnh này sẽ quét các model đã import ở trên và tạo bảng nếu chưa có
Base.metadata.create_all(bind=engine)

# Cho phép Flutter kết nối (CORS)
myapp.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Kết nối router auth
myapp.include_router(auth_routes.router)

# 2. KẾT NỐI ROUTER TASKS TẠI ĐÂY
myapp.include_router(tasks_routes.router)

# QUAN TRỌNG: Bạn phải thêm dòng này để Backend nhận diện được Habit
myapp.include_router(habits_routes.router)

@myapp.get("/")
def root():
    return {"message": "API đang chạy mượt mà!"}

# Chạy server
if __name__ == "__main__":
    # "main:myapp" nghĩa là: file tên main.py, biến tên myapp
    # host="0.0.0.0" giúp server lắng nghe tất cả các card mạng (Wi-Fi, LAN,...)
    uvicorn.run("main:myapp", host="0.0.0.0", port=8000, reload=True)