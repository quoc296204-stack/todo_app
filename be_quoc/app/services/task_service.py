from datetime import date, timedelta
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import func, case
from fastapi import HTTPException
from app.models.task_models import SubTask, Task, Category
from app.schemas.task_schema import TaskCreate, CategoryCreate 

# Hàm hỗ trợ xử lý danh mục
def _resolve_category_id(db: Session, user_id: int, category_name: str):
    """
    Biến đổi tên danh mục (chuỗi) thành category_id (số).
    Tự động tạo danh mục mới nếu chưa tồn tại.
    """
    if not category_name:
        return None
    category_name = category_name.strip()
    category_obj = db.query(Category).filter(
        Category.name == category_name, 
        Category.user_id == user_id
    ).first()
    if category_obj:
        return category_obj.id
    # Tự động tạo mới nếu chưa có
    new_category = Category(user_id=user_id, name=category_name)
    db.add(new_category)
    db.flush() # Nạp vào DB tạm để lấy ID mà chưa cần commit chốt
    return new_category.id


# Hàm hỗ trợ công việc

def create_task(db: Session, user_id: int, task_data: TaskCreate):
    try:
        # Lấy hoặc tạo category_id chuẩn từ tên gửi lên
        cat_id = task_data.category_id
        if not cat_id and task_data.category:
            cat_id = _resolve_category_id(db, user_id, task_data.category)
        new_task = Task(
            user_id=user_id,
            title=task_data.title,
            description=task_data.description,
            category_id=cat_id, # ĐÃ SỬA
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

def create_task_with_subtasks(db: Session, user_id: int, task_data: TaskCreate):
    try:
        cat_id = task_data.category_id
        if not cat_id and task_data.category:
            cat_id = _resolve_category_id(db, user_id, task_data.category)
        new_task = Task(
            user_id=user_id,
            title=task_data.title,
            description=task_data.description,
            category_id=cat_id, # ĐÃ SỬA
            priority=task_data.priority,
            start_time=task_data.start_time,
            deadline=task_data.deadline,
            is_reminder=task_data.is_reminder,
            is_completed=False
        )
        db.add(new_task)
        db.flush() # Lấy new_task.id để làm khóa ngoại cho subtasks
        # Tạo subtasks nếu có
        if hasattr(task_data, 'subtasks') and task_data.subtasks:
            subtask_objects = []
            for st in task_data.subtasks:
                new_subtask = SubTask(
                    task_id=new_task.id,
                    title=st.title,
                    is_completed=st.is_checked if hasattr(st, 'is_checked') else False
                )
                subtask_objects.append(new_subtask)
            db.add_all(subtask_objects)
        db.commit()
        db.refresh(new_task) 
        return new_task
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=f"Lỗi hệ thống: {str(e)}")

def get_all_tasks(db: Session, user_id: int, search: str = None, filter_by: str = "all", sort_by: str = "default"):
    try:
        query = db.query(Task).options(
            joinedload(Task.subtasks),
            joinedload(Task.category_info) 
        ).filter(Task.user_id == user_id)
        if search:
            query = query.filter(Task.title.ilike(f"%{search}%"))
        fb = str(filter_by).strip()
        # --- LỌC ---
        if fb in ["today", "Hôm nay"]:
            query = query.filter(func.date(Task.deadline) == func.current_date())
        elif fb in ["overdue", "Quá hạn"]:
            three_days_ago = date.today() - timedelta(days=3)
            query = query.filter(func.date(Task.deadline) < func.current_date(), func.date(Task.deadline) >= three_days_ago, Task.is_completed == False)
        elif fb in ["completed", "Đã hoàn thành"]:
            query = query.filter(Task.is_completed == True)
        # --- SẮP XẾP ---
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
            query = query.order_by(Task.created_at.desc())    

        return query.all()
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def toggle_task_status(db: Session, task_id: int):
    try:
        task = db.query(Task).filter(Task.id == task_id).first()
        if not task: raise HTTPException(status_code=404, detail="Không tìm thấy công việc")
        task.is_completed = not task.is_completed
        task.completed_at = func.now() if task.is_completed else None
        db.commit()
        return {"status": 200, "message": "Thành công", "is_completed": task.is_completed}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))
    

def update_task(db: Session, task_id: int, task_data: TaskCreate):
    try:
        task = db.query(Task).filter(Task.id == task_id).first()
        if not task: raise HTTPException(status_code=404, detail="Không tìm thấy")
    
        cat_id = task_data.category_id
        if not cat_id and task_data.category:
            cat_id = _resolve_category_id(db, task.user_id, task_data.category)
        elif not cat_id:
            cat_id = task.category_id # Giữ nguyên ID cũ nếu không gửi gì
        task.title = task_data.title
        task.description = task_data.description
        task.category_id = cat_id 
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
        if not task: raise HTTPException(status_code=404, detail="Không tìm thấy")
        db.delete(task)
        db.commit()
        return {"status": 200, "message": "Xóa thành công"}
    except Exception as e:
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

# cụm logoic danh mục

def get_categories(db: Session, user_id: int):
    return db.query(Category).filter(Category.user_id == user_id).all()

def add_category(db: Session, cat: CategoryCreate):
    count = db.query(Category).filter(Category.user_id == cat.user_id).count()
    if count >= 10: raise HTTPException(status_code=400, detail="Tối đa 10 danh mục")
    new_cat = Category(user_id=cat.user_id, name=cat.name)
    db.add(new_cat)
    db.commit()
    return {"status": 201, "message": "Thành công"}

def delete_category(db: Session, cat_id: int):
    cat = db.query(Category).filter(Category.id == cat_id).first()
    if not cat: raise HTTPException(status_code=404, detail="Không tìm thấy")
    db.delete(cat)
    db.commit()
    return {"status": 200, "message": "Xóa thành công"}