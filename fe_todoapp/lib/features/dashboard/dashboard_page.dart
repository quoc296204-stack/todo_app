import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../data/services/task_service.dart';
import '../../../data/services/habit_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> with WidgetsBindingObserver {
  // --- HỆ MÀU & CONFIG ---
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceLow = const Color(0xFFEEF1F3);

  final TaskService _taskService = TaskService();
  final HabitService _habitService = HabitService();

  // STATE VARIABLES
  int? currentUserId;
  String userName = "bạn";
  bool isLoading = true;

  List<dynamic> todayTasks = [];
  List<dynamic> todayHabits = [];

  // BIẾN LƯU TRỮ THỜI GIAN ĐỘNG
  String _timeString = "";
  String _dateString = "";
  Timer? _timeTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initData();
    _startClock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timeTimer?.cancel();
    super.dispose();
  }

  void _startClock() {
    _updateTime();
    _timeTimer = Timer.periodic(const Duration(minutes: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    final String formattedTime = DateFormat('HH:mm').format(now);
    final String formattedDate = DateFormat('dd/MM/yyyy').format(now);

    String weekdayStr = "";
    switch (now.weekday) {
      case DateTime.monday: weekdayStr = "Thứ Hai"; break;
      case DateTime.tuesday: weekdayStr = "Thứ Ba"; break;
      case DateTime.wednesday: weekdayStr = "Thứ Tư"; break;
      case DateTime.thursday: weekdayStr = "Thứ Năm"; break;
      case DateTime.friday: weekdayStr = "Thứ Sáu"; break;
      case DateTime.saturday: weekdayStr = "Thứ Bảy"; break;
      case DateTime.sunday: weekdayStr = "Chủ Nhật"; break;
    }

    if (mounted) {
      setState(() {
        _timeString = formattedTime;
        _dateString = "$weekdayStr, $formattedDate";
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _updateTime();
      if (currentUserId != null) _loadDashboardData();
    }
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getInt('userId');
      userName = prefs.getString('userName') ?? "bạn";
    });

    if (currentUserId != null) {
      await _loadDashboardData();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadDashboardData() async {
    if (currentUserId == null || !mounted) return;
    setState(() => isLoading = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final results = await Future.wait([
        _taskService.getAllTasks(currentUserId!, filterBy: 'today'),
        _habitService.getHabitsByDate(currentUserId!, dateStr)
      ]);

      if (mounted) {
        setState(() {
          todayTasks = results[0] as List<dynamic>;
          final habitRes = results[1] as Map<String, dynamic>;
          if (habitRes['status'] == 200) {
            todayHabits = habitRes['data'] ?? [];
          }
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Lỗi tải Dashboard: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _toggleTask(int taskId) async {
    setState(() {
      for (var task in todayTasks) {
        if (task['id'] == taskId) {
          task['is_completed'] = (task['is_completed'] == 1 || task['is_completed'] == true) ? 0 : 1;
          break;
        }
      }
    });
    final res = await _taskService.toggleTaskComplete(taskId);
    if (res['status'] != 200) _loadDashboardData();
  }

  Future<void> _toggleHabit(int habitId) async {
    setState(() {
      for (var habit in todayHabits) {
        if (habit['id'] == habitId) {
          habit['is_completed'] = !(habit['is_completed'] == true);
          break;
        }
      }
    });
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final res = await _habitService.toggleHabit(habitId, dateStr);
    if (res['status'] != 200) _loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadDashboardData,
          child: currentUserId == null
              ? const Center(child: Text("Vui lòng đăng nhập"))
              : SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildSectionHeader("Công việc hôm nay", actionText: "TẤT CẢ", onAction: () => Navigator.pushReplacementNamed(context, '/tasks')),
                const SizedBox(height: 16),
                isLoading ? const Center(child: CircularProgressIndicator()) : _buildTasksList(),
                const SizedBox(height: 32),
                _buildSectionHeader("Thói quen"),
                const SizedBox(height: 16),
                isLoading ? const Center(child: CircularProgressIndicator()) : _buildHabitsList(),
                const SizedBox(height: 32),
                _buildSectionHeader("Đánh giá ngày"),
                const SizedBox(height: 16),
                isLoading ? const SizedBox() : _buildCharts(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                CircleAvatar(backgroundColor: primaryColor.withOpacity(0.2), radius: 20, child: Icon(Icons.person, color: primaryColor)),
                const SizedBox(width: 12),
                Text("Xin chào, $userName!", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
              ]),
              const SizedBox(height: 8),
              Padding(padding: const EdgeInsets.only(left: 52), child: Text("$_timeString   •   $_dateString", style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w700))),
            ],
          ),
        ),
        IconButton(icon: const Icon(Icons.notifications_none, size: 28), onPressed: () {}),
      ],
    );
  }

  Widget _buildSectionHeader(String title, {String? actionText, VoidCallback? onAction}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (actionText != null) GestureDetector(onTap: onAction, child: Text(actionText, style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold))),
      ],
    );
  }

  Widget _buildTasksList() {
    if (todayTasks.isEmpty) return const Text("Hôm nay bạn không có công việc nào.", style: TextStyle(color: Colors.grey));
    return Column(
      children: todayTasks.map((task) {
        bool isCompleted = task['is_completed'] == 1 || task['is_completed'] == true;
        return InkWell(
          onTap: () => _toggleTask(task['id']),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Icon(isCompleted ? Icons.check_circle : Icons.circle_outlined, color: isCompleted ? Colors.green : primaryColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(task['title'] ?? '', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, decoration: isCompleted ? TextDecoration.lineThrough : null, color: isCompleted ? Colors.grey : Colors.black87)),
                ),
                Text(task['deadline'] != null ? task['deadline'].toString().substring(11, 16) : '', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHabitsList() {
    if (todayHabits.isEmpty) return const Text("Hôm nay bạn chưa thiết lập thói quen.", style: TextStyle(color: Colors.grey));
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: todayHabits.map((habit) {
          bool isDone = habit['is_completed'] == true;
          return GestureDetector(
            onTap: () => _toggleHabit(habit['id']),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDone ? Colors.green : Colors.transparent, width: 2)),
              child: Column(children: [
                Icon(isDone ? Icons.check : Icons.star_rounded, color: isDone ? Colors.green : primaryColor),
                const SizedBox(height: 12),
                Text(habit['title'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, color: isDone ? Colors.green : Colors.black87))
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCharts() {
    // --- 1. TÍNH TOÁN TIẾN ĐỘ CÔNG VIỆC ---
    int totalTasks = todayTasks.length;
    int doneTasks = todayTasks.where((t) =>
    t['is_completed'] == 1 || t['is_completed'] == true).length;
    double taskPercent = totalTasks > 0 ? (doneTasks / totalTasks) : 0;

    // --- 2. TÍNH TOÁN TIẾN ĐỘ THÓI QUEN ---
    int totalHabits = todayHabits.length;
    int doneHabits = todayHabits.where((h) =>
    h['is_completed'] == 1 || h['is_completed'] == true).length;
    double habitPercent = totalHabits > 0 ? (doneHabits / totalHabits) : 0;

    // --- 3. HIỂN THỊ 2 BIỂU ĐỒ NẰM NGANG NHAU ---
    return Row(
      children: [
        // Biểu đồ Công việc (Bên trái)
        Expanded(
          child: _buildChartCard("Công việc", taskPercent, doneTasks, totalTasks),
        ),

        const SizedBox(width: 16), // Khoảng cách giữa 2 biểu đồ

        // Biểu đồ Thói quen (Bên phải)
        Expanded(
          child: _buildChartCard("Thói quen", habitPercent, doneHabits, totalHabits),
        ),
      ],
    );
  }

  Widget _buildChartCard(String title, double percent, int done, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Dùng Stack để lồng chữ vào giữa vòng tròn
          SizedBox(
            height: 80, // Chiều cao vòng tròn (bạn có thể tăng giảm tùy ý)
            width: 80,  // Chiều rộng vòng tròn
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Vòng tròn tiến độ
                CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 8, // Độ dày của viền (mặc định là 4)
                  backgroundColor: surfaceLow, // Màu viền xám mờ ở dưới
                  valueColor: AlwaysStoppedAnimation(
                    percent == 1.0 ? Colors.green : primaryColor,
                  ),
                ),
                // Chữ % nằm ở chính giữa
                Center(
                  child: Text(
                    "${(percent * 100).toInt()}%",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900, // Chữ đậm giống ảnh
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. Dòng chữ tiêu đề nằm ở dưới (Công việc / Thói quen)
          Text(
            title.toUpperCase(), // Chuyển thành in hoa giống chữ "MỤC TIÊU NGÀY"
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey[600],
              letterSpacing: 0.5, // Giãn chữ ra một chút cho sang
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() => Container(
    padding: const EdgeInsets.only(top: 12, bottom: 32),
    decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)]),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(Icons.home_filled, "Home", '/dashboard', isActive: true),
        _buildNavItem(Icons.check_circle_outline, "Tasks", '/tasks'),
        _buildNavItem(Icons.repeat, "Habits", '/habits'),
        _buildNavItem(Icons.auto_awesome_outlined, "AI", '/ai'),
        _buildNavItem(Icons.person_outline, "Profile", '/profile'),
      ],
    ),
  );

  Widget _buildNavItem(IconData icon, String label, String route, {bool isActive = false}) => GestureDetector(
    onTap: () { if (!isActive) Navigator.pushReplacementNamed(context, route); },
    child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: isActive ? primaryColor : Colors.grey[400], size: 24), const SizedBox(height: 4), Text(label, style: TextStyle(color: isActive ? primaryColor : Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold))]),
  );
}