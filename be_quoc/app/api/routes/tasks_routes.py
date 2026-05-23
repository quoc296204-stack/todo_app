import traceback
from fastapi import APIRouter, Depends, HTTPException, Query
from typing import Optional
from sqlalchemy.orm import Session
from fastapi.encoders import jsonable_encoder 

from app.db.database import get_db_connection as get_db
from app.services import task_service
from app.schemas.task_schema import TaskCreate, CategoryCreate

router = APIRouter(prefix="/api/tasks", tags=["Tasks"])

# ==================== CỤM API CHO CÔNG VIỆC (TASKS) ====================

@router.post("/create/{user_id}", status_code=200)
def create_new_task(user_id: int, task_data: TaskCreate, db: Session = Depends(get_db)):
    print("🚀 [DEBUG] Dữ liệu Frontend gửi lên:", task_data.model_dump() if hasattr(task_data, 'model_dump') else task_data.dict())
    print("🚀 [DEBUG] Số lượng Subtask nhận được:", len(task_data.subtasks))
    try:
        # Gọi hàm xử lý lưu cả Task chính lẫn SubTask
        new_task = task_service.create_task_with_subtasks(db, user_id, task_data)
        
        # Dùng jsonable_encoder bọc new_task lại để chống lỗi serialize JSON của SQLAlchemy
        return {"status": 200, "message": "Success", "data": jsonable_encoder(new_task)}
    except Exception as e:
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/all/{user_id}")
async def get_all_tasks(
    user_id: int, 
    search: Optional[str] = Query(None),
    filter_by: Optional[str] = Query("all"), 
    sort_by: Optional[str] = Query("default"),
    db: Session = Depends(get_db)
):
    try:
        tasks = task_service.get_all_tasks(db, user_id, search, filter_by, sort_by)
        # Ép kiểu toàn bộ danh sách trả về thành JSON
        return jsonable_encoder(tasks)
    except Exception as e:
        traceback.print_exc() 
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/toggle/{task_id}")
async def toggle_task_status(task_id: int, db: Session = Depends(get_db)):
    return task_service.toggle_task_status(db, task_id)

@router.put("/update/{task_id}")
async def update_task(task_id: int, task_data: TaskCreate, db: Session = Depends(get_db)):
    return task_service.update_task(db, task_id, task_data)

@router.delete("/delete/{task_id}")
async def delete_task(task_id: int, db: Session = Depends(get_db)):
    return task_service.delete_task(db, task_id)

# ==================== CỤM API CHO DANH MỤC (CATEGORIES) ====================

@router.get("/categories/{user_id}")
async def get_categories(user_id: int, db: Session = Depends(get_db)):
    return task_service.get_categories(db, user_id)

@router.post("/categories")
async def add_category(cat: CategoryCreate, db: Session = Depends(get_db)):
    return task_service.add_category(db, cat)

@router.delete("/categories/{cat_id}")
async def delete_category(cat_id: int, db: Session = Depends(get_db)):
    return task_service.delete_category(db, cat_id)

@router.get("/today/{user_id}")
def get_today_tasks(user_id: int, db: Session = Depends(get_db)):
    return task_service.get_today_tasks_dashboard(db, user_id)