import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // --- HỆ MÀU SOFT MINIMALISM ---
  final Color primaryColor = const Color(0xFF4647D3);
  final Color primaryContainer = const Color(0xFF9396FF);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceColor = Colors.white;
  final Color textMain = const Color(0xFF2C2F31);
  final Color textSub = const Color(0xFF595C5E);
  final Color errorColor = const Color(0xFFB41340);

  int _selectedIndex = 4; // Index 4 là Profile

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      // 1. TopAppBar (Glassmorphism style)
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            // 2. Hero Profile Section
            _buildHeroSection(),
            const SizedBox(height: 40),
            // 3. Profile Menu Groups
            _buildMainActions(),
            const SizedBox(height: 16),
            _buildSecondaryActions(),
            const SizedBox(height: 32),
            // 4. Danger Zone
            _buildLogoutButton(),
            const SizedBox(height: 40),
            // 5. Editorial Quote
            _buildFooterQuote(),
            const SizedBox(height: 120),
          ],
        ),
      ),
      // 6. Bottom Navigation Bar bo góc mượt mà
      bottomNavigationBar: _buildBottomNav(),
      extendBody: true,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: bgColor.withOpacity(0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      title: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAfLi7bpWIGPZZBKmV7KbQK6rcLB4Ch98mPZBrlQoiyudolLbQXetpFrosfZvAd8a8ZGUsBmPEhchIac-ygL7KpQ_lXYWs_vT8xSnScAeQm_cbswheZEdhJo5kOG85QLZGF-qEJdzj9tbbmX_qBKisGoq3FDn84Okb6M6XqgccJHUarqFFd3Yyzvj1LhUpWFVl0A1ifddXnHhJnS7zBwlTY5VeK6o3cqmV7tRMsUlCMPZBtTc0yqAjiE-H6Amyv3t2-mOHzoGz69Ac'),
          ),
          const SizedBox(width: 12),
          Text(
            'Digital Curator',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w800, fontSize: 20, letterSpacing: -1),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.pushNamed(context, '/notification_settings'),
          icon: Icon(Icons.settings_outlined, color: primaryColor),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [primaryColor, primaryContainer]),
              ),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: bgColor, width: 4),
                  image: const DecorationImage(
                    image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuD7lpNyGx-H5CROk0mI3DVQtdFi7H0qNa6OwrQgAqTc2WF_7CFNValJ1RZinISd87_1oZoQ_7MXu2xAOdbHGRGDh04-AVMi4GZFQ6cfl_5X7Qf2YJQ89me2lCfa-ug-5HSdfsB0ByZcYnzqBomVw6lGkUkJKkePZz2BtCweaKVJ54Mkn91-Gw2DMRFAuRA_9qw7UNkpODZmHACs4nyxsjCdacppbx4B_hsLjafGieji_-specR0EkX9RieeSVEwG87xmmMMrBe-m6I'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/edit_profile'),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: bgColor, width: 2),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Nguyễn Văn Hiếu', style: TextStyle(color: textMain, fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -1)),
        const SizedBox(height: 4),
        Text('hieu.it@digitalcurator.ai', style: TextStyle(color: textSub, fontSize: 14, fontWeight: FontWeight.w500)),
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
          _buildMenuTile(Icons.lock_outline, 'Thay đổi mật khẩu', route: '/change_password'), // Có thể tách route nếu cần
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
      onTap: () {
        if (route != null) Navigator.pushNamed(context, route);
      },
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
        onTap: () => Navigator.pushReplacementNamed(context, '/login'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
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
          Text('"Simplicity is the ultimate sophistication."', style: TextStyle(color: textSub, fontSize: 14, fontStyle: FontStyle.italic)),
          const SizedBox(height: 8),
          Text('CURATED FOR BALANCE', style: TextStyle(color: textSub, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 2)),
        ],
      ),
    );
  }

  // --- REUSE BOTTOM NAV LOGIC[cite: 3] ---
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
          _buildNavItem(0, Icons.home_max_outlined, 'Home', '/dashboard'),
          _buildNavItem(1, Icons.check_circle, 'Tasks', '/tasks'),
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