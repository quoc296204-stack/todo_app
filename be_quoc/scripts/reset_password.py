#!/usr/bin/env python3
"""
Script reset mật khẩu cho user trong database
"""
from passlib.context import CryptContext
import pymysql
import sys

# Config
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# Mật khẩu mới bạn muốn đặt
NEW_PASSWORD = "123456"  # Đổi thành mật khẩu muốn đặt

# Mã hóa mật khẩu
hashed_password = pwd_context.hash(NEW_PASSWORD)
print(f"Mật khẩu mới được mã hóa: {hashed_password}")
print()

# Kết nối database
try:
    db = pymysql.connect(
        host="localhost",
        user="root",
        password="",  # Thay bằng password của bạn nếu có
        database="todo_app",
        charset="utf8mb4"
    )
    
    with db.cursor(pymysql.cursors.DictCursor) as cursor:
        # Update mật khẩu cho user id = 1
        sql = "UPDATE users SET password = %s WHERE id = %s"
        cursor.execute(sql, (hashed_password, 1))
        db.commit()
        
        print(f"✅ Cập nhật mật khẩu thành công!")
        print(f"👤 User id: 1")
        print(f"🔐 Mật khẩu mới: {NEW_PASSWORD}")
        print()
        print(f"Bây giờ bạn có thể đăng nhập lại rồi đổi mật khẩu bình thường")
    
    db.close()
    
except Exception as e:
    print(f"❌ Lỗi: {e}")
    sys.exit(1)
