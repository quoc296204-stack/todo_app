import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/report_service.dart';

class ProductivityReportPage extends StatefulWidget {
  const ProductivityReportPage({super.key});

  @override
  State<ProductivityReportPage> createState() => _ProductivityReportPageState();
}

class _ProductivityReportPageState extends State<ProductivityReportPage> {
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);

  late Future<Map<String, dynamic>?> _reportFuture;
  final ReportService _reportService = ReportService();

  @override
  void initState() {
    super.initState();
    _reportFuture = _initReportData();
  }

  Future<Map<String, dynamic>?> _initReportData() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUserId = prefs.get('userId');

    if (rawUserId == null) return null;
    final userId = int.parse(rawUserId.toString());

    return _reportService.getProductivityReport(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return const Center(child: Text("Không thể tải báo cáo. Vui lòng thử lại!"));
          }

          final data = snapshot.data!;
// Thêm ngoặc đơn và dấu hỏi chấm (?) vào Map<String, dynamic>?
          final taskChartData = (data['chart_data'] as Map<String, dynamic>?) ?? {};
          final habitChartData = (data['habit_chart_data'] as Map<String, dynamic>?) ?? {};

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _reportFuture = _initReportData();
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildSummaryCards(data),
                  const SizedBox(height: 32),

                  // 1. Biểu đồ cột hoàn thành CÔNG VIỆC có trục XY
                  _buildXYBarChart(
                    title: "Công việc hoàn thành",
                    subtitle: "Thống kê 7 ngày gần nhất",
                    chartData: taskChartData,
                    barColor: primaryColor,
                    showDetailAction: true,
                  ),
                  const SizedBox(height: 32),

                  // 2. MỚI: Biểu đồ cột hoàn thành THÓI QUEN có trục XY
                  _buildXYBarChart(
                    title: "Thói quen duy trì",
                    subtitle: "Thống kê tần suất tuần này",
                    chartData: habitChartData,
                    barColor: const Color(0xFF9A6E24), // Màu vàng/nâu thói quen
                    showDetailAction: false,
                  ),
                  const SizedBox(height: 32),

                  // 3. Khối 2 biểu đồ tròn tiến độ
                  _buildCircularChartsSection(data),
                  const SizedBox(height: 20),

                  // 4. MỚI: Ô thông tin số liệu tổng quan tháng hiện tại
                  _buildMonthlyStatsCard(data),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

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
                Text("${data['growth_rate'] ?? 0}%", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ),
      ],
    );
  }

