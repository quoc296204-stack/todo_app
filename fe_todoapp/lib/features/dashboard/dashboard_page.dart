import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants.dart'; // Đường dẫn đến file constants.dart của bạn

// --- MODEL TASK ---
class Task {
  final String title;
  final String time;
  final String priority;

  Task({required this.title, required this.time, required this.priority});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] ?? '',
      time: json['time'] ?? '',
      priority: json['priority'] ?? '',
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // --- HỆ MÀU ---
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceColor = Colors.white;
  final Color textMain = const Color(0xFF2C2F31);
  final Color textSub = const Color(0xFF595C5E);
  final Color tertiaryColor = const Color(0xFF815100);

  int _selectedIndex = 0;

  // --- BIẾN DỮ LIỆU ĐỘNG ---
  String userName = "..."; // Lấy từ DB
  String avatarUrl = "";           // Lấy từ DB[cite: 3]
  List<Task> todayTasks = [];
  bool isLoadingTasks = true;

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Gọi hàm lấy thông tin user[cite: 3]
    _fetchTasksFromBackend();
  }

  // --- HÀM LẤY THÔNG TIN USER TỪ DATABASE ---
  Future<void> _loadUserData() async {
    try {
      // Thay đổi URL thành endpoint profile của bạn
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/auth/profile/1'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userName = data['full_name'] ?? "Người dùng"; // Gán tên từ DB[cite: 3]
          avatarUrl = data['avatar_url'] ?? "";        // Gán ảnh từ DB[cite: 3]
        });
      }
    } catch (e) {
      debugPrint("Lỗi lấy thông tin user: $e");
      setState(() => userName = "Hiếu"); // Giá trị dự phòng
    }
  }

  // --- HÀM LẤY TASK ---
  Future<void> _fetchTasksFromBackend() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/auth/profile/1'));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          todayTasks = data.map((item) => Task.fromJson(item)).toList();
          isLoadingTasks = false;
        });
      }
    } catch (e) {
      setState(() => isLoadingTasks = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadUserData();
          await _fetchTasksFromBackend();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _buildHeader(),
              const SizedBox(height: 32),
              _buildAIInsightCard(),
              const SizedBox(height: 32),
              _buildPriorityTasksSection(context),
              const SizedBox(height: 32),
              _buildHabitsSection(),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
      extendBody: true,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: bgColor.withOpacity(0.8),
      elevation: 0,
      centerTitle: false,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            // Hiển thị ảnh từ database, nếu trống thì dùng ảnh mặc định
            backgroundImage: avatarUrl.isNotEmpty
                ? NetworkImage(avatarUrl)
                : const NetworkImage('https://www.w3schools.com/howto/img_avatar.png'),
          ),
          const SizedBox(width: 12),
          // Hiển thị Tên User động trên AppBar[cite: 3]
          Text(userName, style: TextStyle(color: textMain, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none_outlined, color: textSub),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        // Hiển thị lời chào với tên lấy từ Database[cite: 3]
        Text('Xin chào, $userName!', style: TextStyle(color: textMain, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1)),
      ],
    );
  }

  // ... Các Widget khác (AI Insight, Task Section, Habits) giữ nguyên như cũ ...
  Widget _buildAIInsightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20, offset: const Offset(0, 10)),
        ],
        border: Border(left: BorderSide(color: primaryColor, width: 6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: primaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GỢI Ý TỪ AI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: 1)),
                const SizedBox(height: 6),
                Text(
                  "Dựa trên lịch trình, bạn nên hoàn thành 'Đồ án TN' trước 14:00 hôm nay.",
                  style: TextStyle(fontSize: 15, color: textMain, height: 1.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityTasksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Công việc hôm nay', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textMain)),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/tasks'),
              child: Text('TẤT CẢ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryColor)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isLoadingTasks)
          const Center(child: CircularProgressIndicator())
        else if (todayTasks.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("Hôm nay bạn không có công việc nào."),
          )
        else
          ...todayTasks.map((task) => _buildTaskTile(task.title, '${task.time} • ${task.priority}')),
      ],
    );
  }

  Widget _buildTaskTile(String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withOpacity(0.2), width: 2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textMain, fontSize: 15)),
                Text(subtitle, style: TextStyle(fontSize: 12, color: textSub)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: textSub.withOpacity(0.5), size: 20),
        ],
      ),
    );
  }

  Widget _buildHabitsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thói quen', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textMain)),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildHabitCard('Uống nước', Icons.water_drop, Colors.blue),
              _buildHabitCard('Đọc sách', Icons.menu_book, tertiaryColor),
              _buildHabitCard('Tập gym', Icons.fitness_center, Colors.green),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHabitCard(String title, IconData icon, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: textMain, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 32),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_max_outlined, 'Home', '/dashboard'),
          _buildNavItem(1, Icons.check_circle, 'Tasks', '/tasks'),
          _buildNavItem(2, Icons.repeat, 'Habits', '/habits'),
          _buildNavItem(3, Icons.auto_awesome_outlined, 'AI', '/ai'),
          _buildNavItem(4, Icons.person_outline, 'Profile', '/profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, String route) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (route != '/dashboard') Navigator.pushNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? primaryColor : textSub, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isSelected ? primaryColor : textSub, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}