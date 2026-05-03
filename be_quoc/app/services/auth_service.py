from app.db.database import get_db_connection
from app.core.security import get_password_hash, verify_password
from fastapi import HTTPException

def register_user_logic(user_data):
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            # 1. Kiểm tra email đã tồn tại chưa
            cursor.execute("SELECT id FROM users WHERE email = %s", (user_data.email,))
            if cursor.fetchone():
                raise HTTPException(status_code=400, detail="Email này đã được sử dụng")

            # 2. Mã hóa mật khẩu từ passwordController[cite: 1]
            hashed_password = get_password_hash(user_data.password)

            # 3. Lưu vào bảng users (role_id mặc định là 2 cho USER)
            sql = """
                INSERT INTO users (full_name, email, password, role_id) 
                VALUES (%s, %s, %s, %s)
            """
            cursor.execute(sql, (user_data.full_name, user_data.email, hashed_password, 2))
            
            conn.commit()
            return {"status": "success", "message": f"Đã tạo tài khoản cho {user_data.full_name}"}
    finally:
        conn.close()

#  hàm xử lý login 
def login_user_logic(login_data):
    # login_data chứa email và password gửi từ Flutter
    conn = get_db_connection()
    try:
        with conn.cursor() as cursor:
            # Tìm user trong DB
            sql = "SELECT id, email, password, full_name FROM users WHERE email = %s"
            cursor.execute(sql, (login_data.email,))
            user = cursor.fetchone()

            # Nếu không tìm thấy hoặc mật khẩu sai
            if not user or not verify_password(login_data.password, user['password']):
                raise HTTPException(status_code=401, detail="Email hoặc mật khẩu không chính xác")

            return {
                "success": True,
                "message": "Đăng nhập thành công",
                "user": {
                    "id": user['id'],
                    "email": user['email'],
                    "full_name": user['full_name']
                }
            }
    finally:
        conn.close()