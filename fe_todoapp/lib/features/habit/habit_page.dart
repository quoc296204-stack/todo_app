import 'package:flutter/material.dart';
import '../../../data/services/habit_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key});

  @override
  State<HabitPage> createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceLow = const Color(0xFFEEF1F3);

  final HabitService _habitService = HabitService();
  int? currentUserId;
  bool isLoading = true;
  List<dynamic> habits = [];
  int progressPercentage = 0;

  DateTime _selectedDate = DateTime.now();
  List<DateTime> _weekDays = [];

  @override
  void initState() {
    super.initState();
    _generateHorizontalCalendar();
    _initData();
  }

  void _generateHorizontalCalendar() {
    final today = DateTime.now();
    _weekDays = List.generate(5, (index) => today.add(Duration(days: index - 2)));
  }

  Future<void> _initData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getInt('userId');
    });

    if (currentUserId != null) {
      await _loadHabitData();
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadHabitData() async {
    if (currentUserId == null || !mounted) return;
    setState(() => isLoading = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final res = await _habitService.getHabitsByDate(currentUserId!, dateStr);

      if (res['status'] == 200 && mounted) {
        final List<dynamic> fetchedHabits = res['data'] ?? [];
        int total = fetchedHabits.length;
        int completed = fetchedHabits.where((h) => h['is_completed'] == true).length;

        setState(() {
          habits = fetchedHabits;
          progressPercentage = total > 0 ? ((completed / total) * 100).toInt() : 0;
          isLoading = false;
        });
      } else {
        if (mounted) setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("❌ LỖI PHẦN CỨNG FRONTEND: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _toggleHabit(int habitId) async {
    setState(() {
      for (var habit in habits) {
        if (habit['id'] == habitId) {
          habit['is_completed'] = !(habit['is_completed'] == true);
          break;
        }
      }
      int total = habits.length;
      int completed = habits.where((h) => h['is_completed'] == true).length;
      progressPercentage = total > 0 ? ((completed / total) * 100).toInt() : 0;
    });

    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final res = await _habitService.toggleHabit(habitId, dateStr);

    if (res['status'] != 200) {
      _loadHabitData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Lỗi kết nối mạng, không thể cập nhật trạng thái!'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showAddHabitDialog() {
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập')));
      return;
    }

    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Thói quen mới", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(hintText: "Tên thói quen (ví dụ: Chạy bộ)...")),
            const SizedBox(height: 8),
            TextField(controller: descController, decoration: const InputDecoration(hintText: "Mô tả ngắn...")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                final success = await _habitService.createHabit(currentUserId!, title, descController.text.trim());
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🎉 Thêm thói quen thành công!'), behavior: SnackBarBehavior.floating, backgroundColor: Colors.green),
                  );
                  _loadHabitData();
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  // 🌟 MỚI: Hàm hiển thị Dialog sửa thói quen
  void _showEditHabitDialog(Map habit) {
    final titleController = TextEditingController(text: habit['title'] ?? '');
    final descController = TextEditingController(text: habit['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Sửa thói quen", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(hintText: "Tên thói quen...")),
            const SizedBox(height: 8),
            TextField(controller: descController, decoration: const InputDecoration(hintText: "Mô tả ngắn...")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                final success = await _habitService.updateHabit(habit['id'], title, descController.text.trim());
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã cập nhật thói quen!'), behavior: SnackBarBehavior.floating),
                  );
                  _loadHabitData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lỗi cập nhật thói quen!')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
            child: const Text("Cập nhật"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String monthYearStr = "THÁNG ${_selectedDate.month.toString().padLeft(2, '0')}, ${_selectedDate.year}";
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: () async => await _loadHabitData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(monthYearStr, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                  Icon(Icons.calendar_month_outlined, color: primaryColor, size: 20),
                ],
              ),
              const SizedBox(height: 16),
              _buildCalendarHeader(),
              const SizedBox(height: 32),
              currentUserId == null
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("Vui lòng đăng nhập để xem dữ liệu")))
                  : isLoading
                  ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                  : _buildHabitList(),
              const SizedBox(height: 24),
              _buildBottomDashboard(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: bgColor, elevation: 0,
    automaticallyImplyLeading: false,
    centerTitle: true,
  );

  Widget _buildCalendarHeader() {
    final List<String> vietnameseWeekdays = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _weekDays.map((day) {
        bool isSelected = day.day == _selectedDate.day && day.month == _selectedDate.month;
        String weekdayStr = vietnameseWeekdays[day.weekday % 7];

        return GestureDetector(
          onTap: () {
            setState(() => _selectedDate = day);
            _loadHabitData();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? primaryColor : surfaceLow.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(weekdayStr, style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('${day.day}', style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontSize: 16, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildHabitList() {
    if (habits.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("Hôm nay không có thói quen nào. Hãy thêm mới!", style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return Column(children: habits.map((h) => _buildHabitItem(habit: h)).toList());
  }

  // 🌟 MỚI: Bọc item bằng Dismissible và InkWell để vuốt xóa / chạm sửa
  Widget _buildHabitItem({required Map habit}) {
    bool isDone = habit['is_completed'] == true;

    return Dismissible(
      key: Key('habit_${habit['id']}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text("Xóa thói quen", style: TextStyle(fontWeight: FontWeight.bold)),
              content: const Text("Bạn có chắc chắn muốn xóa thói quen này không?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("HỦY", style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("XÓA", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        final success = await _habitService.deleteHabit(habit['id']);
        if (success) {
          setState(() {
            habits.removeWhere((h) => h['id'] == habit['id']);
            int total = habits.length;
            int completed = habits.where((h) => h['is_completed'] == true).length;
            progressPercentage = total > 0 ? ((completed / total) * 100).toInt() : 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đã xóa thói quen")),
          );
        } else {
          _loadHabitData(); // Load lại nếu lỗi
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Lỗi không thể xóa thói quen!")),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)]
        ),
        child: InkWell(
          onTap: () => _showEditHabitDialog(habit), // Chạm vào vùng trắng để Sửa
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: primaryColor.withOpacity(0.1), radius: 20, child: Icon(Icons.star_rounded, color: primaryColor, size: 20)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          habit['title'] ?? "",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              decoration: isDone ? TextDecoration.lineThrough : null,
                              color: isDone ? Colors.grey : Colors.black87
                          )
                      ),
                      if (habit['description'] != null && habit['description'].toString().isNotEmpty)
                        Padding(padding: const EdgeInsets.only(top: 2), child: Text(habit['description'], style: const TextStyle(color: Colors.grey, fontSize: 12))),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _toggleHabit(habit['id']), // Chạm riêng vào icon check để Tick
                  child: Container(
                    color: Colors.transparent, // Mở rộng vùng chạm
                    padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                    child: Icon(isDone ? Icons.check_circle : Icons.circle_outlined, color: isDone ? Colors.green : Colors.grey[300], size: 28),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomDashboard() {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            height: 140, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(24)),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Động lực hôm nay", style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('"Kỷ luật là cầu nối giữa mục tiêu và thành tựu."', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 5,
          child: Container(
            height: 140,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 65, height: 65,
                      child: CircularProgressIndicator(
                        value: progressPercentage / 100,
                        strokeWidth: 6, backgroundColor: surfaceLow,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      ),
                    ),
                    Text('$progressPercentage%', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  ],
                ),
                const SizedBox(height: 12),
                const Text("MỤC TIÊU NGÀY", style: TextStyle(color: Colors.grey, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFAB() => FloatingActionButton(
    onPressed: _showAddHabitDialog,
    backgroundColor: primaryColor, shape: const CircleBorder(),
    child: const Icon(Icons.add, color: Colors.white, size: 28),
  );

  Widget _buildBottomNav() => Container(
    padding: const EdgeInsets.only(top: 12, bottom: 32),
    decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)]),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(Icons.home_outlined, "Home", '/dashboard'),
        _buildNavItem(Icons.check_circle_outline, "Tasks", '/tasks'),
        _buildNavItem(Icons.repeat, "Habits", '/habits', isActive: true),
        _buildNavItem(Icons.auto_awesome_outlined, "AI", '/ai'),
        _buildNavItem(Icons.person_outline, "Profile", '/profile'),
      ],
    ),
  );

  Widget _buildNavItem(IconData icon, String label, String route, {bool isActive = false}) => GestureDetector(
    onTap: () { if (!isActive) Navigator.pushReplacementNamed(context, route); },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? primaryColor : Colors.grey[400], size: 24),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: isActive ? primaryColor : Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}