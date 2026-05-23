import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:shared_preferences/shared_preferences.dart'; // Đã thêm thư viện này
=======
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
import 'package:fe_todoapp/data/services/ai_service.dart';
import 'package:fe_todoapp/data/services/task_service.dart';

class AiPage extends StatefulWidget {
  const AiPage({super.key});

  @override
  State<AiPage> createState() => _AiPageState();
}

class _AiPageState extends State<AiPage> {
  // --- HỆ PALETTE MÀU CHỦ ĐẠO UX ---
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceColor = Colors.white;

  // --- BỘ ĐIỀU KHIỂN TEXT FORM ---
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  final AIApiService _aiApiService = AIApiService();
  final TaskService _taskService = TaskService();

<<<<<<< HEAD
  // Đã xóa currentMockUserId = 1, thay bằng biến này
  int _currentUserId = 3;

=======
  int currentMockUserId = 1;
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasParsedData = false;
  String _aiFeedbackMessage = "Tôi đã sẵn sàng. Hãy nhập một kế hoạch bằng ngôn ngữ tự nhiên ở ô phía dưới để tôi xử lý nhé!";

  String _priority = "Trung bình";
  String _startTime = "";
  String _deadline = "";
  List<dynamic> _subtasks = [];

  @override
<<<<<<< HEAD
  void initState() {
    super.initState();
    _loadUserId(); // Tải ID người dùng ngay khi mở trang
  }

  // Hàm động lấy User ID thực tế từ Local Storage
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final rawUserId = prefs.get('userId');
    if (rawUserId != null) {
      setState(() {
        _currentUserId = int.parse(rawUserId.toString());
      });
    }
  }

  @override
