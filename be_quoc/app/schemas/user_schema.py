from pydantic import BaseModel, EmailStr

class UserCreate(BaseModel):
    full_name: str
    email: EmailStr
    password: str

class UserLogin(BaseModel):
    # Khớp với _emailController và _passwordController của bạn
    email: EmailStr
    password: str