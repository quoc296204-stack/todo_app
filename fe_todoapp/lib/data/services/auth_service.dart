import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fe_todoapp/core/constants.dart';

class AuthService {
  static const Duration timeout = Duration(seconds: 10);
  // Nhớ thay IP máy tính của Hiếu vào đây để máy thật gọi được
  final String url = "${AppConfig.baseUrl}/auth/login";

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      ).timeout(timeout);
      return {'status': response.statusCode, 'body': jsonDecode(response.body)};
    } catch (e) {
      return {'status': 500, 'message': e.toString()};
    }
  }
  // hàm login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/login'), // Đường dẫn API login
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Đăng nhập thành công', 'user': data};
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Sai email hoặc mật khẩu'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối server: $e'};
    }
  }
  // hàm update thông tin
  Future<Map<String, dynamic>> updateProfile(int userId, Map<String, dynamic> updateData) async {
    try {
      // Đảm bảo baseUrl của bạn là http://192.168.0.106:8000/api/auth
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/auth/update-profile/$userId'),
        headers: {
          'Content-Type': 'application/json',
          // Nếu sau này bạn có dùng Token, hãy thêm nó vào header ở đây
        },
        body: jsonEncode(updateData),
      ).timeout(timeout);

      // Trả về dữ liệu để UI xử lý tiếp
      return {
        'status': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      print("Lỗi khi gọi API updateProfile: $e");
      return {
        'status': 500,
        'message': 'Không thể kết nối đến server. Kiểm tra mạng hoặc IP!',
      };
    }
  }
  Future<Map<String, dynamic>> changePassword(int userId, String oldPwd, String newPwd) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/auth/change-password/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'old_password': oldPwd,
          'new_password': newPwd,
        }),
      ).timeout(timeout);
      return {'status': response.statusCode, 'body': jsonDecode(response.body)};
    } catch (e) {
      return {'status': 500, 'message': 'Lỗi kết nối'};
    }
  }
}

