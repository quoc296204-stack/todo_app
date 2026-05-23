from pydantic import BaseModel
<<<<<<< HEAD
from typing import List, Optional
from datetime import datetime

# 1. Schema Đầu vào (Nhận text từ Flutter)
=======

>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
class NLPTaskRequest(BaseModel):
    text: str       # Chuỗi văn bản tự nhiên người dùng nhập
    user_id: int    # ID của người dùng để liên kết hệ thống

    class Config:
        json_schema_extra = {
            "example": {
<<<<<<< HEAD
                "text": "Mai lúc 2h chiều đi nộp đồ án tốt nghiệp gấp",
                "user_id": 1
            }
        }

# 2. Schema Định nghĩa cấu trúc Công việc con (Subtasks)
class SubtaskParsed(BaseModel):
    title: str
    is_checked: bool = False

# 3. Schema Đầu ra (Trả kết quả về cho Flutter)
class AIParsedTaskResponse(BaseModel):
    title: str
    description: str
    category: str
    priority: str
    start_time: datetime  # Pydantic sẽ tự động ép chuỗi "YYYY-MM-DD HH:MM:SS" thành datetime chuẩn
    deadline: datetime
    subtasks: List[SubtaskParsed] = [] # Hứng mảng subtasks từ file JSON
=======
                "text": "Mai lúc 8h sáng nộp đồ án tốt nghiệp gấp",
                "user_id": 1
            }
        }
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
