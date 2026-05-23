// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../data/services/task_service.dart';
//
// class TaskPage extends StatefulWidget {
//   const TaskPage({super.key});
//
//   @override
//   State<TaskPage> createState() => _TaskPageState();
// }
//
// class _TaskPageState extends State<TaskPage> with WidgetsBindingObserver {
//   // --- HỆ MÀU & CONFIG ---
//   final Color primaryColor = const Color(0xFF4647D3);
//   final Color bgColor = const Color(0xFFF5F7F9);
//   final Color surfaceLow = const Color(0xFFEEF1F3);
//
//   final TaskService _taskService = TaskService();
//
//   // DỮ LIỆU ĐỘNG
//   int? currentUserId;
//   List<dynamic> tasks = [];
//   List<Map<String, dynamic>> dynamicCategories = [];
//   bool isLoading = true;
//
//   // BIẾN TRẠNG THÁI PHỤC VỤ TÌM KIẾM / LỌC / SẮP XẾP CHUẨN
//   final TextEditingController _searchController = TextEditingController();
//   String _searchQuery = "";
//   String _selectedFilter = "Hôm nay"; // Đổi mặc định sang "Hôm nay" để đồng bộ với Dashboard
//   String _selectedSort = "Mặc định";
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this); // Lắng nghe vòng đời App
//     _refreshAllData();
//   }
//
//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     _searchController.dispose();
//     super.dispose();
//   }
//
//   // Tự động làm mới khi mở lại App từ dưới nền (chống treo ngày cũ)
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     super.didChangeAppLifecycleState(state);
//     if (state == AppLifecycleState.resumed && currentUserId != null) {
//       _refreshAllData();
//     }
//   }
//
//   Future<void> _loadUserId() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       currentUserId = prefs.getInt('userId');
//     });
//   }
//
//   // Tải lại toàn bộ dữ liệu (Tasks & Categories)
//   Future<void> _refreshAllData() async {
//     setState(() => isLoading = true);
//
//     await _loadUserId();
//
//     if (currentUserId != null) {
//       await Future.wait([
//         _fetchTasks(),
//         _loadCategories(),
//       ]);
//     }
//
//     if (mounted) setState(() => isLoading = false);
//   }
//
//   String _mapFilterToBackend(String filterLabel) {
//     switch (filterLabel) {
//       case "Hôm nay": return "today";
//       case "Quá hạn": return "overdue";
//       case "Đã hoàn thành": return "completed";
//       default: return "all";
//     }
//   }
//
//   String _mapSortToBackend(String sortLabel) {
//     switch (sortLabel) {
//       case "Ưu tiên: Cao -> Thấp": return "high_to_low";
//       case "Ưu tiên: Thấp -> Cao": return "low_to_high";
//       default: return "default";
//     }
//   }
//
//   // 1. Logic lấy danh sách Task chuẩn kết nối Backend
//   Future<void> _fetchTasks() async {
//     if (currentUserId == null) return;
//     try {
//       final backendFilter = _mapFilterToBackend(_selectedFilter);
//       final backendSort = _mapSortToBackend(_selectedSort);
//
//       final data = await _taskService.getAllTasks(
//         currentUserId!,
//         search: _searchQuery,
//         filterBy: backendFilter,
//         sortBy: backendSort,
//       );
//       // 👉 THÊM DÒNG NÀY ĐỂ XEM BACKEND TRẢ VỀ CÁI GÌ:
//       print("=== DỮ LIỆU TAB 'HÔM NAY': $data ===");
//       if (mounted) setState(() => tasks = data);
//     } catch (e) {
//       debugPrint("Lỗi tải task từ Backend: $e");
//     }
//   }
//
//   // 2. Đảo trạng thái hoàn thành công việc (NÂNG CẤP OPTIMISTIC UI)
//   Future<void> _toggleTaskCompletion(int taskId) async {
//     bool isCompletedNow = false;
//
//     // Bước 1: Cập nhật giao diện ngay lập tức cho mượt
//     setState(() {
//       for (var task in tasks) {
//         if (task['id'] == taskId) {
//           if (task['is_completed'] is int) {
//             task['is_completed'] = task['is_completed'] == 1 ? 0 : 1;
//             isCompletedNow = task['is_completed'] == 1;
//           } else {
//             task['is_completed'] = !(task['is_completed'] == true);
//             isCompletedNow = task['is_completed'] == true;
//           }
//           break;
//         }
//       }
//     });
//
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(isCompletedNow ? '🎉 Đã đánh dấu hoàn thành!' : 'Đã hủy hoàn thành công việc'),
//           duration: const Duration(milliseconds: 1200),
//           behavior: SnackBarBehavior.floating,
//         ),
//       );
//     }
//
//     // Bước 2: Gọi API cập nhật ngầm. Nếu filter đang là "Tất cả" hoặc "Quá hạn" (những tab ẩn task đã xong)
// // Bước 2: Gọi API cập nhật ngầm.
//     final res = await _taskService.toggleTaskComplete(taskId);
//     if (res['status'] == 200) {
//       // --- SỬA ĐOẠN ĐIỀU KIỆN NÀY ---
//       // Nếu là tab "Hôm nay", chúng ta KHÔNG gọi lại _fetchTasks() để task KHÔNG bị biến mất.
//       // Chỉ gọi lại _fetchTasks() khi bạn đang ở tab "Tất cả" hoặc "Quá hạn" để lọc bớt task đi.
//       if (_selectedFilter != "Hôm nay") {
//         // Chờ 0.5 giây cho người dùng thấy hiệu ứng tick xanh rồi mới load lại danh sách
//         Future.delayed(const Duration(milliseconds: 500), () => _fetchTasks());
//       }
//     } else {
//       _fetchTasks(); // Rollback dữ liệu từ server nếu lỡ mạng bị lỗi
//     }
//   }
//
//   // 3. Logic lấy danh sách Danh mục
//   Future<void> _loadCategories() async {
//     if (currentUserId == null) return;
//     final result = await _taskService.getCategories(currentUserId!);
//     if (result['status'] == 200 && mounted) {
//       setState(() {
//         dynamicCategories = List<Map<String, dynamic>>.from(result['data']);
//       });
//     }
//   }
//
//   // 4. Logic Xóa Task
//   void _confirmDelete(int taskId, String title) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Xác nhận xóa?", style: TextStyle(fontWeight: FontWeight.bold)),
//         content: Text("Bạn muốn xóa công việc '$title' không?"),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
//           TextButton(
//             onPressed: () async {
//               final ok = await _taskService.deleteTask(taskId);
//               if (ok && mounted) {
//                 Navigator.pop(context);
//                 _fetchTasks();
//               }
//             },
//             child: const Text("Xóa", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 5. Logic Quản lý Danh mục
//   void _showCategoryManagement() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
//       builder: (context) => StatefulBuilder(
//           builder: (context, setModalState) {
//             return Container(
//               padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
//                   Text("Quản lý danh mục (${dynamicCategories.length}/10)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//                   const SizedBox(height: 16),
//                   if (dynamicCategories.isEmpty)
//                     const Padding(
//                       padding: EdgeInsets.symmetric(vertical: 20),
//                       child: Text("Chưa có danh mục nào", style: TextStyle(color: Colors.grey)),
//                     ),
//                   ...dynamicCategories.map((cat) => ListTile(
//                     leading: const Icon(Icons.label_rounded, color: Color(0xFF4647D3)),
//                     title: Text(cat['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
//                     trailing: IconButton(
//                       icon: const Icon(Icons.delete_outline, color: Colors.red),
//                       onPressed: () async {
//                         final res = await _taskService.deleteCategory(cat['id']);
//                         if (res['status'] == 200) {
//                           await _loadCategories();
//                           setModalState(() {});
//                         }
//                       },
//                     ),
//                   )).toList(),
//                   if (dynamicCategories.length < 10)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 10),
//                       child: ElevatedButton.icon(
//                         onPressed: () {
//                           Navigator.pop(context);
//                           _showAddCategoryDialog();
//                         },
//                         icon: const Icon(Icons.add),
//                         label: const Text("Thêm danh mục mới"),
//                         style: ElevatedButton.styleFrom(
//                             backgroundColor: primaryColor,
//                             foregroundColor: Colors.white,
//                             minimumSize: const Size(double.infinity, 50),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
//                         ),
//                       ),
//                     )
//                 ],
//               ),
//             );
//           }
//       ),
//     );
//   }
//
//   // 6. Logic Dialog thêm danh mục
//   void _showAddCategoryDialog() {
//     final catController = TextEditingController();
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Danh mục mới", style: TextStyle(fontWeight: FontWeight.bold)),
//         content: TextField(
//             controller: catController,
//             autofocus: true,
//             decoration: const InputDecoration(hintText: "Tên danh mục...")
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
//           ElevatedButton(
//             onPressed: () async {
//               final textValue = catController.text.trim();
//               if (textValue.isNotEmpty && currentUserId != null) {
//                 final res = await _taskService.addCategory(currentUserId!, textValue);
//                 if (res['status'] == 201) {
//                   await _loadCategories();
//                   if (mounted) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Thêm danh mục thành công!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
//                     );
//                     Navigator.pop(context);
//                     _showCategoryManagement();
//                   }
//                 }
//               }
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
//             child: const Text("Lưu"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: bgColor,
//       appBar: _buildAppBar(),
//       body: RefreshIndicator(
//         onRefresh: _refreshAllData,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.symmetric(horizontal: 20),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 20),
//               _buildSearchBar(),
//               const SizedBox(height: 16),
//               _buildFilters(),
//               const SizedBox(height: 32),
//               _buildListHeader(),
//               const SizedBox(height: 20),
//               currentUserId == null
//                   ? const Center(child: Text("Vui lòng đăng nhập để xem dữ liệu"))
//                   : isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : _buildTaskList(),
//               const SizedBox(height: 120),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: _buildFAB(),
//       bottomNavigationBar: _buildBottomNav(),
//     );
//   }
//
//   PreferredSizeWidget _buildAppBar() => AppBar(
//     backgroundColor: bgColor, elevation: 0,
//     automaticallyImplyLeading: false,
//     // title: Text('Digital Curator', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 18)),
//     centerTitle: true,
//     actions: [
//       IconButton(
//         onPressed: () async {
//           await _loadCategories();
//           _showCategoryManagement();
//         },
//         icon: Icon(Icons.category_outlined, color: primaryColor),
//         tooltip: "Quản lý danh mục",
//       )
//     ],
//   );
//
//   Widget _buildTaskList() {
//     if (tasks.isEmpty) {
//       return Center(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Text(
//                 _searchQuery.isNotEmpty ? "Không tìm thấy công việc nào" : "Chưa có công việc nào thỏa mãn",
//                 style: const TextStyle(color: Colors.grey)
//             ),
//           )
//       );
//     }
//     return Column(children: tasks.map((task) => _buildTaskItem(task: task)).toList());
//   }
//
//   Widget _buildTaskItem({required Map task}) {
//     String priority = task['priority']?.toString().toUpperCase() ?? "THẤP";
//     bool isCompleted = task['is_completed'] == 1 || task['is_completed'] == true;
//
//     return InkWell(
//       onTap: () async {
//         final result = await Navigator.pushNamed(context, '/task_detail', arguments: task);
//         if (result == true) _refreshAllData();
//       },
//       onLongPress: () => _confirmDelete(task['id'], task['title']),
//       borderRadius: BorderRadius.circular(16),
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 300),
//         margin: const EdgeInsets.only(bottom: 12),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: isCompleted ? Colors.green.withOpacity(0.5) : Colors.transparent, width: 1.5),
//             boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
//         ),
//         child: Row(
//           children: [
//             GestureDetector(
//               onTap: () => _toggleTaskCompletion(task['id']),
//               child: Icon(
//                 isCompleted ? Icons.check_circle : Icons.circle_outlined,
//                 color: isCompleted ? Colors.green : primaryColor,
//                 size: 26,
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                       task['title'] ?? "",
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         decoration: isCompleted ? TextDecoration.lineThrough : null,
//                         color: isCompleted ? Colors.grey : Colors.black87,
//                       )
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Icon(Icons.access_time, size: 12, color: isCompleted ? Colors.grey : Colors.grey[600]),
//                       const SizedBox(width: 4),
//                       Text(
//                           task['deadline'] != null ? task['deadline'].toString().substring(0, 16) : '',
//                           style: TextStyle(color: isCompleted ? Colors.grey : Colors.grey[600], fontSize: 12)
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             _buildSmallTag(priority, isCompleted ? Colors.grey[200]! : primaryColor.withOpacity(0.1), isCompleted ? Colors.grey : primaryColor),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFAB() => FloatingActionButton(
//     onPressed: () async {
//       final result = await Navigator.pushNamed(context, '/task_detail');
//       if (result == true) _refreshAllData();
//     },
//     backgroundColor: primaryColor, shape: const CircleBorder(),
//     child: const Icon(Icons.add, color: Colors.white, size: 32),
//   );
//
//   Widget _buildBottomNav() => Container(
//     padding: const EdgeInsets.only(top: 12, bottom: 32),
//     decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(32)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)]),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       children: [
//         _buildNavItem(Icons.home_outlined, "Home", '/dashboard'),
//         _buildNavItem(Icons.check_circle, "Tasks", '/tasks', isActive: true),
//         _buildNavItem(Icons.repeat, "Habits", '/habits'),
//         _buildNavItem(Icons.auto_awesome_outlined, "AI", '/ai'),
//         _buildNavItem(Icons.person_outline, "Profile", '/profile'),
//       ],
//     ),
//   );
//
//   Widget _buildNavItem(IconData icon, String label, String route, {bool isActive = false}) {
//     return GestureDetector(
//       onTap: () {
//         if (!isActive) Navigator.pushReplacementNamed(context, route);
//       },
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: isActive ? primaryColor : Colors.grey[400], size: 26),
//           const SizedBox(height: 4),
//           Text(label, style: TextStyle(color: isActive ? primaryColor : Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSmallTag(String text, Color bg, Color textCol) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)), child: Text(text, style: TextStyle(color: textCol, fontSize: 9, fontWeight: FontWeight.w900)));
//
//   Widget _buildSearchBar() => TextField(
//       controller: _searchController,
//       onChanged: (value) {
//         setState(() => _searchQuery = value);
//         _fetchTasks();
//       },
//       decoration: InputDecoration(
//           filled: true,
//           fillColor: surfaceLow,
//           hintText: "Tìm kiếm công việc...",
//           prefixIcon: const Icon(Icons.search, color: Colors.grey),
//           suffixIcon: _searchQuery.isNotEmpty
//               ? IconButton(
//             icon: const Icon(Icons.clear, color: Colors.grey),
//             onPressed: () {
//               _searchController.clear();
//               setState(() => _searchQuery = "");
//               _fetchTasks();
//             },
//           )
//               : null,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)
//       )
//   );
//
//   Widget _buildFilters() => SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//           children: ["Tất cả", "Hôm nay", "Quá hạn", "Đã hoàn thành"].map((f) => GestureDetector(
//             onTap: () {
//               setState(() => _selectedFilter = f);
//               _fetchTasks();
//             },
//             child: _buildFilterChip(f, f == _selectedFilter),
//           )).toList()
//       )
//   );
//
//   Widget _buildFilterChip(String label, bool selected) => Container(
//       margin: const EdgeInsets.only(right: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       decoration: BoxDecoration(
//           color: selected ? primaryColor : surfaceLow,
//           borderRadius: BorderRadius.circular(30)
//       ),
//       child: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold))
//   );
//
//   Widget _buildListHeader() => Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         const Text("Danh sách", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
//         PopupMenuButton<String>(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           onSelected: (String value) {
//             setState(() => _selectedSort = value);
//             _fetchTasks();
//           },
//           itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//             const PopupMenuItem<String>(value: 'Mặc định', child: Text('Mặc định')),
//             const PopupMenuItem<String>(value: 'Ưu tiên: Cao -> Thấp', child: Text('Ưu tiên: Cao ➔ Thấp')),
//             const PopupMenuItem<String>(value: 'Ưu tiên: Thấp -> Cao', child: Text('Ưu tiên: Thấp ➔ Cao')),
//           ],
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
//             child: Row(
//               children: [
//                 Text(_selectedSort == 'Mặc định' ? "SẮP XẾP" : _selectedSort.toUpperCase(), style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
//                 Icon(Icons.arrow_drop_down, color: primaryColor, size: 16),
//               ],
//             ),
//           ),
//         )
//       ]
//   );
// }
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/task_service.dart';
<<<<<<< HEAD
=======
// import 'package:firebase_auth/firebase_auth.dart';
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> with WidgetsBindingObserver {
<<<<<<< HEAD
=======
  // --- HỆ MÀU & CONFIG ---
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceLow = const Color(0xFFEEF1F3);

  final TaskService _taskService = TaskService();

<<<<<<< HEAD
=======
  // DỮ LIỆU ĐỘNG
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
  int? currentUserId;
  List<dynamic> tasks = [];
  List<Map<String, dynamic>> dynamicCategories = [];
  bool isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
<<<<<<< HEAD
  String _selectedFilter = "Hôm nay";
=======
  String _selectedFilter = "Hôm nay"; // Đổi mặc định sang "Hôm nay" để đồng bộ với Dashboard
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
  String _selectedSort = "Mặc định";

  @override
  void initState() {
    super.initState();
<<<<<<< HEAD
    WidgetsBinding.instance.addObserver(this);
=======
    WidgetsBinding.instance.addObserver(this); // Lắng nghe vòng đời App
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
    _refreshAllData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
=======
  // Tự động làm mới khi mở lại App từ dưới nền (chống treo ngày cũ)
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
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

<<<<<<< HEAD
  Future<void> _refreshAllData() async {
    setState(() => isLoading = true);
    await _loadUserId();
=======
  // Tải lại toàn bộ dữ liệu (Tasks & Categories)
  Future<void> _refreshAllData() async {
    setState(() => isLoading = true);

    await _loadUserId();

>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
    if (currentUserId != null) {
      await Future.wait([
        _fetchTasks(),
        _loadCategories(),
      ]);
    }
<<<<<<< HEAD
=======

>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
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
      // 👉 THÊM DÒNG NÀY ĐỂ XEM BACKEND TRẢ VỀ CÁI GÌ:
      print("=== DỮ LIỆU TAB 'HÔM NAY': $data ===");
      if (mounted) setState(() => tasks = data);
    } catch (e) {
      debugPrint("Lỗi tải task từ Backend: $e");
    }
  }

<<<<<<< HEAD
  Future<void> _toggleTaskCompletion(int taskId) async {
    bool isCompletedNow = false;
=======
  // 2. Đảo trạng thái hoàn thành công việc (NÂNG CẤP OPTIMISTIC UI)
  Future<void> _toggleTaskCompletion(int taskId) async {
    bool isCompletedNow = false;

    // Bước 1: Cập nhật giao diện ngay lập tức cho mượt
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
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

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isCompletedNow ? '🎉 Đã đánh dấu hoàn thành!' : 'Đã hủy hoàn thành công việc'),
          duration: const Duration(milliseconds: 1200),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

<<<<<<< HEAD
    final res = await _taskService.toggleTaskComplete(taskId);
    if (res['status'] == 200) {
      if (_selectedFilter != "Hôm nay") {
        Future.delayed(const Duration(milliseconds: 500), () => _fetchTasks());
      }
    } else {
      _fetchTasks();
=======
    // Bước 2: Gọi API cập nhật ngầm. Nếu filter đang là "Tất cả" hoặc "Quá hạn" (những tab ẩn task đã xong)
// Bước 2: Gọi API cập nhật ngầm.
    final res = await _taskService.toggleTaskComplete(taskId);
    if (res['status'] == 200) {
      // --- SỬA ĐOẠN ĐIỀU KIỆN NÀY ---
      // Nếu là tab "Hôm nay", chúng ta KHÔNG gọi lại _fetchTasks() để task KHÔNG bị biến mất.
      // Chỉ gọi lại _fetchTasks() khi bạn đang ở tab "Tất cả" hoặc "Quá hạn" để lọc bớt task đi.
      if (_selectedFilter != "Hôm nay") {
        // Chờ 0.5 giây cho người dùng thấy hiệu ứng tick xanh rồi mới load lại danh sách
        Future.delayed(const Duration(milliseconds: 500), () => _fetchTasks());
      }
    } else {
      _fetchTasks(); // Rollback dữ liệu từ server nếu lỡ mạng bị lỗi
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
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

  void _confirmDelete(int taskId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa?", style: TextStyle(fontWeight: FontWeight.bold)),
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
            child: const Text("Xóa", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

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
                    title: Text(cat['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
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

  void _showAddCategoryDialog() {
    final catController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Danh mục mới", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
            controller: catController,
            autofocus: true,
            decoration: const InputDecoration(hintText: "Tên danh mục...")
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Hủy")),
          ElevatedButton(
            onPressed: () async {
              final textValue = catController.text.trim();
              if (textValue.isNotEmpty && currentUserId != null) {
                final res = await _taskService.addCategory(currentUserId!, textValue);
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
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white),
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
              currentUserId == null
                  ? const Center(child: Text("Vui lòng đăng nhập để xem dữ liệu"))
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
<<<<<<< HEAD
=======
    title: Text('Digital Curator', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 18)),
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
    centerTitle: true,
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
    if (tasks.isEmpty) {
      return Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
                _searchQuery.isNotEmpty ? "Không tìm thấy công việc nào" : "Chưa có công việc nào thỏa mãn",
                style: const TextStyle(color: Colors.grey)
            ),
          )
      );
    }
    return Column(children: tasks.map((task) => _buildTaskItem(task: task)).toList());
  }

  Widget _buildTaskItem({required Map task}) {
    String priority = task['priority']?.toString().toUpperCase() ?? "THẤP";
    bool isCompleted = task['is_completed'] == 1 || task['is_completed'] == true;

    // ==============================================
    // (MỚI) ĐẾM SỐ LƯỢNG SUBTASK
    // ==============================================
    List subtasks = task['subtasks'] ?? [];
    int totalSubtasks = subtasks.length;
    int completedSubtasks = subtasks.where((s) => s['is_completed'] == true || s['is_completed'] == 1).length;

    return InkWell(
      onTap: () async {
        final result = await Navigator.pushNamed(context, '/task_detail', arguments: task);
        if (result == true) _refreshAllData();
      },
      onLongPress: () => _confirmDelete(task['id'], task['title']),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isCompleted ? Colors.green.withOpacity(0.5) : Colors.transparent, width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _toggleTaskCompletion(task['id']),
              child: Icon(
                isCompleted ? Icons.check_circle : Icons.circle_outlined,
                color: isCompleted ? Colors.green : primaryColor,
                size: 26,
              ),
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
                        color: isCompleted ? Colors.grey : Colors.black87,
                      )
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 12, color: isCompleted ? Colors.grey : Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                          task['deadline'] != null ? task['deadline'].toString().substring(0, 16) : '',
                          style: TextStyle(color: isCompleted ? Colors.grey : Colors.grey[600], fontSize: 12)
                      ),
                    ],
                  ),

                  // ==============================================
                  // (MỚI) HIỂN THỊ BADGE ĐẾM SUBTASK NẾU CÓ
                  // ==============================================
                  if (totalSubtasks > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.account_tree_outlined, size: 14, color: isCompleted ? Colors.grey : primaryColor),
                          const SizedBox(width: 4),
                          Text(
                            '$completedSubtasks/$totalSubtasks',
                            style: TextStyle(
                              color: isCompleted ? Colors.grey : (completedSubtasks == totalSubtasks ? Colors.green : primaryColor),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            _buildSmallTag(priority, isCompleted ? Colors.grey[200]! : primaryColor.withOpacity(0.1), isCompleted ? Colors.grey : primaryColor),
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
        setState(() => _searchQuery = value);
        _fetchTasks();
      },
      decoration: InputDecoration(
          filled: true,
          fillColor: surfaceLow,
          hintText: "Tìm kiếm công việc...",
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
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
              setState(() => _selectedFilter = f);
              _fetchTasks();
            },
            child: _buildFilterChip(f, f == _selectedFilter),
          )).toList()
      )
  );

  Widget _buildFilterChip(String label, bool selected) => Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
          color: selected ? primaryColor : surfaceLow,
          borderRadius: BorderRadius.circular(30)
      ),
      child: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold))
  );

  Widget _buildListHeader() => Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Danh sách", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1)),
        PopupMenuButton<String>(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          onSelected: (String value) {
            setState(() => _selectedSort = value);
            _fetchTasks();
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(value: 'Mặc định', child: Text('Mặc định')),
            const PopupMenuItem<String>(value: 'Ưu tiên: Cao -> Thấp', child: Text('Ưu tiên: Cao ➔ Thấp')),
            const PopupMenuItem<String>(value: 'Ưu tiên: Thấp -> Cao', child: Text('Ưu tiên: Thấp ➔ Cao')),
          ],
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                Text(_selectedSort == 'Mặc định' ? "SẮP XẾP" : _selectedSort.toUpperCase(), style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold)),
                Icon(Icons.arrow_drop_down, color: primaryColor, size: 16),
              ],
            ),
          ),
        )
      ]
  );
}