import os
import json
import re
from datetime import datetime, timedelta

class AIService:
<<<<<<< HEAD
    _cached_data = None  # Cơ chế RAM Cache chặn hoàn toàn hiện tượng Blocking I/O
=======
    _cached_data = None  # Cơ chế RAM Cache chặn hoàn toàn hiện tượng Blocking I/O gây kẹt luồng
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a

    @staticmethod
    def _load_training_data() -> list:
        """Nạp dữ liệu tri thức Few-shot lên RAM một lần duy nhất khi khởi động hệ thống"""
        if AIService._cached_data is not None:
            return AIService._cached_data
            
        try:
<<<<<<< HEAD
            # Thuật toán dịch chuyển an toàn ra ngoài thư mục scripts/
=======
            # Thuật toán dịch chuyển an toàn lùi 2 cấp từ app/services/ để nhảy ra ngoài và truy cập scripts/
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
            current_dir = os.path.dirname(os.path.abspath(__file__))
            json_path = os.path.normpath(os.path.join(current_dir, "..", "..", "scripts", "ai_training_data.json"))
            
            with open(json_path, "r", encoding="utf-8") as file:
                data = json.load(file)
                AIService._cached_data = data.get("examples", [])
                return AIService._cached_data
        except Exception as e:
            print(f"⚠️ [AIService RAM Cache Error] Không tìm thấy file JSON tri thức: {str(e)}")
            return []

    @staticmethod
    def extract_task_nlp(text: str) -> dict:
<<<<<<< HEAD
        """Thuật toán đối sánh ranh giới từ vựng \\b kết hợp Regex thông minh"""
=======
        """Thuật toán đối sánh ranh giới từ vựng \\b tiếng Việt kết hợp tính điểm trọng số"""
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
        if not text or text.strip() == "":
            return AIService._get_fallback_safety_response("Nhiệm vụ mới")

        text_lower = text.lower()
        training_examples = AIService._load_training_data()
        
<<<<<<< HEAD
        # 1. ĐỐI SÁNH TỪ KHÓA TRONG FILE JSON ĐỂ LẤY KHUÔN (TEMPLATE)
        best_match = None
        max_score = 0
        
        for example in training_examples:
            score = 0
            for kw in example["keywords"]:
=======
        matched_title = None
        matched_desc = None
        matched_cat = "Cá nhân"
        is_large_task = False
        
        best_match = None
        max_score = 0
        
        # Ma trận duyệt tính toán điểm trọng số trùng khớp từ khóa cụ thể (Score Matcher)
        for example in training_examples:
            score = 0
            for kw in example["keywords"]:
                # Sử dụng nhãn \b bảo toàn ranh giới cụm từ tiếng Việt, chống trùng lắp ký tự con
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
                if re.search(rf'\b{re.escape(kw.lower())}\b', text_lower):
                    score += 1
            if score > max_score:
                max_score = score
                best_match = example
                
