import 'package:flutter/material.dart';

class TaskDetailPage extends StatelessWidget {
  const TaskDetailPage({super.key});

  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceLow = const Color(0xFFEEF1F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // 1. TOP APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Chi tiết công việc",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: Icon(Icons.settings_outlined, color: primaryColor), onPressed: () {}),
        ],
      ),

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                // 2. HERO INPUT SECTION
                const Text("TIÊU ĐỀ", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
                TextField(
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1),
                  decoration: InputDecoration(
                    hintText: "Tên công việc...",
                    hintStyle: TextStyle(color: Colors.grey[300]),
                    border: InputBorder.none,
                  ),
                ),

                const SizedBox(height: 32),

                // 3. AI INSIGHT CARD
                _buildAIAnalysisCard(),

                const SizedBox(height: 32),

                // 4. FORM FIELDS
                _buildLabel("MÔ TẢ CHI TIẾT"),
                const SizedBox(height: 8),
                TextField(
                  maxLines: 4,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: surfaceLow,
                    hintText: "Nhập ghi chú thêm...",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),

                const SizedBox(height: 24),
                _buildLabel("DANH MỤC"),
                const SizedBox(height: 8),
                _buildDropdownField("Dự án cá nhân"),

                const SizedBox(height: 24),
                _buildLabel("DEADLINE"),
                const SizedBox(height: 8),
                _buildDateTimePicker(),

                const SizedBox(height: 24),
                _buildLabel("MỨC ĐỘ ƯU TIÊN"),
                const SizedBox(height: 8),
                _buildPrioritySegmentedControl(),

                const SizedBox(height: 24),
                _buildReminderToggle(),

                const SizedBox(height: 32),

                // 5. SUBTASKS SECTION
                _buildSubtaskHeader(),
                const SizedBox(height: 16),
                _buildSubtaskItem("Nghiên cứu thị trường mục tiêu", true),
                _buildSubtaskItem("Thêm công việc phụ mới...", false),

                const SizedBox(height: 120), // Khoảng trống cho nút Lưu
              ],
            ),
          ),

          // 6. BOTTOM ACTION BAR (Lưu công việc)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 8,
                  shadowColor: primaryColor.withOpacity(0.4),
                ),
                child: const Text("Lưu công việc", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildLabel(String text) {
    return Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey));
  }

  Widget _buildAIAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: primaryColor.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border(left: BorderSide(color: primaryColor, width: 4))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome, color: primaryColor, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Phân tích AI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF4647D3))),
                SizedBox(height: 4),
                Text("Task này mất khoảng 2h để hoàn thành dựa trên các dữ liệu tương tự.", style: TextStyle(fontSize: 13, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: surfaceLow, borderRadius: BorderRadius.circular(30)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: [value, "Công việc", "Học tập"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) {},
        ),
      ),
    );
  }

  Widget _buildDateTimePicker() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: surfaceLow, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [Icon(Icons.calendar_today, color: primaryColor, size: 18), const SizedBox(width: 12), const Text("24 Tháng 5, 2024", style: TextStyle(fontWeight: FontWeight.w500))]),
          Text("14:30", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPrioritySegmentedControl() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: surfaceLow, borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          Expanded(child: _buildPriorityTab("Thấp", false)),
          Expanded(child: _buildPriorityTab("Trung bình", true)),
          Expanded(child: _buildPriorityTab("Cao", false)),
        ],
      ),
    );
  }

  Widget _buildPriorityTab(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(20), boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null),
      child: Center(child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? primaryColor : Colors.grey))),
    );
  }

  Widget _buildReminderToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [const Icon(Icons.notifications_active_outlined, color: Colors.grey), const SizedBox(width: 12), const Text("Nhắc nhở", style: TextStyle(fontWeight: FontWeight.w500))]),
        Switch(value: true, onChanged: (v) {}, activeColor: primaryColor),
      ],
    );
  }

  Widget _buildSubtaskHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Công việc phụ (Subtasks)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
          child: const Icon(Icons.add, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildSubtaskItem(String text, bool isDone) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)]),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Icon(isDone ? Icons.check_box : Icons.check_box_outline_blank, color: isDone ? primaryColor : Colors.grey[300]),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: isDone ? Colors.black : Colors.grey))),
        ],
      ),
    );
  }
}