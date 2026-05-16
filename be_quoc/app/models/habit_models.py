from sqlalchemy import Column, Integer, String, DateTime, Boolean, Date, ForeignKey
from sqlalchemy.dialects.mysql import BIGINT  # Dùng kiểu bigint unsigned đồng bộ hệ thống
from sqlalchemy.sql import func
from app.db.database import Base

class Habit(Base):
    __tablename__ = "habits"
    # Thêm cấu hình an toàn chống trùng lặp metadata khi Uvicorn hot-reload code
    __table_args__ = {'extend_existing': True}  

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    user_id = Column(BIGINT(unsigned=True), nullable=False)  # Đồng bộ cấu hình bigint unsigned
    title = Column(String(255), nullable=False)
    description = Column(String(255), nullable=True)
    created_at = Column(DateTime, server_default=func.now())


class HabitLog(Base):
    __tablename__ = "habit_logs"
    # Thêm cấu hình an toàn chống trùng lặp metadata khi Uvicorn hot-reload code
    __table_args__ = {'extend_existing': True}

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    habit_id = Column(Integer, ForeignKey("habits.id", ondelete="CASCADE"), nullable=False)
    user_id = Column(BIGINT(unsigned=True), nullable=False)
    completed_at = Column(DateTime, server_default=func.now(), nullable=False)