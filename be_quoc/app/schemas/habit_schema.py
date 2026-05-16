from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class HabitBase(BaseModel):
    user_id: int
    title: str
    subtitle: Optional[str] = ""

class HabitCreate(HabitBase):
    user_id: int

class HabitResponse(BaseModel):
    id: int
    user_id: int
    title: str
    subtitle: Optional[str] = None
    created_at: datetime
    
    # SỬA LỖI TẠI ĐÂY: Thêm giá trị mặc định để tránh lỗi "Field required"
    current_streak: int = 0 
    is_completed_today: bool = False

    class Config:
        from_attributes = True # Cho phép Pydantic đọc dữ liệu từ SQLAlchemy model