from sqlalchemy import  Column, Integer, String, DateTime
from sqlalchemy.sql import func
from sqlalchemy.dialects.mysql import BIGINT
from app.db.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    password = Column(String)
    full_name = Column(String)
    # Các cột mới thêm:
    phone_number = Column(String, nullable=True)
    birthday = Column(String, nullable=True) # Hoặc Date tùy bạn set up
    job_title = Column(String, nullable=True)
    gender = Column(String, nullable=True)
    bio = Column(String, nullable=True)
    avatar_url = Column(String, nullable=True)