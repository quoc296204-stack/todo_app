from datetime import date, datetime

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import cast, Date # SỬA LỖI Ở ĐÂY: Import Date từ sqlalchemy
from sqlalchemy.orm import Session
import traceback

from app.db.database import get_db_connection as get_db
from app.schemas.ai_schema import NLPTaskRequest, AIParsedTaskResponse 
from app.services.ai_service import AIService
from app.models.task_models import Task
from app.models.habit_models import Habit, HabitLog


# Router gốc đã có prefix="/ai"
router = APIRouter(prefix="/ai", tags=["Internal AI Engine"])

# 1. API PHÂN TÍCH VĂN BẢN (Đã gộp 2 hàm trùng lặp làm 1)
@router.post("/nlp-task", response_model=AIParsedTaskResponse)
async def process_nlp_task(request: NLPTaskRequest, db: Session = Depends(get_db)):
    try:
        print(f"📥 [AI API Request] Tiếp nhận phân tích văn bản: '{request.text}'")
        ai_parsed_result = AIService.extract_task_nlp(request.text)
        return ai_parsed_result
        
    except Exception as e:
        print("\n🛑 [LỖI HỆ THỐNG MODULE AI ROUTE DETECTED] 🛑")
        traceback.print_exc()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Sự cố xử lý logic AI cục bộ: {str(e)}"
        )

# 2. API GỢI Ý TỪ CURATOR (Đường dẫn thực tế: /api/ai/suggestions/{user_id})
@router.get("/suggestions/{user_id}")
def get_curator_suggestion(user_id: int, db: Session = Depends(get_db)):
    today = date.today()
    now = datetime.now()

    try:
        # ƯU TIÊN 1: Kiểm tra Task QUÁ HẠN
        overdue_tasks = db.query(Task).filter(
            Task.user_id == user_id,
            Task.is_completed == False,
            Task.deadline < now
        ).count()

        if overdue_tasks > 0:
            return {
                "title": "Cảnh báo trễ hạn 🚨",
                "message": f"Bạn đang có {overdue_tasks} công việc đã quá hạn. Hãy ưu tiên xử lý dứt điểm chúng để giải tỏa áp lực nhé!"
            }

        # ƯU TIÊN 2: Kiểm tra Task cần làm HÔM NAY
        today_tasks = db.query(Task).filter(
            Task.user_id == user_id,
            Task.is_completed == False,
            cast(Task.deadline, Date) == today
        ).count()

        if today_tasks > 0:
            return {
                "title": "Trọng tâm hôm nay ✨",
                "message": f"Bạn còn {today_tasks} công việc cần hoàn thành trong hôm nay. Lên dây cót tinh thần và bắt đầu thôi!"
            }

        # ƯU TIÊN 3: Nhắc nhở Thói quen chưa tick hôm nay
        habits_count = db.query(Habit).filter(Habit.user_id == user_id).count()
        if habits_count > 0:
            logs_today = db.query(HabitLog).filter(
                HabitLog.user_id == user_id,
                cast(HabitLog.completed_at, Date) == today
            ).count()
            
            if logs_today == 0:
                return {
                    "title": "Duy trì thói quen 🌱",
                    "message": "Hôm nay bạn chưa ghi nhận thói quen nào cả. Đừng để đứt chuỗi kỷ luật nhé!"
                }

        # MẶC ĐỊNH: Rảnh rỗi / Đã làm xong hết
        return {
            "title": "Chưa có gợi ý ✨",
            "message": "Bạn đang quản lý thời gian rất tốt, mọi thứ đều hoàn thành. Hãy tiếp tục phát huy nhé!"
        }

    except Exception as e:
        print(f"[LỖI GỢI Ý]: {str(e)}")
        return {
            "title": "Chưa có gợi ý ✨",
            "message": "Bạn đang làm rất tốt, hãy tiếp tục phát huy nhé!"
        }