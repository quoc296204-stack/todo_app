from pydantic import BaseModel
from typing import Optional
from datetime import datetime

# ĐÃ SỬA: Đổi toàn bộ `subtitle` thành `description` để khớp với DB Model

class HabitBase(BaseModel):
    user_id: int
    title: str
    description: Optional[str] = "" 


class HabitCreate(BaseModel):
    user_id: int
    title: str
    description: Optional[str] = None


class HabitUpdate(BaseModel):
    title: str
    description: Optional[str] = None


class HabitResponse(BaseModel):
    id: int
    user_id: int
    title: str
    description: Optional[str] = None
    created_at: datetime
    
    current_streak: int = 0 
    is_completed_today: bool = False

    class Config:
        from_attributes = True