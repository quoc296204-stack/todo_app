import 'package:flutter/material.dart';

class HabitPage extends StatelessWidget {
  const HabitPage({super.key});

  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceLow = const Color(0xFFEEF1F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
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
            Text('Digital Curator',
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -1)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined, color: Color(0xFF64748B)), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildEditorialHeader(),
            const SizedBox(height: 32),
            _buildCalendarHeader(),
            const SizedBox(height: 16),
            _buildCalendarStrip(),
            const SizedBox(height: 32),
            _buildAIInsight(),
            const SizedBox(height: 32),
            _buildHabitItem(
              title: "Đọc sách",
              subtitle: "30p",
              streak: "5 ngày",
              icon: Icons.menu_book,
              iconColor: Colors.indigo,
              isCompleted: true,
            ),
            const SizedBox(height: 16),
            _buildHabitItem(
              title: "Uống 2L nước",
              subtitle: "Tiến trình",
              streak: "12 ngày",
              icon: Icons.water_drop,
              iconColor: Colors.lightBlue,
              isCompleted: false,
              isWater: true,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildMotivationCard()),
                const SizedBox(width: 16),
                Expanded(child: _buildDailyGoalCard()),
              ],
            ),
            const SizedBox(height: 120),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildEditorialHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("THÀNH TỰU HÔM NAY",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: primaryColor)),
        const Text("Thói quen của bạn",
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1)),
        const Text("Duy trì kỷ luật để kiến tạo tự do.", style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("THÁNG 10, 2023", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
        Icon(Icons.calendar_month, color: primaryColor, size: 20),
      ],
    );
  }

  Widget _buildCalendarStrip() {
    final days = [
      {'d': 'T2', 'n': '23'},
      {'d': 'T3', 'n': '24'},
      {'d': 'T4', 'n': '25'}, // Active
      {'d': 'T5', 'n': '26'},
      {'d': 'T6', 'n': '27'},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: days.map((day) {
          bool isActive = day['n'] == '25';
          return Container(
            width: 56, height: 80,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: isActive ? primaryColor : surfaceLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(day['d']!, style: TextStyle(color: isActive ? Colors.white70 : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(day['n']!, style: TextStyle(color: isActive ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAIInsight() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: primaryColor, width: 4)),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: primaryColor, size: 24),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              "Bạn đã hoàn thành thói quen \"Đọc sách\" 5 ngày liên tục. Hãy thử tăng lên 40 phút nhé.",
              style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitItem({required String title, required String streak, required IconData icon, required Color iconColor, required bool isCompleted, bool isWater = false, String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Row(
                  children: [
                    if (isWater)
                      Row(children: List.generate(5, (i) => Container(width: 6, height: 6, margin: const EdgeInsets.only(right: 4), decoration: BoxDecoration(shape: BoxShape.circle, color: i < 3 ? Colors.lightBlue : Colors.lightBlue.withOpacity(0.2)))))
                    else
                      Text(subtitle ?? "", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    const SizedBox(width: 12),
                    Icon(Icons.local_fire_department, size: 14, color: primaryColor),
                    Text(streak, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor)),
                  ],
                ),
              ],
            ),
          ),
          Icon(isCompleted ? Icons.check_circle : Icons.radio_button_unchecked, color: isCompleted ? primaryColor : Colors.grey[300], size: 32),
        ],
      ),
    );
  }

  Widget _buildMotivationCard() {
    return Container(
      height: 160, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(20)),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Động lực hôm nay", style: TextStyle(color: Colors.white70, fontSize: 10)),
          SizedBox(height: 4),
          Text("\"Kỷ luật là cầu nối giữa mục tiêu và thành tựu.\"", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildDailyGoalCard() {
    return Container(
      height: 160, padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(alignment: Alignment.center, children: [
            SizedBox(width: 56, height: 56, child: CircularProgressIndicator(value: 0.75, strokeWidth: 4, backgroundColor: surfaceLow, valueColor: AlwaysStoppedAnimation(primaryColor))),
            const Text("75%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
          const SizedBox(height: 12),
          const Text("MỤC TIÊU NGÀY", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
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
          _buildNavItem(context, Icons.home_outlined, "Home", false, route: '/dashboard'),
          _buildNavItem(context, Icons.check_circle_outline, "Tasks", false, route: '/tasks'),
          _buildNavItem(context, Icons.repeat, "Habits", true, route: '/habits'),
          _buildNavItem(context, Icons.auto_awesome_outlined, "AI", false,route: '/ai'),
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