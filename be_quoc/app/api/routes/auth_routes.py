from datetime import datetime, timedelta

from fastapi import APIRouter, HTTPException, Depends, status
from sqlalchemy import func
from sqlalchemy.orm import Session
from app.db.database import get_db_connection as get_db
from app.schemas.user_schema import UserCreate, UserLogin, PasswordChange, UserUpdate
from app.services import auth_service
from app.models.user_models import User
<<<<<<< HEAD
from app.models.task_models import Task
from app.models.habit_models import Habit, HabitLog
=======
from app.core.security import verify_firebase_token 
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a

# Thống nhất prefix để Swagger không bị lỗi nhân đôi đường dẫn
router = APIRouter(prefix="/api/auth", tags=["auth"])

@router.post("/register")
def register(user_in: UserCreate, db: Session = Depends(get_db),user_token: dict = Depends(verify_firebase_token)):
    # Luôn truyền 'db' vào service để xử lý
    return auth_service.register_user_logic(db, user_in)

@router.post("/login")
def login(user_in: UserLogin, db: Session = Depends(get_db),user_token: dict = Depends(verify_firebase_token)):
    return auth_service.login_user_logic(db, user_in)

@router.put("/change-password/{user_id}")
def change_password(user_id: int, req: PasswordChange, db: Session = Depends(get_db),user_token: dict = Depends(verify_firebase_token)):
    # Logic đổi mật khẩu giờ đã nằm gọn trong service
    return auth_service.change_password_logic(db, user_id, req)

@router.get("/profile/{user_id}")
<<<<<<< HEAD
def get_profile(user_id: int, db: Session = Depends(get_db)):
=======
def get_profile(user_id: int, db: Session = Depends(get_db),user_token: dict = Depends(verify_firebase_token)):
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Không tìm thấy người dùng")
    return {
        "full_name": user.full_name,
        "avatar_url": "https://www.w3schools.com/howto/img_avatar.png"
<<<<<<< HEAD
    }

@router.put("/update-profile/{user_id}")
def update_profile(user_id: int, user_update: UserUpdate, db: Session = Depends(get_db)):
    # Gọi sang Service để xử lý (giống hệt cách bạn làm với đổi mật khẩu)
    return auth_service.update_profile_logic(db, user_id, user_update)

@router.get("/productivity-report/{user_id}")
def get_productivity_report(user_id: int, db: Session = Depends(get_db)):
    # Các mốc thời gian để tính toán
    today = datetime.now().date()
    seven_days_ago = today - timedelta(days=7)
    fourteen_days_ago = today - timedelta(days=14)

    # =========================================================
    # 1. TỶ LỆ HOÀN THÀNH (Tính trong 7 ngày qua)
    # =========================================================
    total_tasks_7d = db.query(Task).filter(
        Task.user_id == user_id,
        func.date(Task.created_at) >= seven_days_ago,
        func.date(Task.created_at) <= today
    ).count()

    completed_tasks_7d = db.query(Task).filter(
        Task.user_id == user_id,
        Task.is_completed == True, # Tùy tên cột DB của bạn (vd: status == "done")
        func.date(Task.created_at) >= seven_days_ago,
        func.date(Task.created_at) <= today
    ).count()

    completion_rate = 0
    if total_tasks_7d > 0:
        completion_rate = int((completed_tasks_7d / total_tasks_7d) * 100)

    # =========================================================
    # 2. TĂNG TRƯỞNG (% So với 7 ngày trước đó nữa)
    # =========================================================
    completed_tasks_prev_7d = db.query(Task).filter(
        Task.user_id == user_id,
        Task.is_completed == True,
        func.date(Task.created_at) >= fourteen_days_ago,
        func.date(Task.created_at) < seven_days_ago
    ).count()

    growth_rate = 0
    if completed_tasks_prev_7d > 0:
        growth_rate = int(((completed_tasks_7d - completed_tasks_prev_7d) / completed_tasks_prev_7d) * 100)
    elif completed_tasks_7d > 0:
        growth_rate = 100 # Tuần trước lười không làm, tuần này có làm => Tăng 100%

    # Tạo nhãn động (+ hoặc -) cho Flutter hiển thị
    growth_label = f"+{growth_rate}% vs t.trước" if growth_rate >= 0 else f"{growth_rate}% vs t.trước"

    # =========================================================
   # =========================================================
    # 3. THÓI QUEN (Tỷ lệ duy trì trong 7 ngày)
    # =========================================================
    # 1. Đếm tổng số thói quen user đã tạo
    total_habits = db.query(Habit).filter(
        Habit.user_id == user_id
    ).count()

    habit_rate = 0
    if total_habits > 0:
        max_possible_logs = total_habits * 7 # Tổng số lần lý thuyết phải làm trong 7 ngày
        
        # 2. Đếm số lần thực sự đã check-in (dựa vào cột completed_at)
        actual_logs = db.query(HabitLog).filter(
            HabitLog.user_id == user_id,
            func.date(HabitLog.completed_at) >= seven_days_ago,
            func.date(HabitLog.completed_at) <= today
        ).count()
        
        # 3. Tính tỷ lệ %
        habit_rate = int((actual_logs / max_possible_logs) * 100)
        
        # Đảm bảo không vượt quá 100% (Phòng trường hợp 1 ngày user bấm check-in 2 lần cho 1 thói quen)
        if habit_rate > 100:
            habit_rate = 100
    # =========================================================
    # 4. BIỂU ĐỒ (Dữ liệu 7 ngày gần nhất, CÓ TÊN NGÀY CHUẨN)
    # =========================================================
    days_name = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]
    raw_chart = {}
    max_tasks_in_day = 0

    # Lặp ngược từ 6 ngày trước cho tới Hôm nay để lấy đúng TÊN THỨ gắn vào Biểu đồ
    for i in range(6, -1, -1):
        target_date = today - timedelta(days=i)
        weekday_str = days_name[target_date.weekday()] # Tự động dịch ra T2, T3...
        
        daily_count = db.query(Task).filter(
            Task.user_id == user_id,
            Task.is_completed == True,
            func.date(Task.created_at) == target_date # Nhóm theo từng ngày
        ).count()
        
        raw_chart[weekday_str] = daily_count
        if daily_count > max_tasks_in_day:
            max_tasks_in_day = daily_count

    # Chuẩn hóa về tỷ lệ 0.0 -> 1.0 (Bắt buộc để Flutter vẽ cột không bị tràn)
    chart_data = {}
    for day, count in raw_chart.items():
        if max_tasks_in_day == 0:
            chart_data[day] = 0.0
        else:
            chart_data[day] = round(count / max_tasks_in_day, 2)

    # =========================================================
    # 5. TRẢ VỀ JSON CHO FLUTTER
    # =========================================================
    report_data = {
        "completion_rate": completion_rate,
        "growth_rate": abs(growth_rate), # Trả về số tuyệt đối, dấu +/- đã có ở label
        "growth_label": growth_label,
        "habit_rate": habit_rate,
        "ai_suggestion_title": "Duy trì phong độ nhé!",
        "ai_suggestion_content": f"Tuần này bạn đã hoàn thành {completed_tasks_7d} công việc. Tiếp tục phát huy nhé!",
        "chart_data": chart_data # Sẽ tự động vẽ ra đúng các cột có chữ T2, T3...
    }
    
    return {"status": 200, "data": report_data}
=======
    }
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
