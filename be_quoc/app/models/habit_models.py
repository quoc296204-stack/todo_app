from sqlalchemy import Column, String, DateTime, ForeignKey
from sqlalchemy.dialects.mysql import BIGINT  
from sqlalchemy.sql import func
from app.db.database import Base

class Habit(Base):
    __tablename__ = "habits"
    __table_args__ = {'extend_existing': True}  

    # ĐÃ SỬA: Đổi Integer thành BIGINT(unsigned=True)
    id = Column(BIGINT(unsigned=True), primary_key=True, index=True, autoincrement=True)
    
    # Nối khóa ngoại về bảng users cho chặt chẽ
    user_id = Column(BIGINT(unsigned=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)  
    title = Column(String(255), nullable=False)
    description = Column(String(255), nullable=True) # Giữ nguyên description
    created_at = Column(DateTime, server_default=func.now())


class HabitLog(Base):
    __tablename__ = "habit_logs"
    __table_args__ = {'extend_existing': True}

    # ĐÃ SỬA: Đồng bộ toàn bộ ID thành BIGINT
    id = Column(BIGINT(unsigned=True), primary_key=True, index=True, autoincrement=True)
    habit_id = Column(BIGINT(unsigned=True), ForeignKey("habits.id", ondelete="CASCADE"), nullable=False)
    user_id = Column(BIGINT(unsigned=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    completed_at = Column(DateTime, server_default=func.now(), nullable=False)