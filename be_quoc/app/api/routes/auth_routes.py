from datetime import datetime, timedelta
from fastapi import APIRouter, HTTPException, Depends, status
from sqlalchemy import func
from sqlalchemy.orm import Session
from app.db.database import get_db_connection as get_db
from app.schemas.user_schema import UserCreate, UserLogin, PasswordChange, UserUpdate
from app.services import auth_service
from app.models.user_models import User
from app.models.task_models import Task
from app.models.habit_models import Habit, HabitLog

# Thống nhất prefix
router = APIRouter(prefix="/api/auth", tags=["auth"])

@router.post("/register")
def register(user_in: UserCreate, db: Session = Depends(get_db)):
    return auth_service.register_user_logic(db, user_in)

@router.post("/login")
def login(user_in: UserLogin, db: Session = Depends(get_db)):
    return auth_service.login_user_logic(db, user_in)

@router.put("/change-password/{user_id}")
def change_password(user_id: int, req: PasswordChange, db: Session = Depends(get_db)):
    return auth_service.change_password_logic(db, user_id, req)

@router.get("/profile/{user_id}")
def get_profile(user_id: int, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Không tìm thấy người dùng")
    return {
        "full_name": user.full_name,
        "avatar_url": "https://www.w3schools.com/howto/img_avatar.png"
    }

@router.put("/update-profile/{user_id}")
def update_profile(user_id: int, user_update: UserUpdate, db: Session = Depends(get_db)):
    return auth_service.update_profile_logic(db, user_id, user_update)

@router.get("/productivity-report/{user_id}")
def get_productivity_report(user_id: int, db: Session = Depends(get_db)):
    today = datetime.now().date()
    seven_days_ago = today - timedelta(days=7)
    fourteen_days_ago = today - timedelta(days=14)
    first_day_of_month = today.replace(day=1) # Lấy ngày mùng 1 của tháng hiện tại

    # ==========================================
    # 1. TỶ LỆ HOÀN THÀNH & TĂNG TRƯỞNG (7 ngày qua)
    # ==========================================
    total_tasks_7d = db.query(Task).filter(
        Task.user_id == user_id,
        func.date(Task.created_at) >= seven_days_ago,
        func.date(Task.created_at) <= today
    ).count()

    completed_tasks_7d = db.query(Task).filter(
        Task.user_id == user_id,
        Task.is_completed == True,
        func.date(Task.created_at) >= seven_days_ago,
        func.date(Task.created_at) <= today
    ).count()

    completion_rate = int((completed_tasks_7d / total_tasks_7d) * 100) if total_tasks_7d > 0 else 0

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
        growth_rate = 100

    growth_label = f"{growth_rate}% so với tuần trước"

    # ==========================================
    # 2. THỐNG KÊ THÓI QUEN (Tổng quan)
    # ==========================================
    total_habits = db.query(Habit).filter(Habit.user_id == user_id).count()
    habit_rate = 0
    if total_habits > 0:
        max_possible_logs = total_habits * 7
        actual_logs = db.query(HabitLog).filter(
            HabitLog.user_id == user_id,
            func.date(HabitLog.completed_at) >= seven_days_ago,
            func.date(HabitLog.completed_at) <= today
        ).count()
        habit_rate = min(int((actual_logs / max_possible_logs) * 100), 100)

    # ==========================================
    # 3. THỐNG KÊ THÁNG HIỆN TẠI (MỚI BỔ SUNG)
    # ==========================================
    monthly_total_tasks = db.query(Task).filter(
        Task.user_id == user_id,
        func.date(Task.created_at) >= first_day_of_month,
        func.date(Task.created_at) <= today
    ).count()

    monthly_task_completed = db.query(Task).filter(
        Task.user_id == user_id,
        Task.is_completed == True,
        func.date(Task.created_at) >= first_day_of_month,
        func.date(Task.created_at) <= today
    ).count()

    monthly_task_rate = int((monthly_task_completed / monthly_total_tasks) * 100) if monthly_total_tasks > 0 else 0
    current_month_str = f"tháng {today.month}"

    # ==========================================
    # 4. DỮ LIỆU BIỂU ĐỒ CỘT (7 NGÀY QUA)
    # ==========================================
    days_name = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]
    chart_data = {}
    habit_chart_data = {}

    for i in range(6, -1, -1):
        target_date = today - timedelta(days=i)
        weekday_str = days_name[target_date.weekday()]
        
        # Đếm số task hoàn thành trong ngày
        daily_task_count = db.query(Task).filter(
            Task.user_id == user_id,
            Task.is_completed == True,
            func.date(Task.created_at) == target_date
        ).count()
        chart_data[weekday_str] = daily_task_count  # Trả về số thực tế, không chia tỷ lệ nữa
        
        # Đếm số thói quen hoàn thành trong ngày
        daily_habit_count = db.query(HabitLog).filter(
            HabitLog.user_id == user_id,
            func.date(HabitLog.completed_at) == target_date
        ).count()
        habit_chart_data[weekday_str] = daily_habit_count

    return {
        "status": 200, 
        "data": {
            "completion_rate": completion_rate,
            "growth_rate": abs(growth_rate),
            "growth_label": growth_label,
            "habit_rate": habit_rate,
            "chart_data": chart_data,
            # Các key mới đẩy về cho FE
            "habit_chart_data": habit_chart_data,
            "current_month": current_month_str,
            "monthly_total_tasks": monthly_total_tasks,
            "monthly_task_completed": monthly_task_completed,
            "monthly_task_rate": monthly_task_rate
        }
    }