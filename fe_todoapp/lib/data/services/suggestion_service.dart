import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fe_todoapp/core/constants.dart';

class SuggestionService {
  Future<Map<String, String>> getSuggestion(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/ai/suggestions/$userId'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return {
          "title": data["title"] ?? "Gợi ý từ Curator",
          "message": data["message"] ?? "Bạn đang làm rất tốt!"
        };
      }
    } catch (e) {
      print("Lỗi tải gợi ý: $e");
    }
    // Trả về mặc định nếu lỗi hoặc rớt mạng
    return {
      "title": "Chưa có gợi ý ✨",
      "message": "Bạn đang làm rất tốt, hãy tiếp tục phát huy nhé!"
    };
  }
}