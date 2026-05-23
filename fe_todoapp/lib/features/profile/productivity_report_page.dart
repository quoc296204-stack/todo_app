import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/report_service.dart';
// import '../../../data/services/report_service.dart'; // Import service của bạn

class ProductivityReportPage extends StatefulWidget {
  const ProductivityReportPage({super.key});

  @override
  State<ProductivityReportPage> createState() => _ProductivityReportPageState();
}

// class _EditProfilePageState extends State<ProductivityReportPage> { // Giữ tên class State của bạn
class _ProductivityReportPageState extends State<ProductivityReportPage> {
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);

  // Khởi tạo service
  // final ReportService _reportService = ReportService();
  late Future<Map<String, dynamic>?> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = _initReportData();
  }

  // Hàm trung gian lấy userId từ SharedPreferences rồi gọi Service
  final ReportService _reportService = ReportService();

  Future<Map<String, dynamic>?> _initReportData() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUserId = prefs.get('userId');

    if (rawUserId == null) return null;
    final userId = int.parse(rawUserId.toString());

    // 1. GỌI API THẬT TỪ BACKEND
    return _reportService.getProductivityReport(userId);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      // DÙNG FUTUREBUILDER ĐỂ QUẢN LÝ DỮ LIỆU ĐỘNG
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _reportFuture,
        builder: (context, snapshot) {
          // 1. Trạng thái đang tải dữ liệu (Loading)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Trạng thái lỗi mạng hoặc không có dữ liệu
          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Không thể tải báo cáo. Vui lòng thử lại!"));
          }

          // 3. Đã có dữ liệu thành công -> Lấy data ra bóc tách
          final data = snapshot.data!;
          final chartData = data['chart_data'] as Map<String, dynamic> ?? {};

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _reportFuture = _initReportData(); // Luật ngầm: Pull-to-refresh force reload
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSummaryCards(data), // Truyền data vào
                  const SizedBox(height: 40),

                  _buildChartHeader(),
                  const SizedBox(height: 16),

                  _buildBarChart(chartData), // Truyền dữ liệu biểu đồ vào
                  const SizedBox(height: 24),

                  _buildBottomSection(data), // Truyền dữ liệu thói quen & AI
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- CÁC HÀM UI ĐÃ ĐƯỢC ĐỘNG HÓA DỮ LIỆU ---

  Widget _buildSummaryCards(Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.bar_chart, color: primaryColor, size: 20),
                ),
                const SizedBox(height: 16),
                const Text("Tỷ lệ hoàn thành", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                // 👉 Đã thêm ?? 0
                Text("${data['completion_rate'] ?? 0}%", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.trending_up, color: Colors.blue, size: 20),
                ),
                const SizedBox(height: 16),
                const Text("Tăng trưởng", style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                // 👉 Đã thêm ?? 0
                Text("${data['growth_rate'] ?? 0}%", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(Map<String, dynamic> chartData) {
    double maxVal = 0;
    String maxDay = "";
    chartData.forEach((key, value) {
      if ((value as num).toDouble() > maxVal) {
        maxVal = value.toDouble();
        maxDay = key;
      }
    });

    return Container(
      height: 200,
      // 1. SỬA LỖI TRÀN: Giảm padding 2 bên từ 16 xuống 8
      padding: const EdgeInsets.only(top: 24, bottom: 16, left: 8, right: 8),
      decoration: BoxDecoration(color: const Color(0xFFEDF1F5), borderRadius: BorderRadius.circular(24)),
      child: Row(
        // crossAxisAlignment: CrossAxisAlignment.end,
        children: chartData.entries.map((entry) {
          // 2. CHỐNG TRÀN TUYỆT ĐỐI: Bọc từng cột vào Expanded để nó tự chia đều không gian
          return Expanded(
            child: _buildBar(
                entry.key, // <-- TÊN CỦA CỘT (T2, T3, CN...) CHÍNH LÀ Ở ĐÂY
                (entry.value as num).toDouble(),
                entry.key == maxDay
            ),
          );
        }).toList(),
      ),
    );
  }

  // Hàm vẽ từng cột (đã tối ưu lại kích thước)
  Widget _buildBar(String label, double heightFactor, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: FractionallySizedBox(
            heightFactor: heightFactor,
            child: Container(
              // 3. SỬA LỖI TRÀN: Giảm bề ngang cột từ 32 xuống 24 để vừa với màn hình nhỏ
              width: 24,
              decoration: BoxDecoration(
                color: isActive ? primaryColor : primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // HIỂN THỊ TÊN CỘT: Dữ liệu API trả về "T2", "T3" sẽ được in ra ở dòng Text này
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildBottomSection(Map<String, dynamic> data) {
    // 👉 An toàn hóa: Nếu habit_rate bị null, mặc định là 0
    final habitRate = data['habit_rate'] ?? 0;
    double habitValue = (habitRate as num).toDouble() / 100;

    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            height: 180,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Thói quen", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: habitValue,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey[200],
                        color: const Color(0xFF9A6E24),
                      ),
                      Center(
                        // 👉 Dùng biến habitRate đã được an toàn hóa
                        child: Text("$habitRate%", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text("Duy trì", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 6,
          child: Container(
            height: 180,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: primaryColor.withOpacity(0.5), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: primaryColor, size: 16),
                    const SizedBox(width: 8),
                    Text("Gợi ý từ Curator", style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                // 👉 Đã sửa lỗi: Thêm giá trị chuỗi dự phòng nếu Title bị null
                Text(
                    data['ai_suggestion_title']?.toString() ?? "Chưa có gợi ý",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.3)
                ),
                const SizedBox(height: 4),
                // 👉 Đã sửa lỗi: Thêm giá trị chuỗi dự phòng nếu Content bị null
                Text(
                  data['ai_suggestion_content']?.toString() ?? "Bạn đang làm rất tốt, hãy tiếp tục phát huy nhé!",
                  style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),        ),
      ],
    );
  }

  // --- Các hàm UI giữ nguyên ---
  PreferredSizeWidget _buildAppBar() => AppBar(/* ... Giữ nguyên như bài trước ... */);
  Widget _buildChartHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Công việc hoàn thành", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("Thống kê 7 ngày gần nhất", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        Text("CHI TIẾT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
      ],
    );
  }
}