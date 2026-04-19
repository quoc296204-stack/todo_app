import 'package:flutter/material.dart';

/// Trang đăng ký tài khoản
/// Dùng StatefulWidget vì giao diện có dữ liệu thay đổi theo trạng thái:
/// - text trong các ô input
/// - ẩn/hiện mật khẩu
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

/// State quản lý toàn bộ dữ liệu và giao diện động của trang Register
class _RegisterPageState extends State<RegisterPage> {
  /// Controller để lấy dữ liệu người dùng nhập từ các ô text
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  /// Biến điều khiển ẩn/hiện mật khẩu
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  /// Bộ màu chính của giao diện
  final Color primaryColor = const Color(0xFF4647D3);
  final Color primaryContainerColor = const Color(0xFF9396FF);
  final Color secondaryColor = const Color(0xFF4650B9);

  /// Màu nền và bề mặt
  final Color backgroundColor = const Color(0xFFF5F7F9);
  final Color surfaceLowColor = const Color(0xFFEEF1F3);
  final Color surfaceHighColor = const Color(0xFFDFE3E6);
  final Color surfaceLowestColor = const Color(0xFFFFFFFF);

  /// Màu chữ chính và chữ phụ
  final Color textMainColor = const Color(0xFF2C2F31);
  final Color textSubColor = const Color(0xFF595C5E);

  /// Màu viền
  final Color outlineColor = const Color(0xFF747779);
  final Color outlineVariantColor = const Color(0xFFABADAF);

  @override
  void dispose() {
    /// Giải phóng controller khi widget bị hủy
    /// để tránh rò rỉ bộ nhớ
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  /// Hàm xử lý khi bấm nút Đăng ký
  void onRegister() {
    /// Lấy dữ liệu từ các ô input và loại bỏ khoảng trắng đầu/cuối
    final fullName = fullNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    /// Kiểm tra nếu còn ô nào bỏ trống
    if (fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ thông tin'),
        ),
      );
      return;
    }

