
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
D:\do_an \

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

### 1. Backend

1. Di chuyển vào thư mục `be_quoc`: `cd be_quoc`
2. Cài đặt thư viện: `pip install -r requirements.txt`
3. Khởi chạy server: `uvicorn app.main:app --reload`

### 2. Frontend

1. Di chuyển vào thư mục `fe_todoapp`: `cd fe_todoapp`
2. Cài đặt thư viện: `flutter pub get`
3. Chạy ứng dụng: `flutter run`

---

*Dự án phát triển bởi [sirya] - Đồ án  chuyên ngành khoa học máy tính.*.

---