<<<<<<< HEAD
        # 2. BÓC TÁCH & LÀM SẠCH TIÊU ĐỀ (Xóa các từ chỉ thời gian, trạng thái)
        # ==========================================
        # 2. BÓC TÁCH & LÀM SẠCH TIÊU ĐỀ (Phiên bản V2)
        # ==========================================
        clean_text = text
        
        # Từ điển Stop-words mở rộng: Quét sạch mọi trạng từ chỉ thời gian và cảm thán
        stop_words = [
            "gấp", "khẩn cấp", "quan trọng", "nhớ", "vội", "cần", "phải",
            "hôm nay", "nay", "ngày mai", "mai", "ngày kia", "kia",
            "tuần này", "tuần sau", "tháng này",
            "sáng", "trưa", "chiều", "tối", "đêm",
            "lúc", "vào", "khoảng", "tầm", "nhé", "nha", "đi" 
            # Lưu ý: nếu có chữ "đi", "đi siêu thị" sẽ thành "Siêu thị", rất gọn.
        ]
        
        # 2.1 Lọc Stop-words bằng ranh giới từ \b
        for w in stop_words:
            clean_text = re.sub(rf'\b{w}\b', '', clean_text, flags=re.IGNORECASE)
            
        # 2.2 Quét sạch các cụm giờ phức tạp (VD: 8h, 8h30, 15:00, 8g)
        clean_text = re.sub(r'\d{1,2}\s*(h|giờ|g|:)\s*\d{0,2}', '', clean_text, flags=re.IGNORECASE)
        
        # 2.3 Xóa các ký tự đặc biệt thừa thãi bị rớt lại (như dấu phẩy, gạch ngang)
        clean_text = re.sub(r'[^\w\s]', '', clean_text)
        
        # 2.4 Dọn dẹp khoảng trắng và viết hoa chữ cái đầu
        clean_title = re.sub(r'\s+', ' ', clean_text).strip().capitalize()
        
        if best_match and max_score > 0:
            # Thuật toán thông minh: Nếu sau khi lọc mà câu chữ còn dài (> 4 ký tự), 
            # lấy luôn chữ của người dùng làm tiêu đề. Ngược lại thì mượn tiêu đề của File JSON
            matched_title = clean_title if len(clean_title) > 4 else best_match["title"]
            matched_desc = best_match["description"]
            matched_cat = best_match["category"]
            is_large_task = best_match["is_large_task"]
            subtasks_template = best_match.get("subtasks", [])
        else:
            # ... (Phần dự phòng giữ nguyên)
            matched_title = clean_title if clean_title else "Nhiệm vụ tự lập bằng AI"
            matched_desc = f"Nhiệm vụ được tạo từ hệ thống AI: {matched_title}."
            matched_cat = "Cá nhân"
            
            # Quét các từ vựng lớn dự phòng
            large_keywords = ["đồ án", "báo cáo", "học", "thi", "dọn dẹp", "kế hoạch", "nghiên cứu", "project", "event", "sự kiện"]
            is_large_task = any(kw in text_lower for kw in large_keywords)
            subtasks_template = []

        # 3. BÓC TÁCH THỜI GIAN (XỬ LÝ LUÔN CẢ SÁNG/CHIỀU/TỐI)
        target_date = datetime.now()
        if re.search(rf'\bmai\b', text_lower):
            target_date += timedelta(days=1)
        elif re.search(rf'\bkia\b', text_lower):
            target_date += timedelta(days=2)

        time_match = re.search(r'(\d{1,2})\s*(h|giờ|:)\s*(\d{2})?', text_lower)
        hour, minute = 23, 59  # Mặc định cuối ngày nếu không ghi rõ
        
        if time_match:
            raw_hour = int(time_match.group(1))
            minute = int(time_match.group(3)) if time_match.group(3) else 0
            
            # Thuật toán thông minh hiểu Sáng/Chiều
            if re.search(rf'\bchiều\b|\btối\b', text_lower):
                if raw_hour < 12:
                    raw_hour += 12
            elif re.search(rf'\bsáng\b', text_lower):
                if raw_hour == 12:
                    raw_hour = 0
            
            hour = raw_hour

        due_datetime = target_date.replace(hour=hour, minute=minute, second=0, microsecond=0)
        
        # 4. MỨC ĐỘ ƯU TIÊN (Trả về đúng định dạng cho Schema của bạn)
        priority = "Trung bình"
        if any(kw in text_lower for kw in ["gấp", "khẩn cấp", "quan trọng", "vội", "deadline"]):
=======
        if best_match and max_score > 0:
            matched_title = best_match["title"]
            matched_desc = best_match["description"]
            matched_cat = best_match["category"]
            is_large_task = best_match["is_large_task"]
        else:
            # Fallback Safety Engine: Lọc sạch văn cảnh khi câu lệnh lạ nằm ngoài file tri thức huấn luyện JSON
            clean_text = text
            stop_words = ["gấp", "khẩn cấp", "quan trọng", "mai", "kia", "hôm nay", "lúc", "nhớ", "vội"]
            for w in stop_words:
                clean_text = re.sub(rf'\b{w}\b', '', clean_text, flags=re.IGNORECASE)
            clean_text = re.sub(r'\d{1,2}\s*(h|giờ|:)\s*\d{0,2}', '', clean_text, flags=re.IGNORECASE)
            
            matched_title = re.sub(r'\s+', ' ', clean_text).strip().capitalize()
            # Bảo vệ tuyệt đối đầu ra không bao giờ trả về chuỗi rỗng gây sập giao diện Flutter
            if not matched_title or matched_title == "":
                matched_title = "Nhiệm vụ tự lập bằng AI"
                
            matched_desc = f"Nhiệm vụ lập lịch tự động cho đầu việc: {matched_title}."
            
            # Thẩm định độ phức tạp từ khóa cốt lõi để quyết định gán nhãn việc lớn/nhỏ
            large_keywords = ["đồ án", "báo cáo", "học", "thi", "dọn dẹp", "kết hoạch", "nghiên cứu", "project"]
            is_large_task = any(kw in text_lower for kw in large_keywords)

        # Trích xuất bóc tách mốc thời gian cục bộ bằng Regex
        target_date = datetime.now()
        if "mai" in text_lower:
            target_date += timedelta(days=1)
        elif "kia" in text_lower:
            target_date += timedelta(days=2)

        time_match = re.search(r'(\d{1,2})\s*(h|giờ|:)\s*(\d{2})?', text_lower)
        hour, minute = 23, 59  # Hạn chót mặc định vào cuối ngày nếu không chỉ rõ giờ
        if time_match:
            hour = int(time_match.group(1))
            minute = int(time_match.group(3)) if time_match.group(3) else 0

        due_datetime = target_date.replace(hour=hour, minute=minute, second=0, microsecond=0)
        
        # Phân cấp mức độ ưu tiên nhiệm vụ
        priority = "Trung bình"
        if any(kw in text_lower for kw in ["gấp", "khẩn cấp", "quan trọng", "vội"]):
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
            priority = "Cao"
        elif any(kw in text_lower for kw in ["rảnh", "thong thả", "từ từ"]):
            priority = "Thấp"

