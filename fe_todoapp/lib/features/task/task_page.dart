import 'package:flutter/material.dart';
import '../../../data/services/task_service.dart';
import 'package:intl/intl.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  // --- HỆ MÀU & CONFIG ---
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceLow = const Color(0xFFEEF1F3);

  final TaskService _taskService = TaskService();

  // DỮ LIỆU ĐỘNG
  List<dynamic> tasks = [];
  List<Map<String, dynamic>> dynamicCategories = [];
  bool isLoading = true;

  // BIẾN TRẠNG THÁI PHỤC VỤ TÌM KIẾM / LỌC / SẮP XẾP CHUẨN
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  String _selectedFilter = "Tất cả"; // Hiển thị: "Tất cả", "Hôm nay", "Quá hạn", "Đã hoàn thành"
  String _selectedSort = "Mặc định"; // Hiển thị: "Mặc định", "Ưu tiên: Cao -> Thấp", "Ưu tiên: Thấp -> Cao"

  @override
  void initState() {
    super.initState();
    _refreshAllData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Tải lại toàn bộ dữ liệu (Tasks & Categories)
  Future<void> _refreshAllData() async {
    setState(() => isLoading = true);
    await Future.wait([
      _fetchTasks(),
      _loadCategories(),
    ]);
    if (mounted) setState(() => isLoading = false);
  }

  // Hàm chuyển đổi nhãn tiếng Việt sang mã tiếng Anh để gửi lên API Backend chống lỗi URL
  String _mapFilterToBackend(String filterLabel) {
    switch (filterLabel) {
      case "Hôm nay": return "today";
      case "Quá hạn": return "overdue";
      case "Đã hoàn thành": return "completed";
      default: return "all";
    }
  }

  // Hàm chuyển đổi nhãn sắp xếp sang mã tiếng Anh gửi lên Backend
  String _mapSortToBackend(String sortLabel) {
    switch (sortLabel) {
      case "Ưu tiên: Cao -> Thấp": return "high_to_low";
      case "Ưu tiên: Thấp -> Cao": return "low_to_high";
      default: return "default";
    }
  }

  // 1. Logic lấy danh sách Task chuẩn kết nối Backend
  Future<void> _fetchTasks() async {
    try {
      final backendFilter = _mapFilterToBackend(_selectedFilter);
      final backendSort = _mapSortToBackend(_selectedSort);

      final data = await _taskService.getAllTasks(
        1, // Giả định userId = 1
        search: _searchQuery,
        filterBy: backendFilter,
        sortBy: backendSort,
      );
      if (mounted) setState(() => tasks = data);
    } catch (e) {
      debugPrint("Lỗi tải task từ Backend: $e");
    }
  }

  // 2. Đảo trạng thái hoàn thành công việc khi click nút tròn
  Future<void> _toggleTaskCompletion(int taskId) async {
    try {
      final res = await _taskService.toggleTaskComplete(taskId);
      if (res['status'] == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(res['is_completed'] == true ? '🎉 Đã đánh dấu hoàn thành!' : 'Đã hủy hoàn thành công việc'),
              duration: const Duration(seconds: 1),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        _fetchTasks(); // Tải lại danh sách tương ứng từ server ngay lập tức
      }
    } catch (e) {
      debugPrint("Lỗi khi thay đổi trạng thái hoàn thành: $e");
    }
  }

  // 3. Logic lấy danh sách Danh mục
  Future<void> _loadCategories() async {
    final result = await _taskService.getCategories(1);
    if (result['status'] == 200 && mounted) {
      setState(() {
        dynamicCategories = List<Map<String, dynamic>>.from(result['data']);
      });
    }
  }

  // 4. Logic Xóa Task
  void _confirmDelete(int taskId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa?"),
        content: Text("Bạn muốn xóa công việc '$title' không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          TextButton(
            onPressed: () async {
              final ok = await _taskService.deleteTask(taskId);
              if (ok && mounted) {
                Navigator.pop(context);
                _fetchTasks();
              }
            },
            child: const Text("Xóa", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // 5. Logic Quản lý Danh mục
  void _showCategoryManagement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                  Text("Quản lý danh mục (${dynamicCategories.length}/10)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  if (dynamicCategories.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Text("Chưa có danh mục nào", style: TextStyle(color: Colors.grey)),
                    ),
                  ...dynamicCategories.map((cat) => ListTile(
                    leading: const Icon(Icons.label_rounded, color: Color(0xFF4647D3)),
                    title: Text(cat['name']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () async {
                        final res = await _taskService.deleteCategory(cat['id']);
                        if (res['status'] == 200) {
                          await _loadCategories();
                          setModalState(() {});
                        }
                      },
                    ),
                  )).toList(),
                  if (dynamicCategories.length < 10)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddCategoryDialog();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Thêm danh mục mới"),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                      ),
                    )
                ],
              ),
            );
          }
      ),
    );
  }

  // 6. Logic Dialog thêm danh mục
  void _showAddCategoryDialog() {
    final catController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Danh mục mới"),
        content: TextField(controller: catController, decoration: const InputDecoration(hintText: "Tên danh mục...")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              final textValue = catController.text.trim();
              if (textValue.isNotEmpty) {
                final res = await _taskService.addCategory(1, textValue);
                if (res['status'] == 201) {
                  await _loadCategories();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thêm danh mục thành công!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
                    );
                    Navigator.pop(context);
                    _showCategoryManagement();
                  }
                }
              }
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

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
              isLoading
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

  // --- UI COMPONENTS ---

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: Colors.white.withOpacity(0.8), elevation: 0,
    automaticallyImplyLeading: false,
    title: Text('Digital Curator', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 18)),
    actions: [
      IconButton(
        onPressed: () async {
          await _loadCategories();
          _showCategoryManagement();
        },
        icon: Icon(Icons.category_outlined, color: primaryColor),
        tooltip: "Quản lý danh mục",
      )
    ],
  );

  Widget _buildTaskList() {
    if (tasks.isEmpty) return const Center(child: Text("Chưa có công việc nào thỏa mãn"));
    return Column(children: tasks.map((task) => _buildTaskItem(task: task)).toList());
  }

  Widget _buildTaskItem({required Map task}) {
    String priority = task['priority']?.toString().toUpperCase() ?? "THẤP";
    bool isCompleted = task['is_completed'] == 1 || task['is_completed'] == true;

    return InkWell(
      onTap: () async {
        final result = await Navigator.pushNamed(context, '/task_detail', arguments: task);
        if (result == true) _refreshAllData();
      },
      onLongPress: () => _confirmDelete(task['id'], task['title']),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _toggleTaskCompletion(task['id']),
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: isCompleted ? Colors.green : primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
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
                        color: isCompleted ? Colors.grey : Colors.black87,
                      )
                  ),
                  const SizedBox(height: 4),
                  Text(
                      "Hạn: ${task['deadline'] ?? ''}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12)
                  ),
                ],
              ),
            ),
            _buildSmallTag(priority, primaryColor.withOpacity(0.1), primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() => FloatingActionButton(
    onPressed: () async {
      final result = await Navigator.pushNamed(context, '/task_detail');
      if (result == true) _refreshAllData();
    },
    backgroundColor: primaryColor, shape: const CircleBorder(),
    child: const Icon(Icons.add, color: Colors.white, size: 32),
  );

  Widget _buildBottomNav() => Container(
    padding: const EdgeInsets.only(top: 12, bottom: 32),
    decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
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

  Widget _buildNavItem(IconData icon, String label, String route, {bool isActive = false}) {
    return GestureDetector(
      onTap: () {
        if (!isActive) Navigator.pushReplacementNamed(context, route);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? primaryColor : Colors.grey[400], size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? primaryColor : Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSmallTag(String text, Color bg, Color textCol) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)), child: Text(text, style: TextStyle(color: textCol, fontSize: 9, fontWeight: FontWeight.w900)));

  Widget _buildSearchBar() => TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
        _fetchTasks(); // Kích hoạt bộ lọc tìm kiếm tức thì từ Backend
      },
      decoration: InputDecoration(
          filled: true,
          fillColor: surfaceLow,
          hintText: "Tìm kiếm...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = "");
              _fetchTasks();
            },
          )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)
      )
  );

  Widget _buildFilters() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          children: ["Tất cả", "Hôm nay", "Quá hạn", "Đã hoàn thành"].map((f) => GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = f;
              });
              _fetchTasks(); // Gửi tín hiệu tải lại tương ứng mốc lọc của Backend
            },
            child: _buildFilterChip(f, f == _selectedFilter),
          )).toList()
      )
  );

  Widget _buildFilterChip(String label, bool selected) => Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: selected ? primaryColor : surfaceLow, borderRadius: BorderRadius.circular(30)), child: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)));

  Widget _buildListHeader() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Danh sách", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
        PopupMenuButton<String>(
          onSelected: (String value) {
            setState(() {
              _selectedSort = value;
            });
            _fetchTasks(); // Gửi lệnh cập nhật sắp xếp xuống MySQL
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(value: 'Mặc định', child: Text('Mặc định')),
            const PopupMenuItem<String>(value: 'Ưu tiên: Cao -> Thấp', child: Text('Ưu tiên: Cao ➔ Thấp')),
            const PopupMenuItem<String>(value: 'Ưu tiên: Thấp -> Cao', child: Text('Ưu tiên: Thấp ➔ Cao')),
          ],
          child: Row(
            children: [
              Text(_selectedSort == 'Mặc định' ? "SẮP XẾP" : _selectedSort.toUpperCase(), style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
              Icon(Icons.arrow_drop_down, color: primaryColor, size: 16),
            ],
          ),
        )
      ]
  );
}