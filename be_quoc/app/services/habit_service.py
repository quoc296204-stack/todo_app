from sqlalchemy.orm import Session
from app.models.habit_models import Habit, HabitLog
from datetime import date, timedelta
from app.schemas.habit_schema import HabitCreate

# 1. XEM DANH SÁCH: (Giữ nguyên logic tính Streak của Hiếu)
def get_user_habits(db: Session, user_id: int):
    habits = db.query(Habit).filter(Habit.user_id == user_id).all()
    today = date.today()
    for habit in habits:
        log_today = db.query(HabitLog).filter(HabitLog.habit_id == habit.id, HabitLog.completed_at == today).first()
        habit.is_completed_today = True if log_today else False
        
        streak = 0
        check_date = today if habit.is_completed_today else today - timedelta(days=1)
        while True:
            log = db.query(HabitLog).filter(HabitLog.habit_id == habit.id, HabitLog.completed_at == check_date).first()
            if log:
                streak += 1
                check_date -= timedelta(days=1)
            else:
                break
        habit.current_streak = streak
    return habits

# 2. THÊM MỚI
def create_new_habit(db: Session, habit_data: HabitCreate):
    new_habit = Habit(user_id=habit_data.user_id, title=habit_data.title, subtitle=habit_data.subtitle)
    db.add(new_habit)
    db.commit()
    db.refresh(new_habit)
    # Gán giá trị ảo để Pydantic không báo lỗi ResponseValidationError
    new_habit.is_completed_today = False
    new_habit.current_streak = 0
    return new_habit

# 3. CHỈNH SỬA: Tìm đúng cái cũ để sửa, không tạo mới!
def update_habit(db: Session, habit_id: int, data: dict):
    habit = db.query(Habit).filter(Habit.id == habit_id).first()
    if habit:
        habit.title = data.get('title', habit.title)
        habit.subtitle = data.get('subtitle', habit.subtitle)
        db.commit()
        db.refresh(habit)
        habit.is_completed_today = False
        habit.current_streak = 0
    return habit

# 4. XÓA: (Sửa lỗi remove_habit/delete_habit)
def delete_habit(db: Session, habit_id: int):
    habit = db.query(Habit).filter(Habit.id == habit_id).first()
    if habit:
        db.query(HabitLog).filter(HabitLog.habit_id == habit_id).delete() # Xóa log trước
        db.delete(habit)
        db.commit()
        return True
    return False

# 5. ĐÁNH DẤU: (Khớp tên hàm toggle_habit_status với Route)
def toggle_habit_status(db: Session, habit_id: int):
    today = date.today()
    log = db.query(HabitLog).filter(HabitLog.habit_id == habit_id, HabitLog.completed_at == today).first()
    if log:
        db.delete(log)
    else:
        db.add(HabitLog(habit_id=habit_id, completed_at=today))
    db.commit()
    return {"status": "success"}