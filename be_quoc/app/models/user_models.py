from sqlalchemy import  Column, Integer, String, DateTime
from sqlalchemy.sql import func
from sqlalchemy.dialects.mysql import BIGINT
from app.db.database import Base

class User(Base):
    __tablename__ = "users"

    # Khóa chính tự động tăng
    id = Column(BIGINT(unsigned=True), primary_key=True, index=True)
    
    # Thông tin cơ bản (Đã lược bỏ số điện thoại theo yêu cầu của bạn)
    full_name = Column(String(255), nullable=False)
    
    # Email dùng để đăng nhập, phải là duy nhất
    email = Column(String(255), unique=True, index=True, nullable=False)
    
    # Mật khẩu đã được mã hóa (Băm)
    password = Column(String(255), nullable=False)
    
    # Thời điểm tạo tài khoản tự động
    created_at = Column(DateTime, server_default=func.now())

    # Bạn có thể thêm các trường khác sau này như: avatar_url, bio...