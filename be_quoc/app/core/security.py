
import bcrypt

def get_password_hash(password: str) -> str:
    """Mã hóa mật khẩu mới trước khi lưu vào DB"""
    # Ép chuỗi về dạng bytes và cắt tối đa 72 bytes để tránh lỗi bcrypt
    pwd_bytes = password[:72].encode('utf-8')
    # Băm mật khẩu (sinh ra muối ngẫu nhiên tự động)
    salt = bcrypt.gensalt()
    hashed_pwd = bcrypt.hashpw(pwd_bytes, salt)
    
    # Trả về dạng chuỗi văn bản (String) để lưu vào MySQL
    return hashed_pwd.decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Kiểm tra mật khẩu người dùng nhập có khớp với Hash trong DB không"""
    try:
        # Xử lý mật khẩu gửi lên: cắt 72 bytes và ép kiểu
        plain_bytes = plain_password[:72].encode('utf-8')
        
        # Mật khẩu trong DB đang là chuỗi, cần ép về bytes
        hashed_bytes = hashed_password.encode('utf-8')
        
        # Kiểm tra khớp
        return bcrypt.checkpw(plain_bytes, hashed_bytes)
    except Exception as e:
        print(f"Lỗi xác thực mật khẩu: {str(e)}")
        return False