// lib/data/services/report_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants.dart';

class ReportService {
  Future<Map<String, dynamic>?> getProductivityReport(int userId) async {
    try {
      // Đầu băm lắp ráp URL chuẩn
      final url = Uri.parse('${AppConfig.baseUrl}/auth/productivity-report/$userId');

      final response = await http.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        return decodedData['data']; // Trả về cục data bên trong
      }
      return null;
    } catch (e) {
      print("Lỗi ReportService: $e");
      return null;
    }
  }
}