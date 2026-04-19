import 'package:flutter/material.dart';

class AiPage extends StatelessWidget {
  const AiPage({super.key});

  // --- PALETTE MÀU ---
  final Color primaryColor = const Color(0xFF4647D3);
  final Color primaryLight = const Color(0xFF9396FF);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceColor = Colors.white;
  final Color tertiaryColor = const Color(0xFF815100);
  final Color errorColor = const Color(0xFFB41340);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // 1. TOP APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/150'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Digital Curator',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF64748B)),
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
            const SizedBox(height: 20),

            // 2. HEADER SECTION
            _buildHeader(),

            const SizedBox(height: 32),

            // 3. AI FEED (INSIGHT CARDS)
            _buildInsightCard(
              context,
              title: "Bạn có 2 task quan trọng vào buổi chiều",
              desc: "Hãy hoàn thành Task A sớm để tránh áp lực vào khung giờ cao điểm lúc 15:00.",
              label: "TỐI ƯU LỊCH TRÌNH",
              icon: Icons.auto_awesome,
              accentColor: primaryColor,
              useGradient: true,
              buttons: [
                _buildActionButton("Áp dụng", primaryColor, isPrimary: true),
                _buildActionButton("Bỏ qua", Colors.grey[200]!, textColor: Colors.black87),
              ],
            ),

            const SizedBox(height: 16),

            _buildInsightCard(
              context,
              title: "Phong độ tuyệt vời!",
              desc: "Bạn đang duy trì thói quen 'Chạy bộ' rất tốt, hãy tiếp tục phát huy để đạt chuỗi 7 ngày!",
              label: "THÓI QUEN",
              icon: Icons.repeat,
              accentColor: tertiaryColor,
              buttons: [
                _buildActionButton("Xem chi tiết", primaryColor, isGlow: true),
              ],
            ),

            const SizedBox(height: 16),

            _buildInsightCard(
              context,
              title: "Phát hiện khối lượng công việc lớn",
              desc: "Task 'Đồ án' có khối lượng lớn, AI gợi ý bạn chia nhỏ thành các subtasks để dễ dàng quản lý.",
              label: "CẢNH BÁO",
              icon: Icons.warning,
              accentColor: errorColor,
              extraWidget: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_tree, color: primaryColor, size: 18),
                    const SizedBox(width: 10),
                    const Text("AI đề xuất: 4 bước thực hiện nhanh",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              buttons: [
                _buildActionButton("Chia nhỏ ngay", primaryColor, isPrimary: true),
                _buildActionButton("Xem sau", Colors.grey[200]!, textColor: Colors.black87),
              ],
            ),

            // 4. DECORATIVE ENDING
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.cloud_outlined, color: Colors.lightBlue, size: 48),
                    SizedBox(height: 8),
                    Text("Bạn đã xem hết các gợi ý mới nhất.",
                        style: TextStyle(color: Colors.grey, fontSize: 12, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // 5. BOTTOM NAVIGATION BAR
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("TRỢ LÝ AI",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: primaryColor)),
        const SizedBox(height: 8),
        const Text("Gợi ý dành cho bạn Hôm nay",
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1, height: 1.1)),
        const SizedBox(height: 16),
        const Text(
          "Dựa trên thói quen và lịch trình hiện tại, tôi đã tối ưu hóa các đề xuất để giúp ngày của bạn trôi chảy hơn.",
          style: TextStyle(color: Colors.black54, fontSize: 14, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildInsightCard(
      BuildContext context, {
        required String title,
        required String desc,
        required String label,
        required IconData icon,
        required Color accentColor,
        bool useGradient = false,
        Widget? extraWidget,
        required List<Widget> buttons,
      }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // AI Glow vertical bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  gradient: useGradient
                      ? LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [primaryColor, primaryLight])
                      : null,
                  color: useGradient ? null : accentColor,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(color: accentColor.withOpacity(0.1), shape: BoxShape.circle),
                                child: Icon(icon, color: accentColor, size: 16),
                              ),
                              const SizedBox(width: 10),
                              Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                            ],
                          ),
                          if (useGradient) Icon(Icons.auto_awesome, color: primaryLight.withOpacity(0.5), size: 18),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                      const SizedBox(height: 6),
                      Text(desc, style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.4)),
                      if (extraWidget != null) ...[const SizedBox(height: 16), extraWidget],
                      const SizedBox(height: 20),
                      Row(children: buttons.map((b) => Expanded(child: Padding(padding: const EdgeInsets.only(right: 8), child: b))).toList()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, {bool isPrimary = false, bool isGlow = false, Color textColor = Colors.white}) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: isGlow ? null : color,
        gradient: isGlow ? LinearGradient(colors: [primaryColor, primaryLight]) : null,
      ),
      child: Center(
        child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 15, bottom: 35),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(45)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home_outlined, "Home", false, route: '/dashboard'),
          _buildNavItem(context, Icons.check_circle_outline, "Tasks", false, route: '/tasks'),
          _buildNavItem(context, Icons.repeat, "Habits", false, route: '/habits'),
          _buildNavItem(context, Icons.auto_awesome, "AI", true, route: '/ai'),
          _buildNavItem(context, Icons.person_outline, "Profile", false,route: '/profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, {String? route}) {
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