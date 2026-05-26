import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/task_service.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  // --- HỆ MÀU ĐỒNG BỘ VỚI TASK PAGE ---
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceLow = const Color(0xFFEEF1F3);

  final TaskService _taskService = TaskService();
  final TextEditingController _categoryController = TextEditingController();

  int? currentUserId;
  List<Map<String, dynamic>> categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getInt('userId');
    });
  }

  Future<void> _refreshData() async {
    setState(() => isLoading = true);
    await _loadUserId();
    if (currentUserId != null) {
      await _fetchCategories();
    }
    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _fetchCategories() async {
    final result = await _taskService.getCategories(currentUserId!);
    if (result['status'] == 200 && mounted) {
      setState(() {
        categories = List<Map<String, dynamic>>.from(result['data']);
      });
    }
  }

  // Xử lý thêm danh mục
  Future<void> _handleAddCategory() async {
    final name = _categoryController.text.trim();
    if (name.isEmpty || currentUserId == null) return;

    // Ẩn bàn phím
    FocusScope.of(context).unfocus();

    final result = await _taskService.addCategory(currentUserId!, name);
    print("🚀 Dữ liệu Backend trả về: $result"); // Thêm dòng này

    if (result['status'] == 200 || result['status'] == 201) {
      _categoryController.clear();
      _fetchCategories();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đã thêm danh mục mới thành công!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lỗi khi thêm danh mục mới")),
      );
    }
  }

  // Xử lý xóa danh mục kèm dialog xác nhận
  Future<void> _handleDeleteCategory(int catId, String catName) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Xóa danh mục", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Bạn có chắc chắn muốn xóa danh mục '$catName' không? Các công việc thuộc danh mục này có thể bị ảnh hưởng."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("HỦY", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("XÓA", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _taskService.deleteCategory(catId);
      if (result['success'] == true) {
        _fetchCategories();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã xóa danh mục")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không thể xóa danh mục này!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Quản lý danh mục',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: currentUserId == null
          ? const Center(child: Text("Vui lòng đăng nhập"))
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Ô nhập thêm danh mục mới
            _buildAddCategoryInput(),
            const SizedBox(height: 28),
            const Text(
              "Danh mục hiện tại",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            // Danh sách hiển thị danh mục
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : categories.isEmpty
                  ? const Center(child: Text("Chưa có danh mục nào"))
                  : RefreshIndicator(
                onRefresh: _fetchCategories,
                child: ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return _buildCategoryItem(cat);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget ô nhập danh mục mới tinh tế
  Widget _buildAddCategoryInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: TextField(
                controller: _categoryController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: "Tên danh mục mới...",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: _handleAddCategory,
            icon: Icon(Icons.add_circle, color: primaryColor, size: 32),
          ),
        ],
      ),
    );
  }

  // Widget từng dòng danh mục
  Widget _buildCategoryItem(Map<String, dynamic> cat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.folder_open_outlined, color: primaryColor, size: 22),
              const SizedBox(width: 14),
              Text(
                cat['name'] ?? 'Không tên',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
          IconButton(
            onPressed: () => _handleDeleteCategory(cat['id'], cat['name'] ?? ''),
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}