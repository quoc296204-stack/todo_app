from pydantic import BaseModel
from typing import Optional

class TaskResponse(BaseModel):
    title: str
    time: str
    priority: str