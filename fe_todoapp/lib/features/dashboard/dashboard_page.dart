import 'package:flutter/material.dart';
import 'quick_create_sheet.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  // --- PALETTE MÀU ---
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceColor = Colors.white;
  final Color errorColor = const Color(0xFFB41340);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // 1. TOP APP BAR
      appBar: AppBar(
        backgroundColor: bgColor.withOpacity(0.8),
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/150'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Digital Curator',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Color(0xFF6366F1)), // Đổi icon sang AI cho đúng bản HTML mới
            onPressed: () {
              _showQuickCreate(context); // Gọi hàm hiện bảng
            },
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              "THỨ HAI, 24 THÁNG 5",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: primaryColor,
              ),
            ),
            const Text(
              "Xin chào, Tuấn!",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 24),

            // 2. BENTO GRID
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 180,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 85,
                              height: 85,
                              child: CircularProgressIndicator(
                                value: 0.65,
                                strokeWidth: 8,
                                backgroundColor: const Color(0xFFEEF1F3),
                                valueColor: AlwaysStoppedAnimation(primaryColor),
                              ),
                            ),
                            const Text(
                              "65%",
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text("Hoàn thành", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      _buildStatBox("Tổng công việc", "8 Tasks", Icons.assignment, primaryColor),
                      const SizedBox(height: 12),
                      _buildStatBox("Quá hạn", "2 Tasks", Icons.warning, errorColor),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. AI INSIGHT
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surfaceColor.withOpacity(0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border(left: BorderSide(color: primaryColor, width: 4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, color: primaryColor, size: 22),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("GỢI Ý AI", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4647D3))),
                        SizedBox(height: 4),
                        Text(
                          "Bạn nên giải quyết Task 'Đồ án TN' ngay vì sắp đến deadline.",
                          style: TextStyle(fontSize: 14, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. PRIORITY TASKS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Công việc ưu tiên", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/tasks'),
                  child: Text(
                    "Xem tất cả",
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTaskRow("Đồ án TN - Hoàn thiện UI", "Hạn: 14:00 • Cao"),
            _buildTaskRow("Họp nhóm Sprint Review", "Hạn: 16:30 • Trung bình"),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // 5. FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showQuickCreate(context); // Gọi hàm hiện bảng trượt từ dưới lên
        },
        backgroundColor: primaryColor,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // 6. BOTTOM NAV
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 12, bottom: 32, left: 8, right: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, Icons.home, "Home", true, route: '/dashboard'),
            _buildNavItem(context, Icons.check_circle, "Tasks", false, route: '/tasks'),
            _buildNavItem(context, Icons.repeat, "Habits", false , route: '/habits'),
            _buildNavItem(context, Icons.auto_awesome, "AI", false, route: '/ai'),
            _buildNavItem(context, Icons.person, "Profile", false,route: '/profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(),
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Icon(icon, color: color, size: 22),
        ],
      ),
    );
  }

  Widget _buildTaskRow(String title, String info) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF9396FF), width: 2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(info, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, {String? route}) {
    return InkWell(
      onTap: () {
        if (route != null) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? primaryColor : Colors.grey[400], size: 26),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isActive ? primaryColor : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }// Hàm này giúp hiển thị bảng tạo nhanh trượt từ dưới lên
  void _showQuickCreate(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Để sheet cao theo nội dung
      backgroundColor: Colors.transparent, // Để lộ bo góc của Container bên trong
      barrierColor: Colors.black54, // Làm mờ nền Dashboard
      builder: (context) => const QuickCreateSheet(),
    );
  }
} // Dấu đóng ngoặc cuối cùng của Class DashboardPage
