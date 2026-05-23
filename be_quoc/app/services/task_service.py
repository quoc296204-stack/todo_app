
from datetime import date, timedelta
<<<<<<< HEAD
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func, case
from fastapi import HTTPException
from app.models.task_models import SubTask, Task, Category
=======
from sqlalchemy.orm import Session
from sqlalchemy import func, case
from fastapi import HTTPException
from app.models.task_models import Task, Category
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
from app.schemas.task_schema import TaskCreate, CategoryCreate 

# ==================== CỤM LOGIC CHO CÔNG VIỆC (TASKS) ====================

def create_task(db: Session, user_id: int, task_data: TaskCreate):
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
            is_completed=False  
        )
        db.add(new_task)
        db.commit()
        db.refresh(new_task)
        return {"status": 201, "message": "Thành công", "task_id": new_task.id}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Lỗi hệ thống: {str(e)}")


<<<<<<< HEAD
def get_all_tasks(db: Session, user_id: int, search: str = None, filter_by: str = "all", sort_by: str = "default"):
    try:
        # ==========================================
        # ĐÃ SỬA Ở ĐÂY: Nhét joinedload(Task.subtasks) vào
        # ==========================================
        query = db.query(Task).options(joinedload(Task.subtasks)).filter(Task.user_id == user_id)
=======
def get_all_tasks(db: Session, user_id: int, search: str, filter_by: str, sort_by: str):
    try:
        query = db.query(Task).filter(Task.user_id == user_id)
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a

        if search:
            query = query.filter(Task.title.ilike(f"%{search}%"))

        fb = str(filter_by).strip()

        # --- LỌC THEO NGÀY HÔM NAY ---
        if fb in ["today", "Hôm nay"]:
            query = query.filter(func.date(Task.deadline) == func.current_date())
            
        elif fb in ["overdue", "Quá hạn"]:
            three_days_ago = date.today() - timedelta(days=3)
            query = query.filter(
                func.date(Task.deadline) < func.current_date(),
                func.date(Task.deadline) >= three_days_ago,
                Task.is_completed == False
            )
            
        elif fb in ["completed", "Đã hoàn thành"]:
            query = query.filter(Task.is_completed == True)
            
        else:
<<<<<<< HEAD
            # Mặc định (Tất cả) sẽ trả về toàn bộ task, không lọc is_completed nữa
=======
            # ĐÃ SỬA: Mặc định (Tất cả) sẽ trả về toàn bộ task, không lọc is_completed nữa
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
            pass 

        priority_weight = case(
            (Task.priority == 'CAO', 3),
            (Task.priority == 'TRUNG BÌNH', 2),
            (Task.priority == 'THẤP', 1),
            else_=0
        )

        sb = str(sort_by).strip()
        if sb in ["Ưu tiên: Cao -> Thấp", "high_to_low"]:
            query = query.order_by(priority_weight.desc(), Task.created_at.desc())
        elif sb in ["Ưu tiên: Thấp -> Cao", "low_to_high"]:
            query = query.order_by(priority_weight.asc(), Task.created_at.desc())
        else:
            if fb in ["completed", "Đã hoàn thành"]:
                query = query.order_by(Task.completed_at.desc()) 
            else:
                query = query.order_by(Task.created_at.desc())    

        return query.all()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def toggle_task_status(db: Session, task_id: int):
    try:
        task = db.query(Task).filter(Task.id == task_id).first()
        if not task:
            raise HTTPException(status_code=404, detail="Không tìm thấy công việc")
        
        task.is_completed = not task.is_completed
        task.completed_at = func.now() if task.is_completed else None
        
        db.commit()
        return {"status": 200, "message": "Cập nhật trạng thái thành công", "is_completed": task.is_completed}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

def update_task(db: Session, task_id: int, task_data: TaskCreate):
    try:
        task = db.query(Task).filter(Task.id == task_id).first()
        if not task:
            raise HTTPException(status_code=404, detail="Không tìm thấy công việc")
        
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

def delete_task(db: Session, task_id: int):
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


# ==================== CỤM LOGIC CHO DANH MỤC (CATEGORIES) ====================

def get_categories(db: Session, user_id: int):
    try:
        return db.query(Category).filter(Category.user_id == user_id).all()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def add_category(db: Session, cat: CategoryCreate):
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

def delete_category(db: Session, cat_id: int):
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


# ==================== ENDPOINT RIÊNG CHO DASHBOARD (TÙY CHỌN DÙNG) ====================

def get_today_tasks_dashboard(db: Session, user_id: int):
    try:
        # NÂNG CẤP: Trả về TOÀN BỘ đối tượng Task (có ID, is_completed) của hôm nay 
        # để Frontend có dữ liệu vẽ biểu đồ và xử lý logic toggle
        return db.query(Task).filter(
            Task.user_id == user_id,
            func.date(Task.deadline) == func.current_date() 
        ).all()
    except Exception as e:
<<<<<<< HEAD
        raise HTTPException(status_code=500, detail=str(e))
    
def create_task_with_subtasks(db: Session, user_id: int, task_data: TaskCreate):
    # Tạo task chính
    new_task = Task(
        user_id=user_id,
        title=task_data.title,
        description=task_data.description,
        category=task_data.category,
        priority=task_data.priority,
        start_time=task_data.start_time,
        deadline=task_data.deadline,
        is_reminder=task_data.is_reminder
    )
    
    db.add(new_task)
    db.commit()
    db.refresh(new_task)
    
    # Tạo subtasks nếu có
    if task_data.subtasks and len(task_data.subtasks) > 0:
        subtask_objects = []
        for st in task_data.subtasks:
            new_subtask = SubTask(
                task_id=new_task.id,
                title=st.title,
                is_completed=st.is_checked
            )
            subtask_objects.append(new_subtask)
            
        db.add_all(subtask_objects)
        db.commit()
        
        # 2. CỰC KỲ QUAN TRỌNG: Phải refresh(new_task) lần nữa 
        # Để nó tự động nạp mảng subtasks từ Database lên RAM
        db.refresh(new_task) 
        
    return new_task
=======
        raise HTTPException(status_code=500, detail=str(e))
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
