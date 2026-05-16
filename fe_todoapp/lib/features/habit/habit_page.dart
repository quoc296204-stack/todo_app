import 'package:flutter/material.dart';
import '../../../data/services/habit_service.dart';
import 'package:intl/intl.dart';

class HabitPage extends StatefulWidget {
  const HabitPage({super.key}); // Giữ nguyên định danh cấu trúc của bạn

  @override
  State<HabitPage> createState() => _HabitPageState();
}

class _HabitPageState extends State<HabitPage> {
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceLow = const Color(0xFFEEF1F3);

  final HabitService _habitService = HabitService();

  List<dynamic> habits = [];
  bool isLoading = true;
  int progressPercentage = 0;

  DateTime _selectedDate = DateTime.now();
  List<DateTime> _weekDays = [];

  @override
  void initState() {
    super.initState();
    _generateHorizontalCalendar();
    _loadHabitData();
  }

  void _generateHorizontalCalendar() {
    final today = DateTime.now();
    _weekDays = List.generate(5, (index) => today.add(Duration(days: index - 2)));
  }

  // 🌟 NÂNG CẤP BỌC TRY-CATCH: Chống tuyệt đối việc treo Loading hoặc trắng màn hình
  Future<void> _loadHabitData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final res = await _habitService.getHabitsByDate(1, dateStr); // Gọi dữ liệu User ID = 1

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
      // Nếu có lỗi ép kiểu, in ngay ra màn hình debug để xử lý và tắt trạng thái xoay tải
      debugPrint("❌ LỖI PHẦN CỨNG FRONTEND: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Future<void> _toggleHabit(int habitId) async {
  //   final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
  //   final res = await _habitService.toggleHabit(habitId, dateStr);
  //   if (res['status'] == 200) {
  //     _loadHabitData();
  //   }
  // }
  // 🌟 NÂNG CẤP UX: Đảo trạng thái lập tức trên giao diện, chạy API ngầm dưới nền
  Future<void> _toggleHabit(int habitId) async {
    // Bước 1: Cập nhật local state ngay lập tức để giao diện phản hồi không độ trễ
    setState(() {
      // Duyệt mảng tìm thói quen vừa bấm và đảo trạng thái is_completed
      for (var habit in habits) {
        if (habit['id'] == habitId) {
          habit['is_completed'] = !(habit['is_completed'] == true);
          break;
        }
      }

      // Tính toán lại luôn phần trăm mục tiêu ngày để vòng tròn tiến độ nhảy số lập tức
      int total = habits.length;
      int completed = habits.where((h) => h['is_completed'] == true).length;
      progressPercentage = total > 0 ? ((completed / total) * 100).toInt() : 0;
    });

    // Bước 2: Gọi API cập nhật xuống MySQL ở dưới Background (Không gọi lại _loadHabitData() để tránh bị bật Spinner loading)
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final res = await _habitService.toggleHabit(habitId, dateStr);

    // Bước 3: Phòng hờ trường hợp hy hữu (lỗi mạng, server sập), nếu API thất bại thì rollback lại dữ liệu chuẩn
    if (res['status'] != 200) {
      _loadHabitData(); // Tải lại dữ liệu gốc từ DB để đồng bộ lại giao diện cho chính xác
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

  // 🌟 VIẾT THÊM: Hàm hiển thị Dialog tạo thói quen trực tiếp từ điện thoại
  void _showAddHabitDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                final success = await _habitService.createHabit(1, title, descController.text.trim());
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('🎉 Thêm thói quen thành công!'), behavior: SnackBarBehavior.floating),
                  );
                  _loadHabitData(); // Tải lại danh sách thói quen mới lập tức
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

  @override
  Widget build(BuildContext context) {
    String monthYearStr = DateFormat('THÁNG MM, yyyy').format(_selectedDate).toUpperCase();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshData,
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
              isLoading
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

  Future<void> _refreshData() async {
    await _loadHabitData();
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: bgColor, elevation: 0,
    automaticallyImplyLeading: false,
    title: const Text('Digital Curator', style: TextStyle(color: Color(0xFF4647D3), fontWeight: FontWeight.w900, fontSize: 18)),
    centerTitle: true,
    actions: [IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.grey), onPressed: () {})],
  );

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: _weekDays.map((day) {
        bool isSelected = day.day == _selectedDate.day && day.month == _selectedDate.month;
        String weekdayStr = DateFormat('E').format(day).replaceFirst('Mon', 'T2').replaceFirst('Tue', 'T3').replaceFirst('Wed', 'T4').replaceFirst('Thu', 'T5').replaceFirst('Fri', 'T6').replaceFirst('Sat', 'T7').replaceFirst('Sun', 'CN');

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

  // 🌟 NÂNG CẤP CHUẨN KIỂU: Đổi sang nhận diện tham số đặt tên {required Map habit} an toàn tuyệt đối
  Widget _buildHabitItem({required Map habit}) {
    bool isDone = habit['is_completed'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)]),
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
            onTap: () => _toggleHabit(habit['id']),
            child: Icon(isDone ? Icons.check_circle : Icons.circle_outlined, color: isDone ? Colors.green : Colors.grey[300], size: 28),
          ),
        ],
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

  // 🌟 ĐÃ LIÊN KẾT: Bấm nút "+" sẽ bật ngay cửa sổ nhập thói quen
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