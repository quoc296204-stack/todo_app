from pydantic import BaseModel
<<<<<<< HEAD
from typing import Optional, List
from datetime import datetime

# Thêm class này để hứng dữ liệu Subtask từ Flutter gửi lên
class SubTaskCreate(BaseModel):
    title: str
    is_checked: bool = False  # Flutter đang gửi lên là is_checked, ta dùng đúng tên này để hứng

class TaskCreate(BaseModel):
    title: str
    description: Optional[str] = None
    category: str
    priority: str
    start_time: datetime
    deadline: datetime
    is_reminder: bool = False
    
    # MỞ CỬA: Thêm mảng này để hứng danh sách các việc con
    subtasks: List[SubTaskCreate] = []
=======
from typing import Optional
from datetime import datetime


class TaskCreate(BaseModel):
    title: str
    description: Optional[str] = None
    category: str
    priority: str

    start_time: datetime
    deadline: datetime

    is_reminder: bool = False
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a

class CategoryCreate(BaseModel):
    name: str
    user_id: int