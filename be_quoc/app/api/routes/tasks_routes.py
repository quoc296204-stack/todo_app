from datetime import date, timedelta
from fastapi import APIRouter, HTTPException, Depends, Query
from pydantic import BaseModel
from typing import Optional, List
from sqlalchemy.orm import Session
from sqlalchemy import func, case
from app.db.database import get_db_connection  # Giữ nguyên hàm dependency của bạn
from app.models.task_models import Task, Category 

router = APIRouter(prefix="/api/tasks", tags=["Tasks"])

# --- KHAI BÁO SCHEMAS (PYDANTIC) ---
class TaskCreate(BaseModel):
    title: str
    description: Optional[str] = None
    category: str
    start_time: str 
    deadline: str
    priority: str
    is_reminder: bool

class CategoryCreate(BaseModel):
    user_id: int
    name: str

# ==================== CỤM API CHO CÔNG VIỆC (TASKS) ====================

# 1. TẠO MỚI CÔNG VIỆC (Dùng ORM)
@router.post("/create/{user_id}")
async def create_task(user_id: int, task_data: TaskCreate, db: Session = Depends(get_db_connection)):
    try:
        new_task = Task(
            user_id=user_id,
            title=task_data.title,
            description=task_data.description,
            category=task_data.category,
            priority=task_data.priority,
            start_time=task_data.start_time,
            deadline=task_data.deadline,
            is_reminder=task_data.is_reminder,
            is_completed=False  # Mặc định tạo mới là chưa hoàn thành
        )
        db.add(new_task)
        db.commit()
        db.refresh(new_task)
        return {"status": 201, "message": "Thành công", "task_id": new_task.id}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Lỗi hệ thống: {str(e)}")


# 2. LẤY DANH SÁCH CÔNG VIỆC (Đã cập nhật sửa lỗi Lọc & Sắp xếp theo ý Hiếu)
@router.get("/all/{user_id}")
async def get_all_tasks(
    user_id: int, 
    search: Optional[str] = Query(None),
    filter_by: Optional[str] = Query("all"),  # Nhận cả mã tiếng Anh từ Flutter: all, today, overdue, completed
    sort_by: Optional[str] = Query("default"), # Nhận: default, high_to_low, low_to_high
    db: Session = Depends(get_db_connection)
):
    try:
        # Khởi tạo câu lệnh query gốc tìm theo user_id
        query = db.query(Task).filter(Task.user_id == user_id)

        # Xử lý tìm kiếm tương đối (nếu có)
        if search:
            query = query.filter(Task.title.ilike(f"%{search}%"))

        # Chuẩn hóa chuỗi bộ lọc nhận được để so sánh chính xác
        fb = str(filter_by).strip()

        # --- CẬP NHẬT LOGIC BỘ LỌC CHÍNH XÁC ---
        if fb in ["today", "Hôm nay"]:
            # Chỉ lấy việc của ngày hôm nay VÀ chưa hoàn thành
            query = query.filter(
                func.date(Task.start_time) == func.current_date(), 
                Task.is_completed == False
            )
            
        elif fb in ["overdue", "Quá hạn"]:
            # CẬP NHẬT: Chỉ lấy deadline TRƯỚC HÔM NAY (loại trừ hôm nay) và trong vòng 3 ngày gần nhất, chưa hoàn thành
            three_days_ago = date.today() - timedelta(days=3)
            query = query.filter(
                func.date(Task.deadline) < func.current_date(),
                func.date(Task.deadline) >= three_days_ago,
                Task.is_completed == False
            )
            
        elif fb in ["completed", "Đã hoàn thành"]:
            # CẬP NHẬT: CHỈ trả về những công việc đã hoàn thành (Không bị lẫn lộn dữ liệu khác)
            query = query.filter(Task.is_completed == True)
            
        else:
            # Tab "Tất cả" (all): Chỉ hiển thị các công việc chưa hoàn thành để tránh bị lẫn lộn full task
            query = query.filter(Task.is_completed == False)

        # Tính toán trọng số sắp xếp độ ưu tiên của công việc
        priority_weight = case(
            (Task.priority == 'CAO', 3),
            (Task.priority == 'TRUNG BÌNH', 2),
            (Task.priority == 'THẤP', 1),
            else_=0
        )

        # Thực hiện sắp xếp dữ liệu trả về cho phù hợp
        sb = str(sort_by).strip()
        if sb in ["Ưu tiên: Cao -> Thấp", "high_to_low"]:
            query = query.order_by(priority_weight.desc(), Task.created_at.desc())
        elif sb in ["Ưu tiên: Thấp -> Cao", "low_to_high"]:
            query = query.order_by(priority_weight.asc(), Task.created_at.desc())
        else:
            # Mặc định sắp xếp sắp xếp
            if fb in ["completed", "Đã hoàn thành"]:
                query = query.order_by(Task.completed_at.desc())  # Thằng nào vừa làm xong thì lên đầu
            else:
                query = query.order_by(Task.created_at.desc())    # Thằng nào mới tạo thì lên đầu

        return query.all()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# 3. API ĐẢO TRẠNG THÁI HOÀN THÀNH CÔNG VIỆC (TOGGLE)
