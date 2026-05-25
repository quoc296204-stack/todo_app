from sqlalchemy import Column, Integer, String, Text, DateTime, Boolean, ForeignKey
from sqlalchemy.dialects.mysql import BIGINT  
from sqlalchemy.sql import func
from app.db.database import Base
from sqlalchemy.orm import relationship

class Category(Base):
    __tablename__ = "categories"
    __table_args__ = {'extend_existing': True}

    # SỬA: Đổi Integer thành BIGINT cho khớp với Database
    id = Column(BIGINT(unsigned=True), primary_key=True, index=True, autoincrement=True)
    user_id = Column(BIGINT(unsigned=True), nullable=False)  
    name = Column(String(255), nullable=False)


class Task(Base):
    __tablename__ = "tasks"
    __table_args__ = {'extend_existing': True}

    # SỬA: Đổi Integer thành BIGINT
    id = Column(BIGINT(unsigned=True), primary_key=True, index=True, autoincrement=True)
    user_id = Column(BIGINT(unsigned=True), nullable=False)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    
    # ==========================================
    # ĐÃ SỬA: Xóa bỏ category dạng String cũ
    # THÊM MỚI: category_id trỏ khóa ngoại về bảng categories
    # ==========================================
    category_id = Column(BIGINT(unsigned=True), ForeignKey("categories.id", ondelete="SET NULL"), nullable=True)  
    
    priority = Column(String(50), nullable=False)
    
    start_time = Column(DateTime, nullable=False) 
    deadline = Column(DateTime, nullable=False)
    is_reminder = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, server_default=func.now())
    
    is_completed = Column(Boolean, default=False, nullable=False)
    completed_at = Column(DateTime, nullable=True) 
    
    # Relationships
    subtasks = relationship("SubTask", back_populates="task", cascade="all, delete-orphan")
    # Thêm relationship để dễ dàng query: task.category_info.name
    category_info = relationship("Category", backref="tasks")


class SubTask(Base):
    __tablename__ = "sub_tasks"
    __table_args__ = {'extend_existing': True}

    # SỬA: Đổi Integer thành BIGINT
    id = Column(BIGINT(unsigned=True), primary_key=True, index=True, autoincrement=True)
    
    task_id = Column(BIGINT(unsigned=True), ForeignKey("tasks.id", ondelete="CASCADE"), nullable=False)
    
    title = Column(String(255), nullable=False)
    is_completed = Column(Boolean, default=False, nullable=False)
    created_at = Column(DateTime, server_default=func.now())
    
    task = relationship("Task", back_populates="subtasks")