// 1. Tạo class SubTaskModel mới
class SubTaskModel {
  final int id;
  final String title;
  bool isCompleted; // Để không dùng final, vì ta sẽ click thay đổi trạng thái này

  SubTaskModel({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory SubTaskModel.fromJson(Map<String, dynamic> json) {
    return SubTaskModel(
      id: json['id'],
      title: json['title'],
      isCompleted: json['is_completed'] ?? false,
    );
  }
}

// 2. Cập nhật class TaskModel hiện tại của bạn
class TaskModel {
  final int id;
  final String title;
  // ... (các thuộc tính cũ giữ nguyên)

  // Thêm dòng này để chứa danh sách việc con
  final List<SubTaskModel> subtasks;

  TaskModel({
    required this.id,
    required this.title,
    // ...
    this.subtasks = const [], // Mặc định là mảng rỗng
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'],
      title: json['title'],
      // ... (parse các thuộc tính cũ) ...

      // Bóc mảng subtasks từ JSON ra
      subtasks: json['subtasks'] != null
          ? (json['subtasks'] as List).map((i) => SubTaskModel.fromJson(i)).toList()
          : [],
    );
  }
}