@router.post("/toggle/{task_id}")
async def toggle_task_status(task_id: int, db: Session = Depends(get_db_connection)):
    try:
        task = db.query(Task).filter(Task.id == task_id).first()
        if not task:
            raise HTTPException(status_code=404, detail="Không tìm thấy công việc")
        
        # Đảo trạng thái True <-> False
        task.is_completed = not task.is_completed
        # Nếu tích chọn hoàn thành thì lưu thời gian hiện tại, nếu hủy chọn thì xóa đi
        task.completed_at = func.now() if task.is_completed else None
        
        db.commit()
        return {"status": 200, "message": "Cập nhật trạng thái thành công", "is_completed": task.is_completed}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))


# 4. CẬP NHẬT CÔNG VIỆC
@router.put("/update/{task_id}")
async def update_task(task_id: int, task_data: TaskCreate, db: Session = Depends(get_db_connection)):
    try:
        task = db.query(Task).filter(Task.id == task_id).first()
        if not task:
            raise HTTPException(status_code=404, detail="Không tìm thấy công việc")
        
        # Gán giá trị mới
        task.title = task_data.title
        task.description = task_data.description
        task.category = task_data.category
        task.priority = task_data.priority
        task.start_time = task_data.start_time
        task.deadline = task_data.deadline
        task.is_reminder = task_data.is_reminder
        
        db.commit()
        return {"status": 200, "message": "Cập nhật thành công"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))


# 5. XÓA CÔNG VIỆC
@router.delete("/delete/{task_id}")
async def delete_task(task_id: int, db: Session = Depends(get_db_connection)):
    try:
        task = db.query(Task).filter(Task.id == task_id).first()
        if not task:
            raise HTTPException(status_code=404, detail="Không tìm thấy công việc")
        
        db.delete(task)
        db.commit()
        return {"status": 200, "message": "Xóa thành công"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))


# ==================== CỤM API CHO DANH MỤC (CATEGORIES) ====================

# 1. LẤY DANH SÁCH DANH MỤC CỦA USER
@router.get("/categories/{user_id}")
async def get_categories(user_id: int, db: Session = Depends(get_db_connection)):
    try:
        categories = db.query(Category).filter(Category.user_id == user_id).all()
        return categories
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


# 2. THÊM DANH MỤC MỚI (Giới hạn tối đa 10)
@router.post("/categories")
async def add_category(cat: CategoryCreate, db: Session = Depends(get_db_connection)):
    try:
        count = db.query(Category).filter(Category.user_id == cat.user_id).count()
        if count >= 10:
            raise HTTPException(status_code=400, detail="Bạn chỉ được tạo tối đa 10 danh mục")

        new_cat = Category(user_id=cat.user_id, name=cat.name)
        db.add(new_cat)
        db.commit()
        return {"status": 201, "message": "Thành công"}
    except HTTPException as he:
        raise he
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e)) 


# 3. XÓA DANH MỤC
@router.delete("/categories/{cat_id}")
async def delete_category(cat_id: int, db: Session = Depends(get_db_connection)):
    try:
        cat = db.query(Category).filter(Category.id == cat_id).first()
        if not cat:
            raise HTTPException(status_code=404, detail="Không tìm thấy danh mục")
        
        db.delete(cat)
        db.commit()
        return {"status": 200, "message": "Xóa thành công"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e)) 


# 4. LẤY DANH SÁCH CÔNG VIỆC HÔM NAY (Cho màn hình Dashboard chính)
@router.get("/today/{user_id}")
def get_today_tasks(user_id: int, db: Session = Depends(get_db_connection)):
    try:
        results = db.query(
            Task.title,
            func.date_format(Task.start_time, '%H:%i').label('time'),
            Task.priority
        ).filter(
            Task.user_id == user_id,
            func.date(Task.start_time) == func.current_date(),
            Task.is_completed == False  # Chỉ lấy việc chưa hoàn thành lên Dashboard
        ).all()
        
        return [{"title": r.title, "time": r.time, "priority": r.priority} for r in results]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))