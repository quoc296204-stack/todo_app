import 'package:flutter/material.dart';

class ProductivityReportPage extends StatelessWidget {
  const ProductivityReportPage({super.key});

  // --- PALETTE MÀU ---
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceColor = Colors.white;
  final Color tertiaryColor = const Color(0xFF815100);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // 1. TOP APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("DIGITAL CURATOR",
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
            Text("Báo cáo năng suất",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: primaryColor)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: primaryColor),
            onPressed: () {},
          )
        ],
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // 2. SUMMARY BENTO GRID
            Row(
              children: [
                Expanded(child: _buildKeyStatCard("Tỷ lệ hoàn thành", "85%", "+12% vs t.trước", Icons.analytics)),
                const SizedBox(width: 12),
                Expanded(child: _buildKeyStatCard("Tăng trưởng", "10%", "Tuần này", Icons.trending_up, isGrowth: true)),
              ],
            ),

            const SizedBox(height: 32),

            // 3. BAR CHART VISUALIZATION
            _buildSectionHeader("Công việc hoàn thành", "Thống kê 7 ngày gần nhất"),
            const SizedBox(height: 16),
            _buildBarChart(),

            const SizedBox(height: 32),

            // 4. HABITS & AI INSIGHT
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildHabitProgressCircle()),
                const SizedBox(width: 16),
                Expanded(flex: 3, child: _buildAIInsightCard()),
              ],
            ),

            const SizedBox(height: 32),

            // 5. RECENT ACTIVITY
            const Text("Hoạt động tiêu biểu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 16),
            _buildActivityItem("Hôm nay", "Hoàn thành dự án UI/UX", "Vượt tiến độ 2 ngày"),
            _buildActivityItem("Thứ 3", "Họp chiến lược Quý 4", "Hoàn thành mục tiêu"),
            _buildActivityItem("Thứ 2", "Nghiên cứu thị trường", "Đã lưu trữ 12 tài liệu", opacity: 0.6),

            const SizedBox(height: 120),
          ],
        ),
      ),

      // 6. BOTTOM NAV
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildKeyStatCard(String label, String value, String trend, IconData icon, {bool isGrowth = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: primaryColor, size: 24),
              if (!isGrowth) Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(trend, style: const TextStyle(color: Colors.orange, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String sub) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        const Text("CHI TIẾT", style: TextStyle(color: Colors.indigo, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildBarChart() {
    final List<double> values = [0.4, 0.65, 0.9, 0.55, 0.75, 0.3, 0.45];
    final List<String> days = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFEEF1F3).withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
      height: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) => Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 30,
              height: 120 * values[i],
              decoration: BoxDecoration(
                color: values[i] > 0.8 ? primaryColor : primaryColor.withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              ),
            ),
            const SizedBox(height: 8),
            Text(days[i], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
        )),
      ),
    );
  }

  Widget _buildHabitProgressCircle() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          const Text("Thói quen", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(width: 80, height: 80, child: CircularProgressIndicator(value: 0.72, strokeWidth: 8, backgroundColor: bgColor, valueColor: AlwaysStoppedAnimation(tertiaryColor))),
              const Text("72%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          const Text("Duy trì", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAIInsightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: primaryColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.auto_awesome, color: primaryColor, size: 16), const SizedBox(width: 8), const Text("Gợi ý từ Curator", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF4647D3)))]),
          const SizedBox(height: 8),
          const Text("Tối ưu hóa thời gian sáng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          const Text("Bạn tập trung tốt nhất trước 10:00 sáng. Hãy tận dụng nhé!", style: TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String day, String title, String sub, {double opacity = 1.0}) {
    return Opacity(
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            SizedBox(width: 60, child: Text(day, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey))),
            Container(width: 1, height: 24, color: Colors.grey.withOpacity(0.2)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(sub, style: const TextStyle(fontSize: 11, color: Colors.grey))])),
            Icon(Icons.check_circle, color: primaryColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 15, bottom: 35),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(45))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home_outlined, "Home", false, route: '/dashboard'),
          _buildNavItem(context, Icons.check_circle_outline, "Tasks", false, route: '/tasks'),
          _buildNavItem(context, Icons.repeat, "Habits", false, route: '/habits'),
          _buildNavItem(context, Icons.auto_awesome_outlined, "AI", false, route: '/ai'),
          _buildNavItem(context, Icons.person, "Profile", true, route: '/profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, {String? route}) {
    return InkWell(
      onTap: () { if (route != null) Navigator.pushNamed(context, route); },
      child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: isActive ? primaryColor : Colors.grey[400], size: 28), const SizedBox(height: 4), Text(label, style: TextStyle(color: isActive ? primaryColor : Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold))]),
    );
  }
}