// HÀM DÙNG CHUNG: Vẽ biểu đồ dạng cột có trục toạ độ X/Y chuẩn chỉnh, MỐC Y LINH HOẠT
  Widget _buildXYBarChart({
    required String title,
    required String subtitle,
    required Map<String, dynamic> chartData,
    required Color barColor,
    required bool showDetailAction,
  }) {
    // 1. Tìm giá trị lớn nhất trong dữ liệu
    double maxVal = 0;
    String maxDay = "";
    chartData.forEach((key, value) {
      if ((value as num).toDouble() > maxVal) {
        maxVal = value.toDouble();
        maxDay = key;
      }
    });

    // 2. Tính toán trục Y động:
    // Nếu số task ít hơn 20, lấy mốc trần là 20.
    // Nếu lớn hơn 20, tự động làm tròn lên số chia hết cho 4 để chia 5 mốc vạch cho đẹp.
    int topY = maxVal <= 20 ? 20 : ((maxVal / 4).ceil() * 4);

    // Tính 5 mốc hiển thị trên trục Y
    int y4 = topY;
    int y3 = (topY * 0.75).round();
    int y2 = (topY * 0.5).round();
    int y1 = (topY * 0.25).round();
    int y0 = 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            if (showDetailAction)
              Text("CHI TIẾT", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          height: 220,
          padding: const EdgeInsets.only(top: 20, bottom: 12, left: 12, right: 16),
          decoration: BoxDecoration(color: const Color(0xFFEDF1F5), borderRadius: BorderRadius.circular(24)),
          child: Row(
            children: [
              // Trục Y hiển thị mốc định lượng CHẠY ĐỘNG (20, 15, 10, 5, 0)
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("$y4", style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text("$y3", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  Text("$y2", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  Text("$y1", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  Text("$y0", style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16), // Chừa khoảng trống tương đương nhãn trục X
                ],
              ),
              const SizedBox(width: 10),

              // Khu vực chứa Đồ thị (Bao gồm trục kẻ dọc ngang và Cột)
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        // Vẽ viền Trục X và Trục Y bằng Border phẳng
                        decoration: const BoxDecoration(
                          border: Border(
                            left: BorderSide(color: Colors.grey, width: 1.5),
                            bottom: BorderSide(color: Colors.grey, width: 1.5),
                          ),
                        ),
                        child: Row(
                          children: chartData.entries.map((entry) {
                            double value = (entry.value as num).toDouble();

                            // 3. SỬA ĐỔI TỶ LỆ CỘT: Chia theo topY thay vì 100
                            double heightFactor = (value / topY).clamp(0.0, 1.0);
                            bool isActive = entry.key == maxDay && maxVal > 0;

                            return Expanded(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: FractionallySizedBox(
                                  heightFactor: heightFactor,
                                  child: Container(
                                    width: 20, // Độ rộng cột cân đối
                                    decoration: BoxDecoration(
                                      color: isActive ? barColor : barColor.withOpacity(0.3),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(5),
                                        topRight: Radius.circular(5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Trục X: Hiển thị nhãn ngày tháng (T2, T3... CN)
                    Row(
                      children: chartData.keys.map((label) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircularChartsSection(Map<String, dynamic> data) {
    final habitRate = data['habit_rate'] ?? 0;
    double habitValue = (habitRate as num).toDouble() / 100;

    final monthlyTaskRate = data['monthly_task_rate'] ?? 0;
    double taskValue = (monthlyTaskRate as num).toDouble() / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tiến độ tháng này", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCircularChartCard(
                title: "Thói quen",
                subtitle: "Tỷ lệ duy trì tuần",
                percent: habitValue,
                centerText: "$habitRate%",
                progressColor: const Color(0xFF9A6E24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildCircularChartCard(
                title: "Công việc",
                subtitle: "Tỷ lệ tiến độ tháng",
                percent: taskValue,
                centerText: "$monthlyTaskRate%",
                progressColor: primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCircularChartCard({
    required String title,
    required String subtitle,
    required double percent,
    required String centerText,
    required Color progressColor,
  }) {
    return Container(
      height: 175,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            width: 70,
            height: 70,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 7,
                  backgroundColor: Colors.grey[200],
                  color: progressColor,
                ),
                Center(
                  child: Text(centerText, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11), textAlign: TextAlign.center),
        ],
      ),
    );
  }

// Ô THÔNG TIN MỚI: Hiển thị thống kê chi tiết số lượng công việc của tháng hiện tại
  Widget _buildMonthlyStatsCard(Map<String, dynamic> data) {
    final currentMonth = data['current_month']?.toString() ?? "tháng này";
    final totalTasks = data['monthly_total_tasks'] ?? 0;
    final completedTasks = data['monthly_task_completed'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.assignment_turned_in_rounded, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                "Số liệu tổng quan $currentMonth",
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Cột 1: Tổng công việc
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Tổng số công việc", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 6),
                    // SỬA LỖI Ở ĐÂY: Đổi FontWeight.black thành w900, Colors.blackDE thành Colors.black87
                    Text(
                      "$totalTasks",
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              // Vạch kẻ ngăn cách nhỏ ở giữa
              Container(width: 1.5, height: 45, color: Colors.grey[200]),
              const SizedBox(width: 20),
              // Cột 2: Đã hoàn thành
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Đã hoàn thành", style: TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 6),
                    // SỬA LỖI Ở ĐÂY: Đổi FontWeight.black thành w900
                    Text(
                      "$completedTasks",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: primaryColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {},
      ),
    );
  }
}