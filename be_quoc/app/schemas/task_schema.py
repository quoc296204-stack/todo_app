from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class SubTaskCreate(BaseModel):
    title: str
    is_checked: bool = False

class TaskCreate(BaseModel):
    title: str
    description: Optional[str] = None
    category_id: Optional[int] = None
    category: Optional[str] = None
    priority: str
    start_time: datetime
    deadline: datetime
    is_reminder: bool = False
    
    # Khai báo subtasks ở đây, mặc định là mảng rỗng
    subtasks: List[SubTaskCreate] = []

class CategoryCreate(BaseModel):
    name: str
    user_id: int