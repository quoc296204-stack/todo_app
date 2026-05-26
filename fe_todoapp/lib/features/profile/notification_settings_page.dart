import 'package:flutter/material.dart';

class NotificationSettingsPage extends StatelessWidget {
  const NotificationSettingsPage({super.key});

  // --- PALETTE MÀU ---
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceLow = const Color(0xFFEEF1F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // 1. TOP APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6366F1)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Cài đặt nhắc nhở",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFD9DDE0),
              child: Icon(Icons.person, color: Colors.white, size: 20),
            ),
          )
        ],
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // 2. HERO SECTION
            _buildHeroSection(),

            const SizedBox(height: 40),

            // 3. NOTIFICATION PREVIEW
            // _buildSectionLabel("Bản xem trước"),
            const SizedBox(height: 8),
            _buildAIPreviewCard(),

            const SizedBox(height: 40),

            // 4. SETTINGS GROUPS
            _buildSettingsGroup(
              title: "Thông báo chung",
              items: [
                _buildSwitchItem(
                  icon: Icons.notifications_paused,
                  title: "Bật/tắt toàn bộ",
                  subtitle: "Vô hiệu hóa tất cả nhắc nhở",
                  value: true,
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildSettingsGroup(
              title: "Nhắc nhở công việc",
              items: [
                _buildSwitchItem(
                  icon: Icons.event_note, // Thay thế event_upcoming
                  title: "Nhắc sắp đến hạn",
                  value: true,
                ),
                _buildTimeSelector(),
              ],
            ),

            const SizedBox(height: 24),

            _buildSettingsGroup(
              title: "Tùy chọn khác",
              items: [
                _buildSwitchItem(icon: Icons.repeat, title: "Nhắc thói quen", subtitle: "Uống nước, nghỉ ngơi...", value: true),
                _buildSimpleItem(Icons.do_not_disturb_on, "Khung giờ yên lặng", trailingText: "22:00 - 06:00"),
                _buildSimpleItem(Icons.volume_up, "Âm thanh", showChevron: true),
                _buildSwitchItem(icon: Icons.vibration, title: "Rung", value: true),
              ],
            ),

            const SizedBox(height: 40),

            // 5. SAVE BUTTON
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 4,
              ),
              child: const Text("Lưu cài đặt", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),

      // 6. BOTTOM NAVIGATION BAR
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text.toUpperCase(),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1.5)),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(Icons.notifications_active, color: primaryColor, size: 40),
        ),
        const SizedBox(height: 16),
        const Text("Cá nhân hóa thông báo", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
        const Text("Tùy chỉnh cách Digital Curator hỗ trợ bạn.",
            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildAIPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: primaryColor, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        // children: [
        //   Icon(Icons.auto_awesome, color: primaryColor, size: 20),
        //   const SizedBox(width: 16),
        //   const Expanded(
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Text("AI GỢI Ý", style: TextStyle(color: Color(0xFF4647D3), fontSize: 10, fontWeight: FontWeight.bold)),
        //         SizedBox(height: 4),
        //         Text("Bạn nên hoàn thành Đồ án TN trước 14:00 hôm nay.",
        //             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, height: 1.4)),
        //       ],
        //     ),
        //   ),
        // ],
      ),
    );
  }

  Widget _buildSettingsGroup({required String title, required List<Widget> items}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: surfaceLow.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSwitchItem({required IconData icon, required String title, String? subtitle, required bool value}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                if (subtitle != null) Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          ),
          Switch(value: value, onChanged: (v) {}, activeColor: primaryColor),
        ],
      ),
    );
  }

  Widget _buildTimeSelector() {
    final times = ["5m", "15m", "30m", "1h", "1d"];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: times.map((t) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: t == "15m" ? primaryColor : surfaceLow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(t, style: TextStyle(color: t == "15m" ? Colors.white : Colors.black87, fontSize: 11, fontWeight: FontWeight.bold)),
        )).toList(),
      ),
    );
  }

  Widget _buildSimpleItem(IconData icon, String title, {String? trailingText, bool showChevron = false}) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
          if (trailingText != null) Text(trailingText, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
          if (showChevron) const Icon(Icons.chevron_right, color: Colors.grey),
        ],
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
          _buildNavItem(context, Icons.home_outlined, "Home", route: '/dashboard'),
          _buildNavItem(context, Icons.check_circle_outline, "Tasks", route: '/tasks'),
          _buildNavItem(context, Icons.repeat, "Habits", route: '/habits'),
          _buildNavItem(context, Icons.auto_awesome_outlined, "AI", route: '/ai'),
          _buildNavItem(context, Icons.person, "Profile", isActive: true, route: '/profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, {bool isActive = false, String? route}) {
    return InkWell(
      onTap: () { if (route != null) Navigator.pushNamed(context, route); },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? primaryColor : Colors.grey[400], size: 28),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? primaryColor : Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}