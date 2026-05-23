from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean, ForeignKey
from sqlalchemy.dialects.mysql import BIGINT  
from sqlalchemy.sql import func
from app.db.database import Base
from sqlalchemy.orm import relationship

class Category(Base):
    __tablename__ = "categories"
    # Bảo vệ metadata khi Uvicorn tự động hot-reload nạp lại code
    __table_args__ = {'extend_existing': True}

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(BIGINT(unsigned=True), nullable=False)  # Chuẩn cấu trúc unsigned
    name = Column(String(255), nullable=False)


class Task(Base):
    __tablename__ = "tasks"
    __table_args__ = {'extend_existing': True}

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(BIGINT(unsigned=True), nullable=False)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    category = Column(String(255), nullable=False)  
    priority = Column(String(50), nullable=False)
    
    start_time = Column(DateTime, nullable=False) 
    deadline = Column(DateTime, nullable=False)
    is_reminder = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, server_default=func.now())
    
    # Quản lý trạng thái hoàn thành công việc
    is_completed = Column(Boolean, default=False, nullable=False)
    completed_at = Column(DateTime, nullable=True) 
    subtasks = relationship("SubTask", back_populates="task", cascade="all, delete-orphan")


class SubTask(Base):
    __tablename__ = "sub_tasks"
    __table_args__ = {'extend_existing': True}

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    
    # ==========================================
    # ĐÃ SỬA: Ép kiểu BIGINT(unsigned=True) cho khớp với bảng tasks
    # ==========================================
    task_id = Column(BIGINT(unsigned=True), ForeignKey("tasks.id", ondelete="CASCADE"), nullable=False)
    
    title = Column(String(255), nullable=False)
    is_completed = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, server_default=func.now())
    
    # Liên kết ngược lại với Task
    task = relationship("Task", back_populates="subtasks")