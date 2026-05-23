import os
import json
import re
from datetime import datetime, timedelta

class AIService:
    _cached_data = None  # Cơ chế RAM Cache chặn hiện tượng Blocking I/O

    @staticmethod
    def _load_training_data() -> list:
        """Nạp dữ liệu tri thức Few-shot lên RAM một lần duy nhất khi khởi động hệ thống"""
        if AIService._cached_data is not None:
            return AIService._cached_data
            
        try:
            # Thuật toán truy cập file an toàn lùi 2 cấp
            current_dir = os.path.dirname(os.path.abspath(__file__))
            json_path = os.path.normpath(os.path.join(current_dir, "..", "..", "scripts", "ai_training_data.json"))
            
            with open(json_path, "r", encoding="utf-8") as file:
                data = json.load(file)
                AIService._cached_data = data.get("examples", [])
                return AIService._cached_data
        except Exception as e:
            print(f"⚠️ [AIService RAM Cache Error] Không tìm thấy file JSON: {str(e)}")
            return []

    @staticmethod
    def extract_task_nlp(text: str) -> dict:
        """Thuật toán phân tích ý định ngôn ngữ tự nhiên (NLP) kết hợp đối sánh Regex"""
        if not text or text.strip() == "":
            return AIService._get_fallback_safety_response("Nhiệm vụ mới")

        text_lower = text.lower()
        training_examples = AIService._load_training_data()
        
        # 1. MA TRẬN ĐỐI SÁNH TỪ KHÓA (SCORE MATCHER)
        best_match = None
        max_score = 0
        for example in training_examples:
            score = 0
            for kw in example["keywords"]:
                # Bảo toàn ranh giới cụm từ tiếng Việt
                if re.search(rf'\b{re.escape(kw.lower())}\b', text_lower):
                    score += 1
            if score > max_score:
                max_score = score
                best_match = example

        # 2. XỬ LÝ TEXT & SINH TIÊU ĐỀ
        if best_match and max_score > 0:
            matched_title = best_match["title"]
            matched_desc = best_match["description"]
            matched_cat = best_match["category"]
            is_large_task = best_match["is_large_task"]
        else:
            # Thuật toán lọc rác cho các câu lệnh tự do
            clean_text = text
            stop_words = ["gấp", "khẩn cấp", "quan trọng", "mai", "kia", "hôm nay", "lúc", "nhớ", "vội"]
            for w in stop_words:
                clean_text = re.sub(rf'\b{w}\b', '', clean_text, flags=re.IGNORECASE)
            
            # Xóa cụm giờ
            clean_text = re.sub(r'\d{1,2}\s*(h|giờ|:)\s*\d{0,2}', '', clean_text, flags=re.IGNORECASE)
            
            matched_title = re.sub(r'\s+', ' ', clean_text).strip().capitalize()
            if not matched_title:
                matched_title = "Nhiệm vụ tự lập bằng AI"
                
            matched_desc = f"Nhiệm vụ lập lịch tự động: {matched_title}."
            matched_cat = "Cá nhân"
            
            large_keywords = ["đồ án", "báo cáo", "học", "thi", "dọn dẹp", "kế hoạch", "nghiên cứu", "project"]
            is_large_task = any(kw in text_lower for kw in large_keywords)

        # 3. TRÍCH XUẤT THỜI GIAN
        target_date = datetime.now()
        if "mai" in text_lower:
            target_date += timedelta(days=1)
        elif "kia" in text_lower:
            target_date += timedelta(days=2)

        time_match = re.search(r'(\d{1,2})\s*(h|giờ|:)\s*(\d{2})?', text_lower)
        hour, minute = 23, 59
        if time_match:
            hour = int(time_match.group(1))
            minute = int(time_match.group(3)) if time_match.group(3) else 0

        due_datetime = target_date.replace(hour=hour, minute=minute, second=0, microsecond=0)
        
        # 4. ƯU TIÊN
        priority = "Trung bình"
        if any(kw in text_lower for kw in ["gấp", "khẩn cấp", "quan trọng", "vội"]):
            priority = "Cao"
        elif any(kw in text_lower for kw in ["rảnh", "thong thả"]):
            priority = "Thấp"

        # 5. SINH SUBTASKS
        subtasks = []
        if is_large_task:
            subtasks = AIService.decompose_task_to_subtasks(matched_title)

        return {
            "title": matched_title,
            "description": matched_desc,
            "category": matched_cat,
            "priority": priority,
            "start_time": datetime.now().strftime("%Y-%m-%d %H:%M"),
            "deadline": due_datetime.strftime("%Y-%m-%d %H:%M"),
            "subtasks": subtasks
        }

    @staticmethod
    def _get_fallback_safety_response(default_title: str) -> dict:
        return {
            "title": default_title,
            "description": f"Nhiệm vụ lập lịch tự động: {default_title}.",
            "category": "Cá nhân",
            "priority": "Trung bình",
            "start_time": datetime.now().strftime("%Y-%m-%d %H:%M"),
            "deadline": (datetime.now() + timedelta(days=1)).strftime("%Y-%m-%d %H:%M"),
            "subtasks": []
        }

    @staticmethod
    def decompose_task_to_subtasks(title: str) -> list:
        """Hệ thống chuyên gia phân rã subtasks"""
        title_lower = title.lower()
        if any(kw in title_lower for kw in ["đồ án", "tốt nghiệp", "project"]):
            return [
                {"title": "Phân tích yêu cầu đề tài & Thiết kế CSDL", "is_checked": False},
                {"title": "Dựng giao diện UI hoàn chỉnh (Flutter)", "is_checked": False},
                {"title": "Viết hệ thống API Backend (FastAPI)", "is_checked": False},
                {"title": "Kiểm thử liên thông và sửa lỗi", "is_checked": False}
            ]
        if any(kw in title_lower for kw in ["báo cáo", "slide"]):
            return [
                {"title": "Chuẩn bị dàn ý nội dung sơ bộ", "is_checked": False},
                {"title": "Triển khai nội dung cốt lõi chi tiết", "is_checked": False},
                {"title": "Rà soát lỗi và hoàn thiện", "is_checked": False}
            ]
        return [
            {"title": "Chuẩn bị tài liệu và công cụ", "is_checked": False},
            {"title": "Tiến hành thực hiện nhiệm vụ", "is_checked": False},
            {"title": "Kiểm tra kết quả nghiệm thu", "is_checked": False}
        ]