<<<<<<< HEAD
        # 5. SINH DANH SÁCH SUBTASKS CHUẨN XÁC
        subtasks = []
        if is_large_task:
            if subtasks_template:
                # Trích xuất 100% từ file JSON
                subtasks = [{"title": st, "is_checked": False} for st in subtasks_template]
            else:
                # Hệ thống dự phòng nếu phát hiện việc lớn nhưng không có trong JSON
                subtasks = AIService._generate_fallback_subtasks(matched_title)

        # Output định dạng chuẩn Pydantic của bạn
=======
        # Tự động sinh danh sách việc con: Nếu là việc nhỏ (is_large_task: false) mảng trả về rỗng để Flutter tự ẩn UI
        subtasks = []
        if is_large_task:
            subtasks = AIService.decompose_task_to_subtasks(matched_title)

>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
        return {
            "title": matched_title,
            "description": matched_desc,
            "category": matched_cat,
            "priority": priority,
<<<<<<< HEAD
            "start_time": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
            "deadline": due_datetime.strftime("%Y-%m-%d %H:%M:%S"),
=======
            "start_time": datetime.now().strftime("%Y-%m-%d %H:%M"),
            "deadline": due_datetime.strftime("%Y-%m-%d %H:%M"),
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
            "subtasks": subtasks
        }

    @staticmethod
    def _get_fallback_safety_response(default_title: str) -> dict:
<<<<<<< HEAD
        """Bọc lót an toàn tuyệt đối chống crash Frontend"""
        now_str = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        future_str = (datetime.now() + timedelta(days=1)).replace(hour=23, minute=59).strftime("%Y-%m-%d %H:%M:%S")
        return {
            "title": default_title,
            "description": f"Hệ thống tạo nhiệm vụ tự động.",
=======
        """Hàm bọc lót an toàn tuyệt đối chống lỗi trả dữ liệu chuỗi rỗng"""
        now_str = datetime.now().strftime("%Y-%m-%d %H:%M")
        future_str = (datetime.now() + timedelta(days=1)).replace(hour=23, minute=59).strftime("%Y-%m-%d %H:%M")
        return {
            "title": default_title,
            "description": f"Nhiệm vụ lập lịch tự động cho đầu việc: {default_title}.",
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
            "category": "Cá nhân",
            "priority": "Trung bình",
            "start_time": now_str,
            "deadline": future_str,
            "subtasks": []
        }

    @staticmethod
<<<<<<< HEAD
    def _generate_fallback_subtasks(title: str) -> list:
        """Sinh subtasks mặc định nếu là việc lớn ngoại lệ"""
        return [
            {"title": f"Chuẩn bị tài liệu và công cụ cho: {title}", "is_checked": False},
            {"title": "Bắt đầu triển khai các hạng mục chính", "is_checked": False},
            {"title": "Kiểm tra nghiệm thu và hoàn thành", "is_checked": False}
=======
    def decompose_task_to_subtasks(title: str) -> list:
        """Hệ thống chuyên gia phân rã các bước hành động cụ thể cho Task lớn"""
        title_lower = title.lower()
        if "đồ án" in title_lower or "tốt nghiệp" in title_lower or "project" in title_lower:
            return [
                {"title": "Phân tích yêu cầu đề tài & Thiết kế cấu trúc CSDL", "is_checked": False},
                {"title": "Dựng giao diện UI hoàn chỉnh trên phần mềm Flutter", "is_checked": False},
                {"title": "Viết hệ thống API chức năng Backend FastAPI", "is_checked": False},
                {"title": "Kiểm thử liên thông toàn hệ thống và sửa lỗi", "is_checked": False}
            ]
        if "báo cáo" in title_lower or "slide" in title_lower:
            return [
                {"title": "Giai đoạn 1: Chuẩn bị công cụ và lập dàn ý nội dung sơ bộ", "is_checked": False},
                {"title": "Giai đoạn 2: Triển khai nội dung cốt lõi chi tiết", "is_checked": False},
                {"title": "Giai đoạn 3: Rà soát lỗi, kiểm tra chất lượng và hoàn thiện", "is_checked": False}
            ]
        return [
            {"title": "Chuẩn bị các tài liệu và công cụ liên quan", "is_checked": False},
            {"title": "Tiến hành thực hiện nhiệm vụ chính", "is_checked": False},
            {"title": "Kiểm tra kết quả nghiệm thu cuối cùng", "is_checked": False}
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
        ]