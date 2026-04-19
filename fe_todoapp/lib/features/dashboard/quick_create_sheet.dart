import 'package:flutter/material.dart';

class QuickCreateSheet extends StatelessWidget {
  const QuickCreateSheet({super.key});

  // --- PALETTE MÀU ---
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceLowest = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 40),
      decoration: BoxDecoration(
        color: surfaceLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Sheet tự co giãn theo nội dung
        children: [
          // 1. THANH KÉO (DRAG HANDLE)
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // 2. HEADER
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text("Tạo nhanh", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                SizedBox(height: 4),
                Text("Chọn nội dung bạn muốn thêm", style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. ACTION GRID (2x2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.count(
              shrinkWrap: true, // Quan trọng: Để Grid nằm gọn trong Column
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1, // Chỉnh tỉ lệ ô vuông
              children: [
                _buildCreateItem(
                  context,
                  icon: Icons.check_circle,
                  title: "Thêm công việc",
                  desc: "Tạo task mới để quản lý tiến độ",
                  route: '/task_detail',
                ),
                _buildCreateItem(
                  context,
                  icon: Icons.repeat,
                  title: "Thêm thói quen",
                  desc: "Thiết lập thói quen hằng ngày",
                  route: '/habits',
                ),
                _buildCreateItem(
                  context,
                  icon: Icons.calendar_today,
                  title: "Thêm lịch",
                  desc: "Lên kế hoạch cho thời gian biểu",
                ),
                _buildCreateItem(
                  context,
                  icon: Icons.notifications,
                  title: "Thêm nhắc nhở",
                  desc: "Tạo thông báo nhắc việc",
                  route: '/notification_settings',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER CHO TỪNG Ô ---
  Widget _buildCreateItem(BuildContext context, {required IconData icon, required String title, required String desc, String? route}) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Đóng sheet trước
        if (route != null) Navigator.pushNamed(context, route); // Chuyển trang sau
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.2)),
            const SizedBox(height: 4),
            Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 10, height: 1.3)),
          ],
        ),
      ),
    );
  }
}