from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
import traceback

from app.db.database import get_db_connection as get_db
<<<<<<< HEAD
# THÊM AIParsedTaskResponse VÀO ĐÂY
from app.schemas.ai_schema import NLPTaskRequest, AIParsedTaskResponse 
=======
from app.schemas.ai_schema import NLPTaskRequest
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
from app.services.ai_service import AIService

router = APIRouter(prefix="/ai", tags=["Internal AI Engine"])

<<<<<<< HEAD
# GẮN response_model VÀO ROUTER ĐỂ FASTAPI TỰ ĐỘNG CHUẨN HÓA JSON
@router.post("/nlp-task", response_model=AIParsedTaskResponse)
async def process_nlp_task(request: NLPTaskRequest, db: Session = Depends(get_db)):
    try:
        print(f"📥 [AI API Request] Tiếp nhận phân tích văn bản: '{request.text}'")
        
        # Gọi Service xử lý
        ai_parsed_result = AIService.extract_task_nlp(request.text)
        
        # Trả về Dictionary, FastAPI sẽ tự động map nó vào schema AIParsedTaskResponse
        return ai_parsed_result
        
    except Exception as e:
        print("[LỖI HỆ THỐNG MODULE AI ROUTE DETECTED]")
=======
@router.post("/nlp-task")
async def process_nlp_task(request: NLPTaskRequest, db: Session = Depends(get_db)):
    try:
        print(f"📥 [AI API Request] Tiếp nhận phân tích văn bản: '{request.text}'")
        ai_parsed_result = AIService.extract_task_nlp(request.text)
        return ai_parsed_result
    except Exception as e:
        print("\n🛑 [LỖI HỆ THỐNG MODULE AI ROUTE DETECTED] 🛑")
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
        traceback.print_exc()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Sự cố xử lý logic AI cục bộ: {str(e)}"
        )