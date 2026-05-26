import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fe_todoapp/core/constants.dart';

class AIApiService {
  static const Duration timeout = Duration(seconds: 15);

  /// Gửi câu nói thô ngôn ngữ tự nhiên lên hệ thống xử lý NLP Local
  Future<Map<String, dynamic>?> processNLPTask(String inputRawText, int loggedInUserId) async {
    try {
      // ✅ SỬA LỖI TRÙNG LẶP: Vì baseUrl đã có sẵn "/api" nên ở đây chỉ cần nối thêm "/ai/nlp-task"
      final url = '${AppConfig.baseUrl}/ai/nlp-task';

      print("🚀 [HttpClient AI] Gửi POST Request lên URL: $url");

      final response = await http.post(
        Uri.parse(url), // ✅ ĐÃ SỬA: Đảm bảo truyền đúng biến url vừa tạo, không dùng link auth cũ
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "text": inputRawText,
          "user_id": loggedInUserId,
        }),
      ).timeout(timeout);

      print("🚨 [HttpClient AI] Server phản hồi trạng thái: ${response.statusCode}");

      if (response.statusCode == 200) {
        // Giải mã utf8 để tránh lỗi hiển thị font tiếng Việt có dấu
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        debugPrint("❌ Lỗi Backend AI: Khởi chạy không thành công mã ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Lỗi kết nối HTTP Client AI: $e");
      return null;
    }
  }

  /// Gọi hệ thống chuyên gia phân rã kế hoạch lớn thành các subtasks
  Future<Map<String, dynamic>?> generateAISubtasks(int taskId) async {
    try {
      final url = '${AppConfig.baseUrl}/ai/subtask-generator/$taskId';
      print("🚀 [HttpClient AI] Gửi POST Phân rã lên URL: $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ).timeout(timeout);

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      } else {
        debugPrint("❌ Lỗi Subtask Generator: Mã ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("❌ Lỗi kết nối Subtask Generator: $e");
      return null;
    }
  }
}