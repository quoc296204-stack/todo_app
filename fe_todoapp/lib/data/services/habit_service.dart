import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fe_todoapp/core/constants.dart';


class HabitService {
  static const Duration timeout = Duration(seconds: 10);

  // 1. Lấy thói quen kèm lịch sử tick theo ngày chọn
  Future<Map<String, dynamic>> getHabitsByDate(int userId, String dateStr) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/habits/$userId?selected_date=$dateStr'),
        headers: {"Content-Type": "application/json"},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return {"status": 200, "data": jsonDecode(utf8.decode(response.bodyBytes))['data']};
      }
      return {"status": response.statusCode, "data": []};
    } catch (e) {
      return {"status": 500, "data": []};
    }
  }

  // 2. Toggle trạng thái log thói quen
  Future<Map<String, dynamic>> toggleHabit(int habitId, String dateStr) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/habits/toggle/$habitId?selected_date=$dateStr'),
        headers: {"Content-Type": "application/json"},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return {"status": response.statusCode};
    } catch (e) {
      return {"status": 500};
    }
  }

  // 3. Tạo mới thói quen
  Future<bool> createHabit(int userId, String title, String description) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/habits/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "title": title, "description": description}),
      ).timeout(timeout);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }
}