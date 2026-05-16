import 'package:flutter/material.dart';
import '../../../data/services/auth_service.dart';
import '../../../core/constants.dart'; // Đảm bảo có AppConfig để lấy IP



class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);

  final oldPwdController = TextEditingController();
  final newPwdController = TextEditingController();
  final confirmPwdController = TextEditingController();

  bool isLoading = false;
  bool isOldVisible = false;
  bool isNewVisible = false;
  bool isConfirmVisible = false; // Thêm biến này để quản lý xác nhận mật khẩu

  final AuthService _authService = AuthService();

  Future<void> handleChangePassword() async {
    // 1. Kiểm tra rỗng
    if (oldPwdController.text.isEmpty || newPwdController.text.isEmpty) {
      _showSnackBar("Vui lòng nhập đầy đủ thông tin", isError: true);
      return;
    }

    // 2. Kiểm tra khớp mật khẩu mới
    if (newPwdController.text != confirmPwdController.text) {
      _showSnackBar("Mật khẩu xác nhận không khớp", isError: true);
      return;
    }

    // 3. Kiểm tra độ dài mật khẩu (theo chuẩn đồ án)
    if (newPwdController.text.length < 6) {
      _showSnackBar("Mật khẩu mới phải có ít nhất 6 ký tự", isError: true);
      return;
    }

    setState(() => isLoading = true);

    // Gọi API từ AuthService (Giả định userId = 1)
    final result = await _authService.changePassword(
        1,
        oldPwdController.text.trim(),
        newPwdController.text.trim()
    );

    if (!mounted) return;
    setState(() => isLoading = false);

    if (result['status'] == 200) {
      _showSnackBar("Đổi mật khẩu thành công!", isError: false);
      // Đợi 1 chút để user kịp thấy SnackBar rồi mới quay lại
      Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
    } else {
      // Hiển thị lỗi từ Backend (ví dụ: "Mật khẩu cũ không chính xác")
      _showSnackBar(result['body']?['detail'] ?? "Đổi mật khẩu thất bại", isError: true);
    }
  }

  void _showSnackBar(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            _buildIllustration(),
            const SizedBox(height: 48),

            _buildInputField("Mật khẩu hiện tại", oldPwdController, isOldVisible,
                    () => setState(() => isOldVisible = !isOldVisible)),
            const SizedBox(height: 16),
            _buildInputField("Mật khẩu mới", newPwdController, isNewVisible,
                    () => setState(() => isNewVisible = !isNewVisible)),
            const SizedBox(height: 16),
            _buildInputField("Xác nhận mật khẩu mới", confirmPwdController, isConfirmVisible,
                    () => setState(() => isConfirmVisible = !isConfirmVisible)),

            const SizedBox(height: 48),
            _buildSubmitButton(),
            const SizedBox(height: 20),
            TextButton(
                onPressed: () {},
                child: Text("Quên mật khẩu?", style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600))
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.black),
    leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
    title: const Text("Thay đổi mật khẩu", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
  );

  Widget _buildIllustration() => Column(
    children: [
      Container(
        width: 96, height: 96,
        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(Icons.lock_reset_rounded, size: 48, color: primaryColor),
      ),
      const SizedBox(height: 24),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "Đảm bảo tài khoản luôn an toàn bằng cách dùng mật khẩu mạnh và không chia sẻ cho người khác.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      )
    ],
  );

  Widget _buildInputField(String label, TextEditingController controller, bool isVisible, VoidCallback toggle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFFEEF1F3), borderRadius: BorderRadius.circular(16)),
          child: TextField(
            controller: controller,
            obscureText: !isVisible, // Sửa lỗi logic hiển thị mật khẩu
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Nhập mật khẩu",
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
              suffixIcon: IconButton(
                icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off, size: 20, color: Colors.grey),
                onPressed: toggle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity,
    height: 60,
    child: ElevatedButton(
      onPressed: isLoading ? null : handleChangePassword,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
        elevation: 0,
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("Lưu mật khẩu mới", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ),
  );

  Widget _buildBottomNav() => Container(
    padding: const EdgeInsets.only(top: 12, bottom: 32),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildBottomNavItem(Icons.home_outlined, "Home", '/dashboard'),
        _buildBottomNavItem(Icons.check_circle_outline, "Tasks", '/tasks'),
        _buildBottomNavItem(Icons.repeat, "Habits", '/habits'),
        _buildBottomNavItem(Icons.auto_awesome_outlined, "AI", '/ai'),
        _buildBottomNavItem(Icons.person, "Profile", '/profile', isSelected: true),
      ],
    ),
  );

  Widget _buildBottomNavItem(IconData icon, String label, String route, {bool isSelected = false}) => GestureDetector(
    onTap: () {
      if (!isSelected) Navigator.pushReplacementNamed(context, route);
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isSelected ? primaryColor : Colors.grey[400], size: 26),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: isSelected ? primaryColor : Colors.grey[400], fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}