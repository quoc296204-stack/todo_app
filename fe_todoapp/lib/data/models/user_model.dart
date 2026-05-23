class UserModel {
  final String fullName; // Nếu backend của bạn là username, hãy đổi thành String username;
  final String email;
  final String password;
  final String confirmPassword; // <-- 1. Thêm trường này

  UserModel({
    required this.fullName,
    required this.email,
    required this.password,
    required this.confirmPassword, // <-- 2. Cập nhật constructor
  });

  Map<String, dynamic> toJson() => {
    // 3. Đảm bảo key này khớp 100% với tên biến trong Pydantic của FastAPI (username hay full_name?)
    'full_name': fullName,
    'email': email,
    'password': password,
    'confirm_password': confirmPassword, // <-- 4. Thêm key này để gửi lên Backend
  };
}