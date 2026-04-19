import 'package:flutter/material.dart';

class TaskPage extends StatelessWidget {
  const TaskPage({super.key});

  // --- PALETTE MÀU (Đồng bộ với Dashboard) ---
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceLow = const Color(0xFFEEF1F3);
  final Color errorColor = const Color(0xFFB41340);
  final Color secondaryColor = const Color(0xFF4650B9);

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
                letterSpacing: -0.5,
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
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // 2. AI INSIGHT CARD
            _buildAIInsightCard(),

            const SizedBox(height: 24),

            // 3. SEARCH BAR
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: surfaceLow,
                hintText: "Tìm kiếm công việc...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),

            const SizedBox(height: 16),

            // 4. FILTERS
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildFilterChip("Tất cả", true),
                  _buildFilterChip("Hôm nay", false),
                  _buildFilterChip("Sắp đến hạn", false),
                  _buildFilterChip("Quá hạn", false),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 5. TASK LIST HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Danh sách",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
                    Text("8 công việc đang chờ",
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
                Text("SẮP XẾP: MỚI NHẤT",
                    style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ],
            ),

            const SizedBox(height: 20),

            // 6. TASK ITEMS
            _buildTaskItem(
              title: "Hoàn thành báo cáo",
              time: "Hạn: 15:30, Hôm qua",
              tag: "QUÁ HẠN",
              priority: "HIGH PRIORITY",
              tagColor: errorColor,
            ),
            _buildTaskItem(
              title: "Chuẩn bị nội dung Workshop",
              time: "Hạn: 09:00, Ngày mai",
              tag: "SẮP ĐẾN",
              priority: "MEDIUM",
              tagColor: secondaryColor,
            ),
            _buildTaskItem(
              title: "Gửi email cho khách hàng",
              time: "Hạn: 17:00, Hôm nay",
              tag: "HÔM NAY",
              priority: "LOW",
              tagColor: secondaryColor,
            ),

            // 7. IMAGE ASSET BREAK
            _buildImageBreak(),

            _buildTaskItem(
              title: "Thiết kế Mockup Phase 2",
              time: "Hạn: 12 Th8",
              tag: "TUẦN TỚI",
              priority: "HIGH PRIORITY",
              tagColor: secondaryColor,
            ),

            const SizedBox(height: 120),
          ],
        ),
      ),

      // 8. FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Chuyển sang trang chi tiết khi nhấn nút +
          Navigator.pushNamed(context, '/task_detail');
        },
        backgroundColor: primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),

      // 9. BOTTOM NAV
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 15, bottom: 35, left: 8, right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(45)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, Icons.home_outlined, "Home", false, route: '/dashboard'),
            _buildNavItem(context, Icons.check_circle, "Tasks", true, route: '/tasks'),
            _buildNavItem(context, Icons.repeat, "Habits", false, route: '/habits'),
            _buildNavItem(context, Icons.auto_awesome_outlined, "AI", false,route: '/ai'),
            _buildNavItem(context, Icons.person_outline, "Profile", false,route: '/profile'),
          ],
        ),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildAIInsightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4, height: 40,
            decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("AI INSIGHT", style: TextStyle(color: primaryColor, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 6),
                const Text(
                  "You have 3 tasks overdue. Priority should be given to the \"Hoàn thành báo cáo\" project.",
                  style: TextStyle(fontWeight: FontWeight.w500, height: 1.4),
                ),
              ],
            ),
          ),
          Icon(Icons.auto_awesome, color: primaryColor, size: 20),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? primaryColor : surfaceLow,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildTaskItem({
    required String title,
    required String time,
    required String tag,
    required String priority,
    required Color tagColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Checkbox(
            value: false,
            onChanged: (v){},
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            activeColor: primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildSmallTag(tag, tagColor.withOpacity(0.1), tagColor),
                    const SizedBox(width: 6),
                    _buildSmallTag(priority, surfaceLow, Colors.grey[700]!),
                  ],
                ),
                const SizedBox(height: 8),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTag(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: textCol, fontSize: 9, fontWeight: FontWeight.w900)),
    );
  }

  Widget _buildImageBreak() {
    return Container(
      height: 120,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=800&q=80'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.indigo.withOpacity(0.6)]),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("WORK ENVIRONMENT", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
            Text("Focus on your productivity flow.", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, {String? route}) {
    return InkWell(
      onTap: () {
        if (route != null) {
          // Sử dụng pushReplacementNamed nếu không muốn chồng quá nhiều màn hình vào stack
          Navigator.pushNamed(context, route);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? primaryColor : Colors.grey[400], size: 28),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? primaryColor : Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}