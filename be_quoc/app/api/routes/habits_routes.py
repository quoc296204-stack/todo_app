from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from datetime import date, datetime
from app.db.database import get_db_connection
from app.models.habit_models import Habit, HabitLog
from pydantic import BaseModel
from typing import Optional
# IMPORT THÊM cast và Date từ sqlalchemy
from sqlalchemy import cast, Date
from app.schemas.habit_schema import HabitUpdate , HabitCreate

router = APIRouter(prefix="/api/habits", tags=["habits"])



# 1. LẤY DANH SÁCH THÓI QUEN THEO NGÀY CHỌN
@router.get("/{user_id}")
def get_habits(user_id: int, selected_date: Optional[str] = Query(None), db: Session = Depends(get_db_connection)):
    try:
        if not selected_date or selected_date == "null":
            target_date = date.today()
        else:
            target_date = date.fromisoformat(selected_date)
        
        all_habits = db.query(Habit).filter(Habit.user_id == user_id).all()
        
        # SỬA LỖI Ở ĐÂY: Dùng cast(..., Date) để so sánh chuẩn xác với target_date
        logs = db.query(HabitLog).filter(
            HabitLog.user_id == user_id, 
            cast(HabitLog.completed_at, Date) == target_date
        ).all()
        
        completed_ids = {log.habit_id for log in logs}
        
        result = []
        for h in all_habits:
            result.append({
                "id": h.id,
                "title": h.title,
                "description": h.description,
                "is_completed": h.id in completed_ids
            })
        return {"status": 200, "data": result}
    except Exception as e:
        print(f"[LỖI GET HABITS]: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


# 2. ĐẢO TRẠNG THÁI HOÀN THÀNH THÓI QUEN (TOGGLE)
@router.post("/toggle/{habit_id}")
def toggle_habit_status(habit_id: int, selected_date: Optional[str] = Query(None), db: Session = Depends(get_db_connection)):
    try:
        if not selected_date or selected_date == "null":
            target_date = date.today()
        else:
            target_date = date.fromisoformat(selected_date)
            
        habit = db.query(Habit).filter(Habit.id == habit_id).first()
        if not habit:
            raise HTTPException(status_code=404, detail="Không tìm thấy thói quen")
            
        # SỬA LỖI Ở ĐÂY: Dùng cast(..., Date)
        log = db.query(HabitLog).filter(
            HabitLog.habit_id == habit_id, 
            cast(HabitLog.completed_at, Date) == target_date
        ).first()
        
        if log:
            db.delete(log)  # Nếu đã có thì xóa bản ghi (Hủy tích chọn)
            is_done = False
        else:
            # Nếu chưa có thì tạo mới
            # combined_dt = datetime.combine(target_date, datetime.now().time())
            new_log = HabitLog(habit_id=habit_id, user_id=habit.user_id, completed_at=target_date)
            db.add(new_log)
            is_done = True
            
        db.commit()
        
        # SỬA LỖI Ở ĐÂY: Dùng cast(..., Date)
        total = db.query(Habit).filter(Habit.user_id == habit.user_id).count()
        done = db.query(HabitLog).filter(
            HabitLog.user_id == habit.user_id, 
            cast(HabitLog.completed_at, Date) == target_date
        ).count()
        percent = int((done / total) * 100) if total > 0 else 0
        
        return {"status": 200, "is_completed": is_done, "new_progress": percent}
    except Exception as e:
        db.rollback()
        print(f"[LỖI TOGGLE HABIT]: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# ... (Phần 3 Tạo mới và Phần 4 Xóa giữ nguyên)
# 3. TẠO THÓI QUEN MỚI
@router.post("/")
def create_habit(habit_data: HabitCreate, db: Session = Depends(get_db_connection)):
    try:
        new_habit = Habit(user_id=habit_data.user_id, title=habit_data.title, subtitle=habit_data.subtitle)
        db.add(new_habit)
        db.commit()
        return {"status": 201, "message": "Thành công"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
# sửa thói quen 
@router.put("/update/{habit_id}")
def update_habit(habit_id: int, habit_data: HabitUpdate, db: Session = Depends(get_db_connection)):
    try:
        # Tìm thói quen theo ID
        habit = db.query(Habit).filter(Habit.id == habit_id).first()
        if not habit:
            raise HTTPException(status_code=404, detail="Không tìm thấy thói quen")
        
        # Cập nhật thông tin
        habit.title = habit_data.title
        habit.subtitle = habit_data.subtitle
        
        # Lưu vào database
        db.commit()
        return {"status": 200, "message": "Cập nhật thành công"}
    except Exception as e:
        db.rollback()
        print(f"[LỖI UPDATE HABIT]: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))

# 4. XÓA THÓI QUEN
@router.delete("/{habit_id}")
def delete_habit(habit_id: int, db: Session = Depends(get_db_connection)):
    try:
        habit = db.query(Habit).filter(Habit.id == habit_id).first()
        if not habit:
            raise HTTPException(status_code=404, detail="Không tìm thấy")
        db.delete(habit)
        db.commit()
        return {"status": 200, "message": "Xóa thành công"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))