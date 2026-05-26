from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from datetime import date
from app.db.database import get_db_connection
from app.schemas.habit_schema import HabitUpdate, HabitCreate

# 👉 IMPORT CÁC HÀM TỪ SERVICE VÀO ĐÂY
from app.services import habit_service 

router = APIRouter(prefix="/api/habits", tags=["habits"])

# Hàm dùng chung để parse ngày
def get_target_date(selected_date: str = None):
    if not selected_date or selected_date == "null":
        return date.today()
    return date.fromisoformat(selected_date)

@router.get("/{user_id}")
def get_habits(user_id: int, selected_date: str = Query(None), db: Session = Depends(get_db_connection)):
    try:
        target_date = get_target_date(selected_date)
        result = habit_service.get_user_habits(db, user_id, target_date)
        return {"status": 200, "data": result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/toggle/{habit_id}")
def toggle_habit_status(habit_id: int, selected_date: str = Query(None), db: Session = Depends(get_db_connection)):
    try:
        target_date = get_target_date(selected_date)
        result = habit_service.toggle_habit_status(db, habit_id, target_date)
        if not result:
            raise HTTPException(status_code=404, detail="Không tìm thấy thói quen")
        return {"status": 200, **result}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/")
def create_habit(habit_data: HabitCreate, db: Session = Depends(get_db_connection)):
    try:
        habit_service.create_new_habit(db, habit_data)
        return {"status": 201, "message": "Thành công"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/update/{habit_id}")
def update_habit(habit_id: int, habit_data: HabitUpdate, db: Session = Depends(get_db_connection)):
    try:
        habit = habit_service.update_habit(db, habit_id, habit_data)
        if not habit:
            raise HTTPException(status_code=404, detail="Không tìm thấy thói quen")
        return {"status": 200, "message": "Cập nhật thành công"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{habit_id}")
def delete_habit(habit_id: int, db: Session = Depends(get_db_connection)):
    try:
        success = habit_service.delete_habit(db, habit_id)
        if not success:
            raise HTTPException(status_code=404, detail="Không tìm thấy")
        return {"status": 200, "message": "Xóa thành công"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))