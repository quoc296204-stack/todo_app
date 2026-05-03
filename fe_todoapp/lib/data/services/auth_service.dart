import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // Nhớ thay IP máy tính của Hiếu vào đây để máy thật gọi được
  static const String baseUrl = 'http://192.168.0.106:8000/api/auth';

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );
      return {'status': response.statusCode, 'body': jsonDecode(response.body)};
    } catch (e) {
      return {'status': 500, 'message': e.toString()};
    }
  }
  // hàm login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'), // Đường dẫn API login
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

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
}

