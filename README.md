
### **README.md**

# 🚀 Smart To-Do & AI Task Manager

Một ứng dụng quản lý công việc thông minh, tích hợp trí tuệ nhân tạo (Local AI Engine) để tự động phân tích ngôn ngữ tự nhiên, lập kế hoạch và phân rã công việc lớn thành các bước triển khai chi tiết.

## 🌟 Tính năng nổi bật

* **AI Smart Planning:** Sử dụng động cơ Rule-based NLP để bóc tách ý định, phân loại danh mục và tự động gợi ý danh sách việc con (Subtasks).
* **Quản lý công việc thông minh:** Hỗ trợ CRUD công việc, lọc theo thời gian (Hôm nay, Quá hạn), sắp xếp theo mức độ ưu tiên.
* **Chi tiết hóa quy trình:** Giao diện chi tiết với thanh tiến độ (Progress Bar) và checklist cho từng việc con.
* **Kiến trúc hiện đại:** * **Backend:** FastAPI (Python), SQLAlchemy (ORM), MySQL.
* **Frontend:** Flutter (Dart), kiến trúc Feature-first dễ bảo trì.



## 🛠 Công nghệ sử dụng

* **Frontend:** Flutter, `http`, `shared_preferences`.
* **Backend:** FastAPI, Pydantic, SQLAlchemy.
* **Database:** MySQL.
* **AI/NLP:** Thuật toán Regex & Rule-based Matching tùy chỉnh.

## 📂 Cấu trúc dự án

```text

├── be_quoc/                # Backend (FastAPI)
│   ├── app/
│   │   ├── api/routes/     # Các API Endpoints
│   │   ├── models/         # SQLAlchemy Models (DB Schema)
│   │   ├── schemas/        # Pydantic Schemas (Data validation)
│   │   └── services/       # Business Logic (AI & Task logic)
│   └── scripts/            # Dữ liệu training (ai_training_data.json)
└── fe_todoapp/             # Frontend (Flutter)
    └── lib/
        ├── data/           # Services & Models
        ├── features/       # Giao diện từng tính năng (AI, Auth, Task, v.v.)
        └── shared/         # Widgets dùng chung

```

## 🚀 Hướng dẫn cài đặt

🛠️ Công cụ yêu cầu: Python (3.9+), Flutter SDK, dart sdk , mysql , vscode( or pycharm ) androi studio
🛠️ CSDL liên hệ qua email : quoc296204@gmail.com
🛠️ Tải repo về 
### 1. Khởi chạy Backend (Python/FastAPI)
Mở Terminal và chạy lần lượt:

1. `cd be_quoc`:vào thư mục back_end
2. `python -m venv venv` : nơi sẽ chứa các thư viện để chạy be 
3. `pip install -r requirements.txt` : file text đã chứa danh sách thư viện cần thiết 
4. `.\venv\Scripts\activate` : kích hoạt thư viện venv
5. `uvicorn app.main:myapp --host 0.0.0.0 --port 8000 --reload` : kích hoạt uvicorn để chạy
6. terminal sẽ báo trạng thái thành công là được !
7. Muốn chắc cú có thể vào swager để check docs#

### 2. Khởi chạy Frontend (Flutter)
Mở một Terminal mới và chạy:

1. `cd fe_todoapp` 
2. `flutter pub get` : cật nhật các thư viện đã liệt kê ở pubspec.yaml
3. Nhớ chọn môi trườg để chạy nhó 
4. `flutter run` : chạy nhó hoặc bấm nút run ở trên 


Mẹo chọn thiết bị: Xem danh sách bằng flutter devices ➔ Chạy đích danh bằng flutter run -d <mã_thiết_bị>.

### 3. Lưu ý khi chạy trên Điện thoại thật (Dùng Ngrok) 
- Dự án này mình dùng thiết bị thật và sử dụng ngrok làm đường hầm 
- Cấu hình ở file constant.dart( bên fe) 
- Hướng dẫn sử dụng ngrok: `https://www.youtube.com/watch?v=Cxi3cHpV238`

Chạy lệnh: ngrok http 8000 (để public port của Backend).

Copy đường dẫn https://...ngrok-free.app hiển thị trên màn hình Ngrok.

Thay thế địa chỉ http://127.0.0.1:8000 trong code cấu hình API của Flutter bằng đường dẫn vừa copy.

Chạy lại flutter run.
