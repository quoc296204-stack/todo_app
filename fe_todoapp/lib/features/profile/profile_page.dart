import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- HỆ MÀU SOFT MINIMALISM ---
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceColor = Colors.white;
  final Color textMain = const Color(0xFF2C2F31);
  final Color textSub = const Color(0xFF595C5E);
  final Color errorColor = const Color(0xFFB41340);

  // --- THÔNG TIN TÀI KHOẢN ĐỘNG ---
  String userName = "Đang tải...";
  String userEmail = "";
  int _selectedIndex = 4;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Tải dữ liệu từ SharedPreferences (đã lưu khi login)
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('userName') ?? "Người dùng";
      userEmail = prefs.getString('userEmail') ?? " ";
    });
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
            _buildHeroSection(),
            const SizedBox(height: 40),
            _buildMainActions(),
            const SizedBox(height: 16),
            _buildSecondaryActions(),
            const SizedBox(height: 32),
            _buildLogoutButton(),
            const SizedBox(height: 40),
            _buildFooterQuote(),
            const SizedBox(height: 120),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      extendBody: true,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: bgColor.withOpacity(0.8),
      elevation: 0,
      title: Row(
        children: [
          // Icon(Icons.dashboard_customize, color: primaryColor),
          // const SizedBox(width: 12),

        ],
      ),
      actions: [
        // IconButton(
        //   onPressed: () => Navigator.pushNamed(context, '/settings'),
        //   icon: Icon(Icons.settings_outlined, color: primaryColor),
        // ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        // Loại bỏ ảnh, thay bằng Icon đại diện tối giản
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person_outline, size: 60, color: primaryColor),
        ),
        const SizedBox(height: 24),
        Text(userName, style: TextStyle(color: textMain, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -1)),
        const SizedBox(height: 4),
        Text(userEmail, style: TextStyle(color: textSub, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildMainActions() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFFEEF1F3), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: <Widget>[
          _buildMenuTile(Icons.person_outline, 'Chỉnh sửa hồ sơ', route: '/edit_profile'),
          _buildMenuTile(Icons.analytics, 'Báo cáo năng suất', route: '/productivity_report'),
          _buildMenuTile(Icons.notifications_active_outlined, 'Cài đặt nhắc nhở', route: '/notification_settings'),
          _buildMenuTile(Icons.lock_outline, 'Thay đổi mật khẩu', route: '/change_password'),
        ],
      ),
    );
  }

  Widget _buildSecondaryActions() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFFEEF1F3), borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _buildMenuTile(Icons.language_outlined, 'Ngôn ngữ', subtitle: 'TIẾNG VIỆT'),
          _buildMenuTile(Icons.help_outline_rounded, 'Trợ giúp & Phản hồi', route: '/support'),
        ],
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String title, {String? subtitle, String? route}) {
    return InkWell(
      onTap: () => route != null ? Navigator.pushNamed(context, route) : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: textMain, fontWeight: FontWeight.w600, fontSize: 15)),
                  if (subtitle != null)
                    Text(subtitle, style: TextStyle(color: textSub, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: textSub.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: errorColor.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          if(mounted) Navigator.pushReplacementNamed(context, '/login');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: errorColor.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(Icons.logout_rounded, color: errorColor, size: 20),
              ),
              const SizedBox(width: 16),
              Text('Đăng xuất', style: TextStyle(color: errorColor, fontWeight: FontWeight.w800, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterQuote() {
    return Opacity(
      opacity: 0.4,
      child: Column(
        children: [


        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.only(top: 12, bottom: 32),
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_outlined, 'Home', '/dashboard'),
          _buildNavItem(1, Icons.check_circle_outlined, 'Tasks', '/tasks'),
          _buildNavItem(2, Icons.repeat, 'Habits', '/habits'),
          _buildNavItem(3, Icons.auto_awesome_outlined, 'AI', '/ai'),
          _buildNavItem(4, Icons.person_outline, 'Profile', '/profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, String route) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (route != '/profile') Navigator.pushReplacementNamed(context, route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? primaryColor : textSub, size: 24, fill: isSelected ? 1.0 : 0.0),
            Text(label, style: TextStyle(color: isSelected ? primaryColor : textSub, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}