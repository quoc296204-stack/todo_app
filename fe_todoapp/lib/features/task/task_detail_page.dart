import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/task_service.dart';

class TaskDetailPage extends StatefulWidget {
  const TaskDetailPage({super.key});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color textMain = const Color(0xFF2C2F31);

  final titleController = TextEditingController();
  final descController = TextEditingController();

  int? currentUserId;
  List<Map<String, dynamic>> dynamicCategories = [];

  // ==============================================
  // (MỚI) Biến chứa danh sách việc con
  // ==============================================
  List<dynamic> currentSubtasks = [];

  String selectedCategory = "";
  String selectedPriority = "Trung bình";
  DateTime startTime = DateTime.now();
  DateTime deadline = DateTime.now().add(const Duration(hours: 4));
  bool isReminder = true;
  bool isLoading = false;

  Map? taskToEdit;
  final TaskService _taskService = TaskService();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _loadUserId();
    if (currentUserId != null) {
      await _loadCategories();
    }
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUserId = prefs.getInt('userId');
    });
  }

  Future<void> _loadCategories() async {
    if (currentUserId == null) return;

    final result = await _taskService.getCategories(currentUserId!);
    if (result['status'] == 200 && mounted) {
      setState(() {
        dynamicCategories = List<Map<String, dynamic>>.from(result['data']);

        if (taskToEdit == null && dynamicCategories.isNotEmpty && selectedCategory.isEmpty) {
          selectedCategory = dynamicCategories[0]['name'];
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map && taskToEdit == null) {
      taskToEdit = args;
      titleController.text = taskToEdit!['title'] ?? "";
      descController.text = taskToEdit!['description'] ?? "";
      selectedCategory = taskToEdit!['category'] ?? "";
      selectedPriority = taskToEdit!['priority'] ?? "Trung bình";
      startTime = DateTime.parse(taskToEdit!['start_time']);
      deadline = DateTime.parse(taskToEdit!['deadline']);

      // ==============================================
      // (MỚI) Load subtasks từ Task được truyền sang
      // ==============================================
      if (taskToEdit!['subtasks'] != null) {
        currentSubtasks = List.from(taskToEdit!['subtasks']);
      }
    }
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: isStart ? startTime : deadline,
      firstDate: DateTime(2000), lastDate: DateTime(2100),
    );
    if (d == null) return;

    if (!mounted) return;
    final TimeOfDay? t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? startTime : deadline),
    );
    if (t == null) return;

    setState(() {
      final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      isStart ? startTime = dt : deadline = dt;
    });
  }

  Future<void> onSaveTask() async {
    if (currentUserId == null) {
      _showSnackBar("Lỗi: Không tìm thấy tài khoản đăng nhập!", isError: true);
      return;
    }

    if (titleController.text.trim().isEmpty) {
      _showSnackBar("Vui lòng nhập tiêu đề", isError: true);
      return;
    }
    if (selectedCategory.isEmpty) {
      _showSnackBar("Vui lòng chọn hoặc thêm danh mục trước", isError: true);
      return;
    }

    setState(() => isLoading = true);
    final taskData = {
      "title": titleController.text.trim(),
      "description": descController.text.trim(),
      "category": selectedCategory,
      "start_time": DateFormat('yyyy-MM-dd HH:mm:ss').format(startTime),
      "deadline": DateFormat('yyyy-MM-dd HH:mm:ss').format(deadline),
      "priority": selectedPriority,
      "is_reminder": isReminder,
    };

    try {
      Map<String, dynamic> result;
      if (taskToEdit == null) {
        result = await _taskService.createTask(currentUserId!, taskData);
      } else {
        result = await _taskService.updateTask(taskToEdit!['id'], taskData);
      }

      if (!mounted) return;
      setState(() => isLoading = false);

      if (result['status'] == 201 || result['status'] == 200) {
        _showSnackBar("Lưu thành công!", isError: false);
        Navigator.pop(context, true);
      } else {
        _showSnackBar(result['body']?['detail'] ?? "Lỗi lưu dữ liệu");
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        _showSnackBar("Lỗi kết nối Server!");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildHeroInput(),
            const SizedBox(height: 32),
            _buildFormSection(),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: bgColor.withOpacity(0.8), elevation: 0,
    title: Text(taskToEdit == null ? "Thêm công việc" : "Chi tiết công việc", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
  );

  Widget _buildHeroInput() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text("TIÊU ĐỀ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
      TextField(controller: titleController, style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: textMain, letterSpacing: -1), decoration: const InputDecoration(hintText: "Tên công việc...", border: InputBorder.none)),
    ],
  );

  Widget _buildFormSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [

      // ==============================================
      // (MỚI) KHU VỰC VẼ SUBTASK NGAY DƯỚI TIÊU ĐỀ
      // ==============================================
      _buildSubtaskList(),

      _buildLabel("DANH MỤC"),
      _buildCategorySelector(),
      const SizedBox(height: 32),
      _buildLabel("MÔ TẢ CHI TIẾT"),
      _buildCard(TextField(controller: descController, maxLines: 4, decoration: const InputDecoration(hintText: "Thêm ghi chú...", border: InputBorder.none))),
      const SizedBox(height: 24),
      _buildLabel("THỜI GIAN & NHẮC NHỞ"),
      _buildCard(Column(children: [
        _buildTimeRow("Bắt đầu", startTime, () => _selectDateTime(context, true)),
        const Divider(height: 32),
        _buildTimeRow("Deadline", deadline, () => _selectDateTime(context, false)),
      ])),
      const SizedBox(height: 24),
      _buildLabel("MỨC ĐỘ ƯU TIÊN"),
      _buildPrioritySelector(),
    ],
  );

  // ==============================================
  // (MỚI) HÀM VẼ DANH SÁCH VIỆC CON & THANH TIẾN ĐỘ
  // ==============================================
  Widget _buildSubtaskList() {
    if (currentSubtasks.isEmpty) return const SizedBox.shrink();

    int total = currentSubtasks.length;
    int completed = currentSubtasks.where((s) => s['is_completed'] == true || s['is_completed'] == 1).length;
    double progress = total == 0 ? 0 : completed / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildLabel("CÁC BƯỚC THỰC HIỆN"),
            Text('$completed/$total', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          color: progress == 1.0 ? Colors.green : primaryColor,
          minHeight: 6,
          borderRadius: BorderRadius.circular(10),
        ),
        const SizedBox(height: 16),

        // Vẽ danh sách Checkbox
        ...currentSubtasks.map((subtask) {
          bool isDone = subtask['is_completed'] == true || subtask['is_completed'] == 1;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.green,
              checkColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              title: Text(
                subtask['title'] ?? '',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                  color: isDone ? Colors.grey : textMain,
                ),
              ),
              value: isDone,
              onChanged: (bool? val) {
                // UI cập nhật lập tức
                setState(() {
                  subtask['is_completed'] = val ?? false;
                });

                // Gọi ngầm hàm cập nhật lên Backend (Không cần await để UI khỏi bị đơ)
                _taskService.toggleSubTaskComplete(subtask['id']);
              },
            ),
          );
        }).toList(),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildCategorySelector() {
    if (dynamicCategories.isEmpty) {
      return const Text("Chưa có danh mục. Vui lòng thêm ở trang Task.", style: TextStyle(color: Colors.red, fontSize: 12, fontStyle: FontStyle.italic));
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: dynamicCategories.map((cat) => ChoiceChip(
        label: Text(cat['name']),
        selected: selectedCategory == cat['name'],
        onSelected: (val) {
          if (val) setState(() => selectedCategory = cat['name']);
        },
        selectedColor: primaryColor,
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
            color: selectedCategory == cat['name'] ? Colors.white : textMain,
            fontSize: 12
        ),
      )).toList(),
    );
  }

  Widget _buildPrioritySelector() => Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFFEEF1F3), borderRadius: BorderRadius.circular(99)), child: Row(children: ["Thấp", "Trung bình", "Cao"].map((p) => Expanded(child: GestureDetector(onTap: () => setState(() => selectedPriority = p), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: selectedPriority == p ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(99)), child: Center(child: Text(p, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: selectedPriority == p ? primaryColor : Colors.grey))))))).toList()));

  Widget _buildBottomAction() => Container(padding: const EdgeInsets.fromLTRB(24, 16, 24, 40), color: bgColor.withOpacity(0.9), child: SizedBox(width: double.infinity, height: 60, child: ElevatedButton(onPressed: isLoading ? null : onSaveTask, style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))), child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Lưu công việc", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))));

  Widget _buildLabel(String text) => Padding(padding: const EdgeInsets.only(left: 4, bottom: 12), child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)));
  Widget _buildCard(Widget child) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: child);
  Widget _buildTimeRow(String label, DateTime time, VoidCallback onTap) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Icon(Icons.access_time, size: 18, color: primaryColor), const SizedBox(width: 12), Text(label, style: const TextStyle(fontWeight: FontWeight.w600))]), Text(DateFormat('dd/MM, HH:mm').format(time), style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))]));
  void _showSnackBar(String msg, {bool isError = true}) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: isError ? Colors.redAccent : Colors.green, behavior: SnackBarBehavior.floating)); }
}