from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes import auth

myapp = FastAPI(title="Digital Curator API")

# Cho phép Flutter kết nối (CORS)
myapp.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Kết nối router auth
myapp.include_router(auth.router, prefix="/api/auth", tags=["Auth"])

@myapp.get("/")
def root():
    return {"message": "API đang chạy mượt mà!"}