=======
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
  void dispose() {
    _inputController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  /// 1. Kích hoạt gửi văn bản ngôn ngữ tự nhiên lên hệ thống AI FastAPI
  Future<void> _submitNaturalLanguageTask() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

<<<<<<< HEAD
    FocusScope.of(context).unfocus();
=======
    FocusScope.of(context).unfocus(); // Hạ bàn phím ảo tránh tràn layout
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
    setState(() {
      _isLoading = true;
      _hasParsedData = false;
      _aiFeedbackMessage = "Hệ thống AI đang phân tích cú pháp từ vựng...";
    });

    try {
<<<<<<< HEAD
      // Đã sử dụng _currentUserId thực tế
      final result = await _aiApiService.processNLPTask(text, _currentUserId);

      if (result != null && result["title"] != null && result["title"].toString().isNotEmpty) {
        setState(() {
=======
      final result = await _aiApiService.processNLPTask(text, currentMockUserId);

      if (result != null && result["title"] != null && result["title"].toString().isNotEmpty) {
        setState(() {
          // Nạp dữ liệu sạch thu được gán thẳng vào các trường điều khiển Form
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
          _titleController.text = result["title"] ?? "";
          _descController.text = result["description"] ?? "";
          _categoryController.text = result["category"] ?? "Cá nhân";

          _priority = result["priority"] ?? "Trung bình";
          _startTime = result["start_time"] ?? DateTime.now().toString().substring(0, 16);
          _deadline = result["deadline"] ?? DateTime.now().toString().substring(0, 16);
          _subtasks = List.from(result["subtasks"] ?? []);

<<<<<<< HEAD
          _hasParsedData = true;
=======
          _hasParsedData = true; // Kích hoạt render Form chi tiết cố định lên trang
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
          _aiFeedbackMessage = "Đã bóc tách xong ý định! Bạn có thể tinh chỉnh dữ liệu trong Form phía dưới trước khi lưu.";
        });
      } else {
        throw Exception("Kết quả bóc tách rỗng hoặc không khớp mẫu từ khóa.");
      }
    } catch (e) {
      setState(() {
        _aiFeedbackMessage = "⚠️ Gặp sự cố phân tích luồng: ${e.toString().replaceAll("Exception: ", "")}";
      });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

<<<<<<< HEAD
  /// 2. Đồng bộ đóng gói Map Payload truyền tham số vị trí chuẩn
=======
  /// 2. Đồng bộ đóng gói Map Payload truyền tham số vị trí chuẩn (int, Map) cho createTask gốc của bạn
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
  Future<void> _saveTaskToDatabase() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❌ Tiêu đề tác vụ không được để trống!")),
      );
      return;
    }

    setState(() { _isSaving = true; });

    Map<String, dynamic> taskPayload = {
      "title": _titleController.text.trim(),
      "description": _descController.text.trim(),
      "category": _categoryController.text.trim(),
      "priority": _priority,
      "start_time": _startTime,
      "deadline": _deadline,
      "subtasks": _subtasks
    };

    try {
<<<<<<< HEAD
      // Đã sử dụng _currentUserId thực tế để lưu task vào đúng giỏ của người dùng
      Map<String, dynamic> response = await _taskService.createTask(_currentUserId, taskPayload);
=======
      // Gọi chuẩn xác hàm nhận diện Map gốc: Future<Map<String, dynamic>> createTask(int userId, Map<String, dynamic> taskData)
      Map<String, dynamic> response = await _taskService.createTask(currentMockUserId, taskPayload);
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a

      if (response.containsKey("id") || response.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🎉 Đã tạo và đồng bộ kế hoạch thành công vào hệ thống MySQL!")),
        );
        _inputController.clear();
<<<<<<< HEAD
=======
        // Quay về trang danh sách Task chính để re-render dữ liệu mới tinh vừa tạo
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
        Navigator.pushReplacementNamed(context, '/tasks');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Gặp sự cố khi ghi nhận dữ liệu: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() { _isSaving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        title: Row(
          children: [
<<<<<<< HEAD
            const SizedBox(width: 12),
=======
            // Triệt tiêu vĩnh viễn lỗi HandshakeException mạng bằng CircleAvatar chứa Icon cục bộ
            CircleAvatar(
              radius: 19,
              backgroundColor: primaryColor.withOpacity(0.1),
              child: Icon(Icons.face, color: primaryColor, size: 22),
            ),
            const SizedBox(width: 12),
            Text('Digital Curator AI', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w900, fontSize: 18)),
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildInsightCard(
                      title: "Trạng Thái Xử Lý Hệ Thống",
                      desc: _aiFeedbackMessage,
                      label: "BẢNG TIN ĐIỀU KHIỂN",
                      icon: Icons.analytics_outlined,
                      accentColor: primaryColor,
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (_hasParsedData && !_isLoading) ...[
                      const SizedBox(height: 20),
                      _buildReviewFormArea(),
                      const SizedBox(height: 30),
                    ],
                  ],
                ),
              ),
            ),
            _buildPromptInputArea(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("TRỢ LÝ AI TOÀN DIỆN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryColor, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        const Text("Phân rã kế hoạch tự động", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -1)),
      ],
    );
  }

  Widget _buildReviewFormArea() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(controller: _titleController, decoration: const InputDecoration(labelText: "Tiêu đề công việc", icon: Icon(Icons.title, size: 18)), style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(controller: _descController, decoration: const InputDecoration(labelText: "Nội dung mô tả chi tiết", icon: Icon(Icons.description, size: 18))),
          const SizedBox(height: 10),
          TextField(controller: _categoryController, decoration: const InputDecoration(labelText: "Danh mục", icon: Icon(Icons.category, size: 18))),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _priority,
            decoration: const InputDecoration(labelText: "Mức độ ưu tiên", icon: Icon(Icons.star_border, size: 18)),
            items: const [
              DropdownMenuItem(value: "Thấp", child: Text("Thấp")),
              DropdownMenuItem(value: "Trung bình", child: Text("Trung bình")),
              DropdownMenuItem(value: "Cao", child: Text("Cao")),
            ],
            onChanged: (val) { if (val != null) setState(() { _priority = val; }); },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.play_circle_outline, size: 20),
            title: const Text("Thời gian bắt đầu", style: TextStyle(fontSize: 12, color: Colors.grey)),
            subtitle: Text(_startTime, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
            dense: true,
            onTap: () async {
              TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
              if (picked != null) {
                setState(() { _startTime = "${DateTime.now().toString().split(' ')[0]} ${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}"; });
              }
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.error_outline, size: 20, color: Colors.redAccent),
            title: const Text("Hạn chót hoàn thành (Deadline)", style: TextStyle(fontSize: 12, color: Colors.grey)),
            subtitle: Text(_deadline, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
            dense: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 1)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
              if (pickedDate != null) {
                setState(() { _deadline = "${pickedDate.toString().split(' ')[0]} 23:59"; });
              }
            },
          ),

<<<<<<< HEAD
=======
          // Bộ lọc tự động ẩn/hiện phân rã việc con Subtask dựa trên kiểm tra mảng rỗng
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
          if (_subtasks.isNotEmpty) ...[
            const Divider(),
            const Text("Các bước triển khai (AI tự phân rã):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 6),
            ..._subtasks.map((sub) {
              return CheckboxListTile(
                title: Text(sub["title"], style: const TextStyle(fontSize: 12)),
                value: sub["is_checked"] ?? false,
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: primaryColor,
                onChanged: (val) { setState(() { sub["is_checked"] = val; }); },
              );
            }).toList(),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
              onPressed: _isSaving ? null : _saveTaskToDatabase,
              child: _isSaving
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Xác nhận tạo kế hoạch", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptInputArea() {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 20),
      decoration: BoxDecoration(color: surfaceColor, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -2))]),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              enabled: !_isLoading && !_isSaving,
              decoration: InputDecoration(
                hintText: "Nhập text tự nhiên (Ví dụ: Mai 8h làm slide gấp)...",
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                filled: true,
                fillColor: bgColor,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              onSubmitted: (_) => _submitNaturalLanguageTask(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isLoading || _isSaving ? null : _submitNaturalLanguageTask,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
<<<<<<< HEAD
              child: const Icon(Icons.send, color: Colors.white, size: 20),
=======
              child: const Icon(Icons.bolt, color: Colors.white, size: 20),
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({required String title, required String desc, required String label, required IconData icon, required Color accentColor}) {
    return Container(
      decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: accentColor),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)), Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)), Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black54))])),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(40)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20)]),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home_outlined, "Home", false, route: '/dashboard'),
          _buildNavItem(context, Icons.check_circle_outline, "Tasks", false, route: '/tasks'),
          _buildNavItem(context, Icons.repeat, "Habits", false, route: '/habits'),
          _buildNavItem(context, Icons.auto_awesome, "AI", true, route: '/ai'),
          _buildNavItem(context, Icons.person_outline, "Profile", false, route: '/profile'),
        ],
      ),
    );
  }

  // Đã sửa lại lỗi đứt gãy ở hàm này để Flutter không báo đỏ
  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, {String? route}) {
    return InkWell(
      onTap: () { if (route != null && ModalRoute.of(context)?.settings.name != route) Navigator.pushReplacementNamed(context, route); },
<<<<<<< HEAD
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? primaryColor : Colors.grey[400], size: 26),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isActive ? primaryColor : Colors.grey[400], fontSize: 9, fontWeight: FontWeight.bold))
          ]
      ),
=======
      child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: isActive ? primaryColor : Colors.grey[400], size: 26), const SizedBox(height: 4), Text(label, style: TextStyle(color: isActive ? primaryColor : Colors.grey[400], fontSize: 9, fontWeight: FontWeight.bold))]),
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
    );
  }
}