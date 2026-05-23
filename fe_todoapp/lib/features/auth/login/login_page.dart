import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/auth_service.dart';


// --- Hệ thống màu sắc (Theme Colors) ---
const Color kPrimary = Color(0xFF4647D3);
const Color kPrimaryContainer = Color(0xFF9396FF);
const Color kSecondary = Color(0xFF4650B9);
const Color kBackground = Color(0xFFF5F7F9);
const Color kSurfaceContainerLow = Color(0xFFEEF1F3);
const Color kSurfaceContainerHighest = Color(0xFFD9DDE0);
const Color kSurfaceContainerLowest = Color(0xFFFFFFFF);
const Color kOnBackground = Color(0xFF2C2F31);
const Color kOnSurface = Color(0xFF2C2F31);
const Color kOnSurfaceVariant = Color(0xFF595C5E);
const Color kOutline = Color(0xFF747779);
const Color kOutlineVariant = Color(0xFFABADAF);
const Color kInverseSurface = Color(0xFF0B0F10);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // --- Khởi tạo Controller và Service ---
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false; // Trạng thái chờ khi gọi API

  /// Xử lý logic đăng nhập
  /// Xử lý logic đăng nhập
  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Kiểm tra validation cơ bản tại Client
    if (email.isEmpty || password.isEmpty) {
      _showMessage('Vui lòng nhập đầy đủ Email và Mật khẩu');
      return;
    }

    // 2. Bật trạng thái Loading (hiện vòng xoay)
    setState(() => _isLoading = true);

    try {
      // 3. Gọi API Login từ AuthService (Đã cấu hình IP máy tính)
      final result = await _authService.login(email, password);

      if (result['success']) {
        _showMessage('Đăng nhập thành công! Chào mừng trở lại.', isError: false);

        final prefs = await SharedPreferences.getInstance();
        int userIdToSave = result['id'] ?? result['data']['id'];
        await prefs.setInt('userId', userIdToSave);
        // --- LOGIC LẤY TÊN THÔNG MINH TỪ JSON LỒNG NHAU ---
        String extractedName = "bạn"; // Mặc định
        try {
          // 1. Đi sâu vào 2 lớp 'user' để lấy data
          final userData = result['user']['user'];

          // 2. Lấy full_name và email
          String? fullName = userData['full_name'];
          String? email = userData['email'];

          // 3. Nếu full_name có thật (không trống), lấy full_name
          if (fullName != null && fullName.trim().isNotEmpty) {
            extractedName = fullName;
          }
          // 4. Nếu full_name trống (hoặc bạn muốn dự phòng), lấy phần chữ trước @ của email
          else if (email != null && email.contains('@')) {
            extractedName = email.split('@')[0]; // Ví dụ: quoc321@gmail.com -> quoc321
          }
        } catch (e) {
          debugPrint("Lỗi trích xuất tên: $e");
        }
        // Lưu tên vào bộ nhớ máy
        await prefs.setString('userName', extractedName);
        // ------------------------------------------------

        // Đợi 0.8s để người dùng thấy thông báo rồi chuyển trang
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            // Chuyển sang màn hình Dashboard và xóa lịch sử các màn trước đó
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        });
      } else {
        // Hiển thị lỗi trả về từ Backend (Sai mật khẩu, User không tồn tại...)
        _showMessage(result['message']);
      }
    } catch (e) {
      // Bắt các lỗi kết nối (Timeout, SocketException)
      _showMessage('Lỗi kết nối server. Hãy kiểm tra IP và Backend!');
    } finally {
      // 4. Luôn tắt trạng thái Loading khi kết thúc
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ cho các controller khi không dùng nữa
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Hiển thị thông báo nhanh (SnackBar)
  void _showMessage(String text, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          const _BlurBackground(), // Hình nền hiệu ứng mờ
          SafeArea(
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final bool isDesktop = constraints.maxWidth >= 950;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: isDesktop
                          ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(flex: 6, child: _HeroPanel()),
                          const SizedBox(width: 48),
                          Expanded(
                            flex: 4,
                            child: Align(
                              alignment: Alignment.center,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 440),
                                child: _buildLoginForm(),
                              ),
                            ),
                          ),
                        ],
                      )
                          : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: _buildLoginForm(),
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

  /// Widget chứa Form đăng nhập
  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        // --- Logo App ---
        Row(
          children: const [
            // Icon(Icons.bubble_chart, color: kPrimary, size: 30),
            SizedBox(width: 8),
            Text(
              ' ',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: kPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          'Chào mừng trở lại',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: kOnBackground,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Vui lòng nhập thông tin của bạn để tiếp tục.',
          style: TextStyle(fontSize: 14, color: kOnSurfaceVariant),
        ),
        const SizedBox(height: 40),

        // --- Ô nhập Email ---
        _buildFieldLabel('EMAIL'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _emailController,
          hintText: 'example@curator.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),

        // --- Ô nhập Mật khẩu ---
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFieldLabel('MẬT KHẨU'),
            GestureDetector(
              onTap: () => _showMessage('Tính năng đang phát triển'),
              child: const Text(
                'Quên mật khẩu?',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kPrimary,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _passwordController,
          hintText: '••••••••',
          obscureText: true,
        ),
        const SizedBox(height: 24),

        // --- Nút Đăng nhập ---
        SizedBox(
          width: double.infinity,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(colors: [kPrimary, kPrimaryContainer]),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(11, 15, 16, 0.08),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : const Text('Đăng nhập', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
        const SizedBox(height: 36),

        // --- Divider ---
        Row(
          children: [
            Expanded(child: Container(height: 1, color: kSurfaceContainerHighest)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('HOẶC', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kOutline, letterSpacing: 1.2)),
            ),
            Expanded(child: Container(height: 1, color: kSurfaceContainerHighest)),
          ],
        ),
        const SizedBox(height: 36),

        // --- Login Google ---
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () => _showMessage('Tính năng Google đang phát triển'),
            style: OutlinedButton.styleFrom(
              backgroundColor: kSurfaceContainerLowest,
              side: BorderSide(color: kOutlineVariant.withOpacity(0.2)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _GoogleIcon(),
                SizedBox(width: 12),
                Text(
                  'Hoặc đăng nhập bằng Google',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kOnSurface),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),

        // --- Điều hướng sang Đăng ký ---
        Center(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 14, color: kOnSurfaceVariant),
              children: [
                const TextSpan(text: 'Chưa có tài khoản? '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: const Text(
                      'Đăng ký ngay',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: kPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: kOnSurfaceVariant, letterSpacing: 1.4),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: kOutline.withOpacity(0.55), fontSize: 15),
        filled: true,
        fillColor: kSurfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: kPrimary, width: 1.2),
        ),
      ),
    );
  }
}

// --- Các Widget phụ trợ (Helper Widgets) ---
class _HeroPanel extends StatelessWidget {
  const _HeroPanel();
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        constraints: const BoxConstraints(minHeight: 680),
        decoration: const BoxDecoration(color: kSurfaceContainerLow),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBOI2P7Z-BVRmDr4JwyAgEaQfgjGOjx_KjXumCf9B16G-rfT-kf1-EO-ZbLb_eoXpC3s2lapvOl48pvgbtmEk4PJQgiqZLIb_myulv7a6f9mHrnCZ1Y1g0SKRAHqQAV2O-ueXY38qAyAFWcgt5_nv0B_M3vIcZ3oNhUAwvQOS9tU_j8CtqDt0G1ug6WHTejWzJ_It-hCh152j2uzSjWmF1mDOadqS7_KyEedeAIGb_nk7wIam0uLlHC2sx8OwcBxt6tqk4IQtAmV30',
              fit: BoxFit.cover,
            ),
            Container(color: kInverseSurface.withOpacity(0.4)),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('DIGITAL CURATOR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: kPrimaryContainer, letterSpacing: 3)),
                  SizedBox(height: 28),
                  Text('Sắp xếp hỗn loạn\nthành sự tĩnh lặng.', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: Colors.white, height: 1.05)),
                  Spacer(),
                  _FeatureCircle(icon: Icons.auto_awesome_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCircle extends StatelessWidget {
  final IconData icon;
  const _FeatureCircle({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.16), shape: BoxShape.circle),
      child: Icon(icon, color: kPrimaryContainer),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();
  @override
  Widget build(BuildContext context) {
    return const Text('G', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: kPrimary));
  }
}

class _BlurBackground extends StatelessWidget {
  const _BlurBackground();
  @override
  Widget build(BuildContext context) {
    return Container(color: kBackground);
  }
}