    /// Kiểm tra mật khẩu xác nhận có trùng với mật khẩu không
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu xác nhận không khớp'),
        ),
      );
      return;
    }

    /// Nếu hợp lệ thì tạm thời hiển thị thông báo thành công
    /// Sau này có thể thay bằng gọi API đăng ký
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đăng ký tài khoản cho $fullName'),
      ),
    );
  }

  /// Hàm xử lý khi bấm đăng ký bằng Google
  void onGoogleRegister() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đăng ký bằng Google'),
      ),
    );
  }

  /// Hàm quay lại màn hình đăng nhập
  void onGoToLogin() {
    Navigator.pop(context);
  }

  /// Widget tạo tiêu đề nhỏ cho từng ô nhập liệu
  Widget buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: textSubColor,
        letterSpacing: 1.3,
      ),
    );
  }

  /// Widget dùng lại để tạo ô nhập liệu
  /// Có thể tái sử dụng cho họ tên, email, mật khẩu...
  Widget buildInput({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: outlineColor,
          fontSize: 15,
        ),
        prefixIcon: Icon(
          icon,
          color: outlineColor,
          size: 22,
        ),
        suffixIcon: suffix,
        filled: true,
        fillColor: surfaceLowColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(
            color: primaryColor,
            width: 1.2,
          ),
        ),
      ),
    );
  }

  /// Panel bên trái trên desktop
  /// Hiển thị ảnh nền, slogan và thông tin giới thiệu
  Widget buildHeroPanel() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        constraints: const BoxConstraints(minHeight: 720),
        color: surfaceLowColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            /// Ảnh nền
            Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuAsQA1AEZ2fKPY3_WWtd0V81XG2wgA9Ho5W-U4niqtrFVqksIYc8ISg3JCxHziJ9qfiVaeFDS2a2xI9bMWEsS1I1k7FJ5_wXm8eXGu7UY3Kfm1EfVG7jBJ1GBUrpmpIDOLHc-m_KgNYUPAkktjRp2RbbPq51tp7LAsMrvKwO5WF1atmAlKqMcJtEehXw9UJB2ZA7Bu4Ipg6oZdxsBznSDuMzQVmsTKz5ImPnSP99qiiomv4dbD3UOTfl0quD9ggVZdEhvE_3b29_s0',
              fit: BoxFit.cover,

              /// Nếu lỗi tải ảnh, hiển thị nền gradient thay thế
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryColor.withOpacity(0.15),
                        secondaryColor.withOpacity(0.08),
                      ],
                    ),
                  ),
                );
              },
            ),

            /// Lớp phủ trắng mờ lên trên ảnh
            Container(
              color: Colors.white.withOpacity(0.70),
            ),

            /// Nội dung chữ trong panel trái
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Digital Curator',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: primaryColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Nâng tầm trải nghiệm số của bạn.',
                    style: TextStyle(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: textMainColor,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Hệ thống quản lý thông minh giúp bạn tối ưu hóa công việc và cuộc sống hàng ngày thông qua sự tĩnh lặng của thiết kế Soft Minimalism.',
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.7,
                      color: textSubColor,
                    ),
                  ),
                  const Spacer(),

                  /// Hộp thông điệp phụ ở cuối panel
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border(
                        left: BorderSide(
                          color: primaryColor,
                          width: 4,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 18,
                              color: primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AI Insight',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: primaryColor,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '"Sự đơn giản là đỉnh cao của sự tinh tế."',
                          style: TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: textMainColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Form đăng ký bên phải
  Widget buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tạo tài khoản mới',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: textMainColor,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Bắt đầu hành trình của bạn với Người quản lý kỹ thuật số.',
          style: TextStyle(
            fontSize: 14,
            color: textSubColor,
          ),
        ),
        const SizedBox(height: 36),

        /// Ô nhập họ tên
        buildLabel('HỌ VÀ TÊN'),
        const SizedBox(height: 8),
        buildInput(
          controller: fullNameController,
          hintText: 'Nguyễn Văn A',
          icon: Icons.person_outline,
        ),

        const SizedBox(height: 20),

        /// Ô nhập email
        buildLabel('EMAIL'),
        const SizedBox(height: 8),
        buildInput(
          controller: emailController,
          hintText: 'example@curator.io',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 20),

        /// Ô nhập mật khẩu
        buildLabel('MẬT KHẨU'),
        const SizedBox(height: 8),
        buildInput(
          controller: passwordController,
          hintText: '••••••••',
          icon: Icons.lock_outline,
          obscureText: obscurePassword,

          /// Nút ẩn/hiện mật khẩu
          suffix: IconButton(
            onPressed: () {
              setState(() {
                obscurePassword = !obscurePassword;
              });
            },
            icon: Icon(
              obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: outlineColor,
            ),
          ),
        ),

        const SizedBox(height: 20),

        /// Ô xác nhận mật khẩu
        buildLabel('XÁC NHẬN MẬT KHẨU'),
        const SizedBox(height: 8),
        buildInput(
          controller: confirmPasswordController,
          hintText: '••••••••',
          icon: Icons.check_circle_outline,
          obscureText: obscureConfirmPassword,

          /// Nút ẩn/hiện xác nhận mật khẩu
          suffix: IconButton(
            onPressed: () {
              setState(() {
                obscureConfirmPassword = !obscureConfirmPassword;
              });
            },
            icon: Icon(
              obscureConfirmPassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: outlineColor,
            ),
          ),
        ),

        const SizedBox(height: 28),

        /// Nút đăng ký chính
        SizedBox(
          width: double.infinity,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                colors: [
                  primaryColor,
                  primaryContainerColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.18),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                'Đăng ký',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 36),

        /// Dòng phân cách "HOẶC"
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 1,
              color: outlineVariantColor.withOpacity(0.25),
            ),
            Container(
              color: surfaceLowestColor,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'HOẶC',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: textSubColor,
                  letterSpacing: 1.3,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 36),

        /// Nút đăng ký bằng Google
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: onGoogleRegister,
            style: OutlinedButton.styleFrom(
              backgroundColor: surfaceLowColor,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _GoogleIcon(),
                SizedBox(width: 12),
                Text(
                  'Hoặc đăng ký bằng Google',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2F31),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 36),

        /// Dòng điều hướng sang màn hình đăng nhập
        Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              Text(
                'Đã có tài khoản? ',
                style: TextStyle(
                  fontSize: 14,
                  color: textSubColor,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text(
                  'Đăng nhập',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Tạo các khối tròn mờ phía sau để trang nhìn mềm hơn
  Widget buildBlurBackground() {
    return Stack(
      children: [
        Positioned(
          top: -180,
          left: -180,
          child: Container(
            width: 420,
            height: 420,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withOpacity(0.05),
            ),
          ),
        ),
        Positioned(
          bottom: -200,
          right: -200,
          child: Container(
            width: 520,
            height: 520,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: secondaryColor.withOpacity(0.05),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          /// Nền mờ trang trí phía sau
          buildBlurBackground(),

          SafeArea(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  /// Nếu chiều rộng đủ lớn thì coi là desktop
                  final bool isDesktop = constraints.maxWidth >= 1000;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Container(
                        decoration: BoxDecoration(
                          color: surfaceLowestColor,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.04),
                              blurRadius: 30,
                              offset: Offset(0, -8),
                            ),
                          ],
                        ),

                        /// Nếu desktop: chia 2 cột
                        /// Nếu mobile/tablet nhỏ: chỉ hiện form
                        child: isDesktop
                            ? Row(
                          children: [
                            Expanded(
                              child: buildHeroPanel(),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 48,
                                  vertical: 56,
                                ),
                                child: buildRegisterForm(),
                              ),
                            ),
                          ],
                        )
                            : Padding(
                          padding: const EdgeInsets.all(24),
                          child: buildRegisterForm(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget icon Google đơn giản
class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return Text(
      'G',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: Color(0xFF4647D3),
      ),
    );
  }
}