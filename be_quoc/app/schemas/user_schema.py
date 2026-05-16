from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import date

class UserCreate(BaseModel):
    full_name: str
    email: EmailStr
    password: str
    phone_number: Optional[str] = None

class UserLogin(BaseModel):
    # Khớp với _emailController và _passwordController của bạn
    email: EmailStr
    password: str

class UserUpdate(BaseModel):
    full_name: str
    email: EmailStr
    phone_number: Optional[str] = None
    birthday: Optional[date] = None
    job_title: Optional[str] = None
    gender: Optional[str] = None
    bio: Optional[str] = None

class PasswordChange(BaseModel):
    old_password: str
    new_password: str