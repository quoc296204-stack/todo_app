from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# 1. Định nghĩa chuỗi kết nối (CỰC KỲ QUAN TRỌNG)
# Cú pháp: mysql+pymysql://<user>:<password>@<host>:<port>/<database_name>
SQLALCHEMY_DATABASE_URL = "mysql+pymysql://root:123456@localhost:3306/todoapp"

# 2. Tạo Engine để kết nối thực tế xuống MySQL
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    # Cấu hình pool_pre_ping giúp tự động kết nối lại nếu DB bị ngắt giữa chừng
    pool_pre_ping=True 
)

# 3. Tạo SessionLocal - nơi sản sinh ra các phiên làm việc với DB
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 4. Định nghĩa Base class để các Models (Habit, Task, User) kế thừa
Base = declarative_base()

# 5. Dependency để FastAPI lấy DB Session cho mỗi Request
def get_db_connection():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()