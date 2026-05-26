from sqlalchemy.orm import Session
from sqlalchemy import cast, Date
from app.models.habit_models import Habit, HabitLog
from datetime import date, timedelta
from app.schemas.habit_schema import HabitCreate, HabitUpdate

# 1. XEM DANH SÁCH
def get_user_habits(db: Session, user_id: int, target_date: date):
    habits = db.query(Habit).filter(Habit.user_id == user_id).all()
    
    logs = db.query(HabitLog).filter(
        HabitLog.user_id == user_id, 
        cast(HabitLog.completed_at, Date) == target_date
    ).all()
    completed_ids = {log.habit_id for log in logs}
    
    result = []
    for h in habits:
        result.append({
            "id": h.id,
            "title": h.title,
            "description": h.description,
            "is_completed": h.id in completed_ids
        })
    return result

# 2. TOGGLE CHECK-IN
def toggle_habit_status(db: Session, habit_id: int, target_date: date):
    habit = db.query(Habit).filter(Habit.id == habit_id).first()
    if not habit:
        return None
    log = db.query(HabitLog).filter(
        HabitLog.habit_id == habit_id, 
        cast(HabitLog.completed_at, Date) == target_date
    ).first()
    is_done = False
    if log:
        db.delete(log)
    else:
        db.add(HabitLog(habit_id=habit_id, user_id=habit.user_id, completed_at=target_date))
        is_done = True
    db.commit()
    
    # Tính lại phần trăm
    total = db.query(Habit).filter(Habit.user_id == habit.user_id).count()
    done = db.query(HabitLog).filter(
        HabitLog.user_id == habit.user_id, 
        cast(HabitLog.completed_at, Date) == target_date
    ).count()
    percent = int((done / total) * 100) if total > 0 else 0
    return {"is_completed": is_done, "new_progress": percent}

# 3. TẠO MỚI
def create_new_habit(db: Session, habit_data: HabitCreate):
    new_habit = Habit(
        user_id=habit_data.user_id, 
        title=habit_data.title, 
        description=habit_data.description 
    )
    db.add(new_habit)
    db.commit()
    db.refresh(new_habit) # Nạp lại dữ liệu để lấy ID vừa tạo
    return new_habit

# 4. CẬP NHẬT
def update_habit(db: Session, habit_id: int, habit_data: HabitUpdate):
    habit = db.query(Habit).filter(Habit.id == habit_id).first()
    if habit:
        habit.title = habit_data.title
        habit.description = habit_data.description 
        db.commit()
        db.refresh(habit)
    return habit

# 5. XÓA 
def delete_habit(db: Session, habit_id: int):
    habit = db.query(Habit).filter(Habit.id == habit_id).first()
    if habit:
        # Do trong DB đã cài ON DELETE CASCADE, nên xóa Habit sẽ tự động xóa HabitLog.
        # Nhưng để an toàn tuyệt đối trên cấp độ code, ta vẫn xóa Log trước:
        db.query(HabitLog).filter(HabitLog.habit_id == habit_id).delete()
        db.delete(habit)
        db.commit()
        return True
    return False