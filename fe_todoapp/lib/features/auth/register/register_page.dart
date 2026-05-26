import 'package:flutter/material.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/auth_service.dart';


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  // 1. Khởi tạo các Controller từ file cũ của bạn
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  // 2. Các trạng thái logic
  bool isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // 3. Hệ màu Soft Minimalism
  final Color primaryColor = const Color(0xFF4647D3);
  final Color primaryContainer = const Color(0xFF9396FF);
  final Color backgroundColor = const Color(0xFFF5F7F9);
  final Color surfaceContainer = const Color(0xFFFFFFFF);
  final Color textMain = const Color(0xFF2C2F31);
  final Color textSub = const Color(0xFF595C5E);
  final Color outlineColor = const Color(0xFFD9DDE0);

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // 4. Logic Validate Email
  bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // 5. Hàm đăng ký tích hợp từ file cũ
  Future<void> onRegister() async {
    FocusScope.of(context).unfocus(); // Ẩn bàn phím

    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      final user = UserModel(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
      );

      final result = await _authService.register(user);

      if (!mounted) return;

      if (result['status'] == 200 || result['status'] == 201) {
        _showSnackBar('Đăng ký thành công!', isError: false);
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        _showSnackBar(result['body']['detail'] ?? 'Đăng ký thất bại');
      }
    } catch (e) {
      _showSnackBar('Không thể kết nối đến máy chủ. Kiểm tra IP!');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 1200),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: surfaceContainer,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 30,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildHeroSection()),
                      Expanded(child: _buildRegisterForm()),
                    ],
                  );
                } else {
                  return _buildRegisterForm();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      height: 850,
      decoration: const BoxDecoration(
        color: Color(0xFFEEF1F3),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAsQA1AEZ2fKPY3_WWtd0V81XG2wgA9Ho5W-U4niqtrFVqksIYc8ISg3JCxHziJ9qfiVaeFDS2a2xI9bMWEsS1I1k7FJ5_wXm8eXGu7UY3Kfm1EfVG7jBJ1GBUrpmpIDOLHc-m_KgNYUPAkktjRp2RbbPq51tp7LAsMrvKwO5WF1atmAlKqMcJtEehXw9UJB2ZA7Bu4Ipg6oZdxsBznSDuMzQVmsTKz5ImPnSP99qiiomv4dbD3UOTfl0quD9ggVZdEhvE_3b29_s0',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Digital Curator', style: TextStyle(color: primaryColor, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -1)),
                    const SizedBox(height: 32),
                    Text('Nâng tầm trải nghiệm\nsố của bạn.', style: TextStyle(color: textMain, fontSize: 48, fontWeight: FontWeight.w800, height: 1.1)),
                    const SizedBox(height: 24),
                    Text('Hệ thống quản lý thông minh giúp bạn tối ưu hóa công việc và cuộc sống hàng ngày.', style: TextStyle(color: textSub, fontSize: 18, height: 1.6)),
                  ],
                ),
                _buildAiInsightCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiInsightCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: primaryColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(Icons.auto_awesome, color: primaryColor, size: 14),
            const SizedBox(width: 8),
            Text('AI INSIGHT', style: TextStyle(color: primaryColor, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2)),
          ]),
          const SizedBox(height: 8),
          Text('"Sự đơn giản là đỉnh cao của sự tinh tế."', style: TextStyle(color: textMain, fontSize: 14, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildRegisterForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 60),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tạo tài khoản mới', style: TextStyle(color: textMain, fontSize: 32, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            // Text('Tham gia cùng Digital Curator ngay hôm nay.', style: TextStyle(color: textSub, fontSize: 14)),
            const SizedBox(height: 48),

            // 6. Tích hợp các Input với Controller và Validator
            _buildLabel('HỌ VÀ TÊN'),
            _buildTextField(
              controller: fullNameController,
              hint: 'Nguyễn Văn A',
              icon: Icons.person_outline,
              validator: (v) => (v == null || v.isEmpty) ? 'Vui lòng nhập họ tên' : null,
            ),
            const SizedBox(height: 24),

            _buildLabel('EMAIL'),
            _buildTextField(
              controller: emailController,
              hint: 'example@curator.io',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Vui lòng nhập email';
                if (!isValidEmail(v)) return 'Email không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 24),

            _buildLabel('MẬT KHẨU'),
            _buildTextField(
              controller: passwordController,
              hint: '••••••••',
              icon: Icons.lock_outline,
              obscureText: !_isPasswordVisible,
              validator: (v) => (v != null && v.length < 6) ? 'Tối thiểu 6 ký tự' : null,
              suffixIcon: IconButton(
                icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: textSub, size: 20),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),
            const SizedBox(height: 24),

            _buildLabel('XÁC NHẬN MẬT KHẨU'),
            _buildTextField(
              controller: confirmPasswordController,
              hint: '••••••••',
              icon: Icons.check_circle_outline,
              obscureText: !_isConfirmPasswordVisible,
              validator: (v) => (v != passwordController.text) ? 'Mật khẩu không khớp' : null,
              suffixIcon: IconButton(
                icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: textSub, size: 20),
                onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
              ),
            ),
            const SizedBox(height: 40),

            // 7. Nút Đăng ký với trạng thái Loading
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : onRegister,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Đăng ký ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            ),

            _buildSocialDivider(),
            _buildGoogleButton(),

            const SizedBox(height: 48),
            _buildFooterLogin(),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(text, style: TextStyle(color: textSub, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: TextStyle(color: textMain, fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textSub.withOpacity(0.4)),
        prefixIcon: Icon(icon, color: textSub.withOpacity(0.7), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFFEEF1F3),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      ),
    );
  }

  Widget _buildSocialDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Row(children: [
        Expanded(child: Divider(color: outlineColor.withOpacity(0.5))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('HOẶC', style: TextStyle(color: textSub, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2))),
        Expanded(child: Divider(color: outlineColor.withOpacity(0.5))),
      ]),
    );
  }

  Widget _buildGoogleButton() {
    return OutlinedButton(
      onPressed: () {}, // Tính năng Google Sign-in có thể thêm sau
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        side: BorderSide(color: outlineColor.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network('https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_Reference_Icon.png', height: 20, errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata)),
          const SizedBox(width: 12),
          Text('Đăng ký bằng Google', style: TextStyle(color: textMain, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildFooterLogin() {
    return Center(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: RichText(
          text: TextSpan(
            text: 'Đã có tài khoản? ',
            style: TextStyle(color: textSub, fontSize: 14),
            children: [
              TextSpan(text: 'Đăng nhập', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}