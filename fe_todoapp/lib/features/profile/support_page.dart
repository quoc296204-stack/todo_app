import 'package:flutter/material.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  // --- PALETTE MÀU ---
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceLow = const Color(0xFFEEF1F3);
  final Color secondaryColor = const Color(0xFF4650B9);
  final Color tertiaryColor = const Color(0xFFF8A010);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // 1. TOP APP BAR
      appBar: AppBar(
        backgroundColor: bgColor.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6366F1)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Hỗ trợ",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: surfaceLow, shape: BoxShape.circle),
              child: const Icon(Icons.contact_support_outlined, color: Colors.grey, size: 20),
            ),
          )
        ],
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // 2. SEARCH SECTION
            _buildSearchBox(),

            const SizedBox(height: 48),

            // 3. FAQ SECTION (ACCORDIONS)
            const Text("Câu hỏi thường gặp", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            const SizedBox(height: 16),
            _buildFAQItem("Cách tạo công việc mới?", "Bạn có thể nhấn vào nút '+' ở màn hình chính hoặc sử dụng lệnh giọng nói. Hệ thống sẽ tự động phân loại công việc."),
            _buildFAQItem("Cách dùng AI gợi ý?", "AI của Digital Curator phân tích thói quen và thời điểm làm việc hiệu quả nhất của bạn để đưa ra các lộ trình cá nhân hóa."),
            _buildFAQItem("Quản lý thói quen...", "Bạn có thể thiết lập mục tiêu hàng ngày. Chúng tôi cung cấp biểu đồ trực quan giúp bạn duy trì động lực."),

            const SizedBox(height: 40),

            // // 4. AI INSIGHT BOX
            // _buildTeamQuote(),

            const SizedBox(height: 48),

            // 5. FEEDBACK FORM
            _buildFeedbackForm(),

            const SizedBox(height: 40),

            // 6. CONTACT SECTION
            Row(
              children: [
                Expanded(child: _buildContactCard(Icons.mail, "Email", "hello", const Color(0xFFCBCEFF))),
                const SizedBox(width: 12),
                Expanded(child: _buildContactCard(Icons.call, "Hotline", "1900 8888", const Color(0xFFFFF0E3))),
              ],
            ),

            const SizedBox(height: 48),
            const Center(
              child: Column(
                children: [
                  Text("Phiên bản 1.0", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                  SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),

      // 7. BOTTOM NAV
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: surfaceLow, borderRadius: BorderRadius.circular(16)),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: "Tìm kiếm câu hỏi...",
          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFAQItem(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        shape: const Border(),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(content, style: const TextStyle(color: Colors.black54, height: 1.5, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  // Widget _buildTeamQuote() {
  //   // return Container(
  //   //   // padding: const EdgeInsets.all(24),
  //   //   // decoration: BoxDecoration(
  //   //   //   color: Colors.white.withOpacity(0.6),
  //   //   //   borderRadius: BorderRadius.circular(16),
  //   //   //   border: Border(left: BorderSide(color: primaryColor, width: 4)),
  //   //   ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       // children: [
  //       //   Icon(Icons.auto_awesome, color: primaryColor, size: 24),
  //       //   const SizedBox(height: 12),
  //       //   const Text(
  //       //     "\"Chúng tôi luôn lắng nghe ý kiến từ bạn để Digital Curator ngày càng hoàn thiện hơn.\"",
  //       //     style: TextStyle(fontStyle: FontStyle.italic, color: Colors.black87, fontSize: 14, height: 1.5),
  //       //   ),
  //       //   const SizedBox(height: 8),
  //       //   Text("ĐỘI NGŨ SÁNG TẠO", style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
  //       // ],
  //   //   ),
  //   // );
  // }

  Widget _buildFeedbackForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: surfaceLow, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Gửi phản hồi", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text("Hãy cho chúng tôi biết vấn đề của bạn.", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 24),
          _buildFormLabel("Loại phản hồi"),
          _buildDropdown(),
          const SizedBox(height: 16),
          _buildFormLabel("Tiêu đề"),
          _buildSmallTextField("Tóm tắt yêu cầu..."),
          const SizedBox(height: 16),
          _buildFormLabel("Nội dung chi tiết"),
          _buildSmallTextField("Mô tả kỹ hơn...", maxLines: 4),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.attach_file, size: 18),
                  label: const Text("Ảnh", style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text("Gửi phản hồi", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: "Lỗi ứng dụng",
          isExpanded: true,
          items: ["Lỗi ứng dụng", "Góp ý"].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
          onChanged: (v) {},
        ),
      ),
    );
  }

  Widget _buildSmallTextField(String hint, {int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(hintText: hint, border: InputBorder.none, hintStyle: const TextStyle(fontSize: 14, color: Colors.grey)),
      ),
    );
  }

  Widget _buildContactCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: primaryColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 15, bottom: 35),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(45))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(context, Icons.home_outlined, "Home", route: '/dashboard'),
          _buildNavItem(context, Icons.check_circle_outline, "Tasks", route: '/tasks'),
          _buildNavItem(context, Icons.repeat, "Habits", route: '/habits'),
          _buildNavItem(context, Icons.auto_awesome_outlined, "AI", route: '/ai'),
          _buildNavItem(context, Icons.person, "Profile", isActive: true, route: '/profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, {bool isActive = false, String? route}) {
    return InkWell(
      onTap: () { if (route != null) Navigator.pushNamed(context, route); },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? primaryColor : Colors.grey[400], size: 28),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: isActive ? primaryColor : Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}