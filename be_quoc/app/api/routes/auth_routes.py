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

    # 1. TỶ LỆ HOÀN THÀNH (7 ngày qua)
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

    # 2. TĂNG TRƯỞNG
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

    # 3. THÓI QUEN
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

    # 4. BIỂU ĐỒ
    days_name = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]
    chart_data = {}
    max_tasks_in_day = 0
    raw_chart = {}

    for i in range(6, -1, -1):
        target_date = today - timedelta(days=i)
        weekday_str = days_name[target_date.weekday()]
        daily_count = db.query(Task).filter(
            Task.user_id == user_id,
            Task.is_completed == True,
            func.date(Task.created_at) == target_date
        ).count()
        raw_chart[weekday_str] = daily_count
        if daily_count > max_tasks_in_day: max_tasks_in_day = daily_count

    for day, count in raw_chart.items():
        chart_data[day] = round(count / max_tasks_in_day, 2) if max_tasks_in_day > 0 else 0.0

    return {
        "status": 200, 
        "data": {
            "completion_rate": completion_rate,
            "growth_rate": abs(growth_rate),
            "growth_label": growth_label,
            "habit_rate": habit_rate,
            "chart_data": chart_data
        }
    }