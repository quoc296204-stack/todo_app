import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fe_todoapp/core/constants.dart';
import 'package:flutter/material.dart';

class TaskService {
  static const Duration timeout = Duration(seconds: 10);

  // 1. LẤY DANH SÁCH CÔNG VIỆC CHUẨN BACKEND (TÌM KIẾM / LỌC / SẮP XẾP)
  Future<List<dynamic>> getAllTasks(
      int userId, {
        String search = "",
        String filterBy = "all",
        String sortBy = "default",
        int? categoryId,
      }) async {
    try {
      final encodedSearch = Uri.encodeComponent(search);
      final url = '${AppConfig.baseUrl}/tasks/all/$userId?search=$encodedSearch&filter_by=$filterBy&sort_by=$sortBy';

      final response = await http.get(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return [];
    } catch (e) {
      debugPrint("Lỗi getAllTasks Service: $e");
      return [];
    }
  }

  // 2. ĐẢO TRẠNG THÁI HOÀN THÀNH CÔNG VIỆC (TOGGLE)
  Future<Map<String, dynamic>> toggleTaskComplete(int taskId) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/tasks/toggle/$taskId'),
        headers: {"Content-Type": "application/json"},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      return {'status': response.statusCode, 'message': 'Lỗi cập nhật từ hệ thống'};
    } catch (e) {
      return {'status': 500, 'message': e.toString()};
    }
  }

  // 3. TẠO MỚI CÔNG VIỆC
  Future<Map<String, dynamic>> createTask(int userId, Map<String, dynamic> taskData) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/tasks/create/$userId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(taskData),
      ).timeout(timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          "status": response.statusCode,
          "body": jsonDecode(utf8.decode(response.bodyBytes)),
        };
      } else {
        return {
          "status": response.statusCode,
          "body": {"detail": "Lỗi server: ${response.statusCode}"}
        };
      }
    } catch (e) {
      return {"status": 500, "message": "Lỗi kết nối server: $e"};
    }
  }

  // 4. LẤY DANH SÁCH DANH MỤC
  Future<Map<String, dynamic>> getCategories(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/tasks/categories/$userId'),
        headers: {"Content-Type": "application/json"},
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return {
          "status": 200,
          "data": jsonDecode(utf8.decode(response.bodyBytes))
        };
      }
      return {"status": response.statusCode, "error": "Lỗi lấy danh mục"};
    } catch (e) {
      return {"status": 500, "error": "Lỗi kết nối: $e"};
    }
  }

  // 5. THÊM DANH MỤC MỚI
  Future<Map<String, dynamic>> addCategory(int userId, String name) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/tasks/categories'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"user_id": userId, "name": name}),
      ).timeout(timeout);

      return {"status": response.statusCode, "success": response.statusCode == 201};
    } catch (e) {
      return {"status": 500, "success": false};
    }
  }

  // 6. CẬP NHẬT CÔNG VIỆC
  Future<Map<String, dynamic>> updateTask(int taskId, Map<String, dynamic> taskData) async {
    try {
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/tasks/update/$taskId'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(taskData),
      ).timeout(timeout);
      return {"status": response.statusCode, "body": jsonDecode(utf8.decode(response.bodyBytes))};
    } catch (e) {
      return {"status": 500, "body": {"detail": e.toString()}};
    }
  }

  // 7. XÓA CÔNG VIỆC
  Future<bool> deleteTask(int taskId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/tasks/delete/$taskId'),
        headers: {"Content-Type": "application/json"},
      ).timeout(timeout);

      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi khi xóa: $e");
      return false;
    }
  }

  // 8. XÓA DANH MỤC
  Future<Map<String, dynamic>> deleteCategory(int catId) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppConfig.baseUrl}/tasks/categories/$catId'),
        headers: {"Content-Type": "application/json"},
      ).timeout(timeout);

      return {
        "status": response.statusCode,
        "success": response.statusCode == 200,
      };
    } catch (e) {
      return {"status": 500, "success": false, "error": "Lỗi: $e"};
    }
  }

  // ==========================================
  // 9. (MỚI) ĐẢO TRẠNG THÁI VIỆC CON (SUBTASK)
  // ==========================================
  Future<bool> toggleSubTaskComplete(int subtaskId) async {
    try {
      // Tạm thời gọi API này (Bạn có thể bổ sung route này ở Backend sau)
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/tasks/subtask/toggle/$subtaskId'),
        headers: {"Content-Type": "application/json"},
      ).timeout(timeout);

      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi toggle subtask: $e");
      return false;
    }
  }
}