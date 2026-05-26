import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fe_todoapp/core/constants.dart';
import 'package:fe_todoapp/data/models/user_model.dart';

class AuthService {
  static const Duration timeout = Duration(seconds: 10);

  // 1. ĐĂNG KÝ (Thuần Backend)
  Future<Map<String, dynamic>> register(UserModel user) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      ).timeout(timeout);

      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      return {
        'status': response.statusCode,
        'body': responseBody,
      };
    } catch (e) {
      return {
        'status': 500,
        'body': {'detail': 'Lỗi kết nối: $e'},
      };
    }
  }

  // 2. ĐĂNG NHẬP (Thuần Backend)
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Trích xuất ID từ Backend trả về
        int? extractedId = data['id'] ?? data['user_id'];
        if (extractedId == null && data['user'] != null && data['user'] is Map) {
          extractedId = data['user']['id'];
        }

        return {
          'success': true,
          'message': 'Đăng nhập thành công',
          'user': data,
          'id': extractedId,
        };
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Sai email hoặc mật khẩu'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối server: $e'};
    }
  }

  // 3. CẬP NHẬT THÔNG TIN
  Future<Map<String, dynamic>> updateProfile(int userId, Map<String, dynamic> updateData) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/auth/update-profile/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updateData),
      ).timeout(timeout);

      return {
        'status': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      return {
        'status': 500,
        'message': 'Không thể kết nối đến server. Kiểm tra mạng hoặc IP!',
      };
    }
  }

  // 4. ĐỔI MẬT KHẨU
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