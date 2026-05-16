import 'package:flutter/material.dart';

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceLow = const Color(0xFFEEF1F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        // Dùng .withValues nếu Flutter của bạn phiên bản quá mới, hoặc giữ .withOpacity nếu dev bình thường
        backgroundColor: bgColor.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6366F1)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Cài đặt",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Center(
              child: Text("DC.", style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w900, fontSize: 18)),
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
            const Text("Chỉnh sửa hồ sơ",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1)), // Đã fix FontWeight
            const Text("Cập nhật thông tin cá nhân và quản lý bảo mật tài khoản của bạn.",
                style: TextStyle(color: Colors.grey, fontSize: 14)),

            const SizedBox(height: 32),
            _buildProfileImagePicker(),
            const SizedBox(height: 32),

            _buildFormSection(
              title: "Thông tin cơ bản",
              icon: Icons.person, // Có icon
              children: [
                _buildInputField("Họ và tên", "Nguyễn Minh Anh"),
                _buildInputField("Email", "minhanh.dc@example.com"),
                _buildInputField("Số điện thoại", "090 123 4567"),
                _buildInputField("Ngày sinh", "1995-08-24"),
              ],
            ),

            const SizedBox(height: 24),

            _buildFormSection(
              title: "Nghề nghiệp & Giới thiệu",
              icon: Icons.work, // Có icon
              children: [
                _buildInputField("Vị trí hiện tại", "UI/UX Designer"),
                _buildInputField("Giới tính", "Nữ", isDropdown: true),
                _buildInputField("Mô tả ngắn", "Một người đam mê sáng tạo...", isTextArea: true),
              ],
            ),

            const SizedBox(height: 24),

            // // PHẦN PASSWORD - ĐÃ FIX THÊM ICON ĐỂ KHÔNG LỖI
            // _buildFormSection(
            //   title: "Đổi mật khẩu",
            //   icon: Icons.lock_outline, // Đã thêm tham số icon bắt buộc vào đây
            //   isPasswordSection: true,
            //   children: [
            //     _buildInputField("Mật khẩu hiện tại", "••••••••", isPassword: true),
            //     _buildInputField("Mật khẩu mới", "••••••••", isPassword: true),
            //     _buildInputField("Xác nhận mật khẩu", "••••••••", isPassword: true),
            //   ],
            // ),

            const SizedBox(height: 40),
            _buildActionButtons(context),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET CON (GIỮ NGUYÊN NHƯNG ĐÃ SOÁT LỖI) ---

  Widget _buildProfileImagePicker() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              image: const DecorationImage(
                image: NetworkImage('https://via.placeholder.com/150'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
            child: const Icon(Icons.photo_camera, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection({required String title, required IconData icon, required List<Widget> children, bool isPasswordSection = false}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String value, {bool isPassword = false, bool isDropdown = false, bool isTextArea = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: isDropdown
                ? DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: [value, "Nam", "Khác"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (v){},
              ),
            )
                : TextField(
              obscureText: isPassword,
              maxLines: isTextArea ? 4 : 1,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: Text("Hủy", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)))),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
            child: const Text("Lưu thay đổi", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}