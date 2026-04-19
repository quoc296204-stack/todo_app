import 'package:flutter/material.dart';

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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          const _BlurBackground(),
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
                          const Expanded(
                            flex: 6,
                            child: _HeroPanel(),
                          ),
                          const SizedBox(width: 48),
                          Expanded(
                            flex: 4,
                            child: Align(
                              alignment: Alignment.center,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 440,
                                ),
                                child: _buildLoginForm(),
                              ),
                            ),
                          ),
                        ],
                      )
                          : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 440,
                          ),
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

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: const [
            Icon(
              Icons.bubble_chart,
              color: kPrimary,
              size: 30,
            ),
            SizedBox(width: 8),
            Text(
              'Digital Curator',
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
          style: TextStyle(
            fontSize: 14,
            color: kOnSurfaceVariant,
          ),
        ),
        const SizedBox(height: 40),
        _buildFieldLabel('EMAIL'),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _emailController,
          hintText: 'example@curator.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFieldLabel('MẬT KHẨU'),
            GestureDetector(
              onTap: () => _showMessage('Chuyển sang màn quên mật khẩu'),
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
        SizedBox(
          width: double.infinity,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                colors: [
                  kPrimary,
                  kPrimaryContainer,
                ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(11, 15, 16, 0.08),
                  blurRadius: 28,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                _showMessage('Xử lý đăng nhập ở đây');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 36),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: kSurfaceContainerHighest,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'HOẶC',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: kOutline,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: kSurfaceContainerHighest,
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              _showMessage('Xử lý đăng nhập Google ở đây');
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: kSurfaceContainerLowest,
              side: BorderSide(
                color: kOutlineVariant.withOpacity(0.2),
              ),
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
                  'Hoặc đăng nhập bằng Google',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: kOnSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        Center(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: kOnSurfaceVariant,
              ),
              children: [
                const TextSpan(text: 'Chưa có tài khoản? '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/register');
                    },
                    child: const Text(
                      'Đăng ký ngay',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kPrimary,
                      ),
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
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: kOnSurfaceVariant,
        letterSpacing: 1.4,
      ),
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
        hintStyle: TextStyle(
          color: kOutline.withOpacity(0.55),
          fontSize: 15,
        ),
        filled: true,
        fillColor: kSurfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(
            color: kPrimary,
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        constraints: const BoxConstraints(minHeight: 680),
        decoration: const BoxDecoration(
          color: kSurfaceContainerLow,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBOI2P7Z-BVRmDr4JwyAgEaQfgjGOjx_KjXumCf9B16G-rfT-kf1-EO-ZbLb_eoXpC3s2lapvOl48pvgbtmEk4PJQgiqZLIb_myulv7a6f9mHrnCZ1Y1g0SKRAHqQAV2O-ueXY38qAyAFWcgt5_nv0B_M3vIcZ3oNhUAwvQOS9tU_j8CtqDt0G1ug6WHTejWzJ_It-hCh152j2uzSjWmF1mDOadqS7_KyEedeAIGb_nk7wIam0uLlHC2sx8OwcBxt6tqk4IQtAmV30',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF3132AE),
                        Color(0xFF8D92FF),
                      ],
                    ),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    kInverseSurface.withOpacity(0.18),
                    kInverseSurface.withOpacity(0.52),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'DIGITAL CURATOR',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: kPrimaryContainer,
                      letterSpacing: 3,
                    ),
                  ),
                  SizedBox(height: 28),
                  Text(
                    'Sắp xếp hỗn loạn\nthành sự tĩnh lặng.',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.05,
                      letterSpacing: -1.2,
                    ),
                  ),
                  SizedBox(height: 24),
                  _HeroLine(),
                  SizedBox(height: 24),
                  Text(
                    'Trải nghiệm trợ lý thông minh giúp bạn quản lý công việc và cuộc sống một cách nghệ thuật nhất.',
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.6,
                      color: Color(0xFFE1E5F0),
                    ),
                  ),
                  Spacer(),
                  Row(
                    children: [
                      _FeatureCircle(icon: Icons.auto_awesome_outlined),
                      SizedBox(width: 16),
                      _FeatureCircle(icon: Icons.verified_user_outlined),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroLine extends StatelessWidget {
  const _HeroLine();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 4,
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: BorderRadius.circular(999),
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
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
        ),
      ),
      child: Icon(
        icon,
        color: kPrimaryContainer,
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: kPrimary,
        ),
      ),
    );
  }
}

class _BlurBackground extends StatelessWidget {
  const _BlurBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -180,
          left: -180,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              color: kPrimary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -220,
          right: -220,
          child: Container(
            width: 600,
            height: 600,
            decoration: BoxDecoration(
              color: kSecondary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}