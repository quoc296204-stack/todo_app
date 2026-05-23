import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/task_service.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> with WidgetsBindingObserver {
  // --- HỆ MÀU & CONFIG ---
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceLow = const Color(0xFFEEF1F3);

  final TaskService _taskService = TaskService();

  // DỮ LIỆU ĐỘNG
  int? currentUserId;
  List<dynamic> tasks = [];
  List<Map<String, dynamic>> dynamicCategories = [];
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedFilter = "Hôm nay";
  String _selectedSort = "Mặc định";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshAllData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && currentUserId != null) {
      _refreshAllData();
    }
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getInt('userId');
    });
  }

  Future<void> _refreshAllData() async {
    setState(() => isLoading = true);
    await _loadUserId();
    if (currentUserId != null) {
      await Future.wait([
        _fetchTasks(),
        _loadCategories(),
      ]);
    }
    if (mounted) setState(() => isLoading = false);
  }

  String _mapFilterToBackend(String filterLabel) {
    switch (filterLabel) {
      case "Hôm nay": return "today";
      case "Quá hạn": return "overdue";
      case "Đã hoàn thành": return "completed";
      default: return "all";
    }
  }

  String _mapSortToBackend(String sortLabel) {
    switch (sortLabel) {
      case "Ưu tiên: Cao -> Thấp": return "high_to_low";
      case "Ưu tiên: Thấp -> Cao": return "low_to_high";
      default: return "default";
    }
  }

  Future<void> _fetchTasks() async {
    if (currentUserId == null) return;
    try {
      final backendFilter = _mapFilterToBackend(_selectedFilter);
      final backendSort = _mapSortToBackend(_selectedSort);

      final data = await _taskService.getAllTasks(
        currentUserId!,
        search: _searchQuery,
        filterBy: backendFilter,
        sortBy: backendSort,
      );
      if (mounted) setState(() => tasks = data);
    } catch (e) {
      debugPrint("Lỗi tải task từ Backend: $e");
    }
  }

  Future<void> _toggleTaskCompletion(int taskId) async {
    bool isCompletedNow = false;
    setState(() {
      for (var task in tasks) {
        if (task['id'] == taskId) {
          if (task['is_completed'] is int) {
            task['is_completed'] = task['is_completed'] == 1 ? 0 : 1;
            isCompletedNow = task['is_completed'] == 1;
          } else {
            task['is_completed'] = !(task['is_completed'] == true);
            isCompletedNow = task['is_completed'] == true;
          }
          break;
        }
      }
    });

    final res = await _taskService.toggleTaskComplete(taskId);
    if (res['status'] == 200) {
      if (_selectedFilter != "Hôm nay") {
        Future.delayed(const Duration(milliseconds: 500), () => _fetchTasks());
      }
    } else {
      _fetchTasks();
    }
  }

  Future<void> _loadCategories() async {
    if (currentUserId == null) return;
    final result = await _taskService.getCategories(currentUserId!);
    if (result['status'] == 200 && mounted) {
      setState(() {
        dynamicCategories = List<Map<String, dynamic>>.from(result['data']);
      });
    }
  }

  // --- BUILD UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refreshAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildFilters(),
              const SizedBox(height: 32),
              _buildListHeader(),
              const SizedBox(height: 20),
              currentUserId == null
                  ? const Center(child: Text("Vui lòng đăng nhập"))
                  : isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildTaskList(),
              const SizedBox(height: 120),
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
    title: Text('Digital Curator', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 18)),
    centerTitle: true,
  );

  Widget _buildTaskList() {
    if (tasks.isEmpty) return const Center(child: Text("Không có công việc nào"));
    return Column(children: tasks.map((task) => _buildTaskItem(task: task)).toList());
  }

  // ====================================================================
  // CHỈNH SỬA Ở ĐÂY: RENDER SUBTASKS TRỰC QUAN KÈM CHECKBOX ĐỘNG
  // ====================================================================
  Widget _buildTaskItem({required Map task}) {
    String priority = task['priority']?.toString().toUpperCase() ?? "THẤP";
    bool isCompleted = task['is_completed'] == 1 || task['is_completed'] == true;

    // Bốc tách danh sách việc con từ JSON Backend trả về
    List subtasks = task['subtasks'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Khối 1: Hiển thị Task chính (Tiêu đề, Deadline, Tag ưu tiên)
          InkWell(
            onTap: () async {
              final result = await Navigator.pushNamed(context, '/task_detail', arguments: task);
              if (result == true) _refreshAllData();
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _toggleTaskCompletion(task['id']),
                    child: Icon(isCompleted ? Icons.check_circle : Icons.circle_outlined, color: isCompleted ? Colors.green : primaryColor, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            task['title'] ?? "",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                color: isCompleted ? Colors.grey : Colors.black87
                            )
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                                task['deadline'] != null ? task['deadline'].toString().substring(0, 16) : '',
                                style: TextStyle(color: Colors.grey[600], fontSize: 12)
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildSmallTag(priority, isCompleted ? Colors.grey[200]! : primaryColor.withOpacity(0.1), isCompleted ? Colors.grey : primaryColor),
                ],
              ),
            ),
          ),

          // Khối 2: Nếu có Subtasks, vẽ một đường kẻ và kết xuất danh sách việc con ngay bên dưới
          if (subtasks.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Divider(height: 1, color: Color(0xFFF0F2F5)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 44, right: 16, top: 8, bottom: 12),
              child: Column(
                children: subtasks.map((subtask) {
                  bool isSubDone = subtask['is_completed'] == true || subtask['is_completed'] == 1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          height: 28,
                          child: Checkbox(
                            value: isSubDone,
                            activeColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (bool? val) {
                              // Tinh chỉnh State tại local lập tức để tránh delay giao diện
                              setState(() {
                                subtask['is_completed'] = val ?? false;
                              });
                              // Gọi API ngầm đồng bộ trạng thái việc con lên MySQL Backend
                              _taskService.toggleSubTaskComplete(subtask['id']);
                            },
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            subtask['title'] ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              decoration: isSubDone ? TextDecoration.lineThrough : null,
                              color: isSubDone ? Colors.grey : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildFAB() => FloatingActionButton(
    onPressed: () async {
      final result = await Navigator.pushNamed(context, '/task_detail');
      if (result == true) _refreshAllData();
    },
    backgroundColor: primaryColor, child: const Icon(Icons.add, color: Colors.white),
  );

  Widget _buildBottomNav() => Container(
    padding: const EdgeInsets.only(top: 12, bottom: 32),
    decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildNavItem(Icons.home_outlined, "Home", '/dashboard'),
        _buildNavItem(Icons.check_circle, "Tasks", '/tasks', isActive: true),
        _buildNavItem(Icons.repeat, "Habits", '/habits'),
        _buildNavItem(Icons.auto_awesome_outlined, "AI", '/ai'),
        _buildNavItem(Icons.person_outline, "Profile", '/profile'),
      ],
    ),
  );

  Widget _buildNavItem(IconData icon, String label, String route, {bool isActive = false}) => GestureDetector(
    onTap: () { if (!isActive) Navigator.pushReplacementNamed(context, route); },
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: isActive ? primaryColor : Colors.grey[400]),
      Text(label, style: TextStyle(color: isActive ? primaryColor : Colors.grey[400], fontSize: 10)),
    ]),
  );

  Widget _buildSmallTag(String text, Color bg, Color textCol) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)), child: Text(text, style: TextStyle(color: textCol, fontSize: 9, fontWeight: FontWeight.w900)));

  Widget _buildSearchBar() => TextField(
    controller: _searchController,
    onChanged: (_) => _fetchTasks(),
    decoration: InputDecoration(filled: true, fillColor: surfaceLow, hintText: "Tìm kiếm...", border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
  );

  Widget _buildFilters() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: ["Tất cả", "Hôm nay", "Quá hạn", "Đã hoàn thành"].map((f) => GestureDetector(
        onTap: () { setState(() => _selectedFilter = f); _fetchTasks(); },
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(color: f == _selectedFilter ? primaryColor : surfaceLow, borderRadius: BorderRadius.circular(30)),
          child: Text(f, style: TextStyle(color: f == _selectedFilter ? Colors.white : Colors.black87)),
        ),
      )).toList(),
    ),
  );

  Widget _buildListHeader() => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      const Text("Danh sách", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      PopupMenuButton<String>(
        onSelected: (v) { setState(() => _selectedSort = v); _fetchTasks(); },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'Mặc định', child: Text('Mặc định')),
          const PopupMenuItem(value: 'Ưu tiên: Cao -> Thấp', child: Text('Cao ➔ Thấp')),
        ],
        child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: const Text("SẮP XẾP")),
      )
    ],
  );
}