import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // --- PALETTE MÀU ---
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color surfaceLow = const Color(0xFFEEF1F3);
  final Color errorColor = const Color(0xFFB41340);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBJhYp85Fapl0e0NJh-dWfFJ3V77HsR9EsP6cWL8TuAmw0cdYoYo6njIlLVmrM7-vfTKrnJdejVXYJX72eFUywc9gzfAOXxrNyZaj-tqZCpzJnS5vz2Ng8dbcR8og2wPniqGPL1t3Oi4Lv2bJmKQkqasXTzjS4RL5ITJznW2bGmHY8-DzLqiH9KtohF8yg5UWBmb_5-cx3JaHdSBRZJXbH2wnmi1Qlh9dKqMGrKu1QKrlcgfuxBpam5fgogobAkq4wGR97FteLQJAc'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Digital Curator',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -1,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: primaryColor),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 32),
            _buildHeroProfile(),
            const SizedBox(height: 48),

            // NHÓM 1: QUẢN LÝ CÁ NHÂN & HIỆU SUẤT
            _buildSectionLabel("QUẢN LÝ"),
            _buildMenuSection([
              _buildMenuItem(
                Icons.person_outline,
                "Chỉnh sửa hồ sơ",
                showChevron: true,
                onTap: () => Navigator.pushNamed(context, '/edit_profile'),
              ),
              _buildMenuItem(
                Icons.analytics_outlined,
                "Báo cáo năng suất",
                showChevron: true,
                onTap: () => Navigator.pushNamed(context, '/productivity_report'),
              ),
              _buildMenuItem(
                Icons.notifications_active_outlined,
                "Cài đặt nhắc nhở",
                showChevron: true,
                onTap: () => Navigator.pushNamed(context, '/notification_settings'),
              ),
            ]),

            const SizedBox(height: 24),

            // NHÓM 2: TÙY CHỈNH & HỖ TRỢ
            _buildSectionLabel("HỆ THỐNG"),
            _buildMenuSection([
              _buildThemeSwitch(),
              _buildMenuItem(
                  Icons.language,
                  "Ngôn ngữ",
                  subtitle: "TIẾNG VIỆT",
                  showChevron: true
              ),
              _buildMenuItem(
                Icons.help_outline,
                "Trợ giúp & Phản hồi",
                showChevron: true,
                onTap: () => Navigator.pushNamed(context, '/support'),
              ),
            ]),

            const SizedBox(height: 32),

            // 4. DANGER ZONE
            _buildLogoutButton(context),

            // 5. EDITORIAL QUOTE
            _buildEditorialQuote(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildSectionLabel(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8, bottom: 8),
        child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
      ),
    );
  }

  Widget _buildHeroProfile() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [primaryColor, const Color(0xFF9396FF)],
                  begin: Alignment.topRight,
                ),
              ),
              child: const CircleAvatar(
                radius: 60,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 56,
                  backgroundImage: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuD7lpNyGx-H5CROk0mI3DVQtdFi7H0qNa6OwrQgAqTc2WF_7CFNValJ1RZinISd87_1oZoQ_7MXu2xAOdbHGRGDh04-AVMi4GZFQ6cfl_5X7Qf2YJQ89me2lCfa-ug-5HSdfsB0ByZcYnzqBomVw6lGkUkJKkePZz2BtCweaKVJ54Mkn91-Gw2DMRFAuRA_9qw7UNkpODZmHACs4nyxsjCdacppbx4B_hsLjafGieji_-specR0EkX9RieeSVEwG87xmmMMrBe-m6I'),
                ),
              ),
            ),
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                color: primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 16),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text("Nguyễn Văn Tuấn", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
        const Text("tuan.nguyen@digitalcurator.ai", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildMenuSection(List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEF1F3).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {String? subtitle, bool showChevron = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Icon(icon, color: primaryColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  if (subtitle != null)
                    Text(subtitle, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
                ],
              ),
            ),
            if (showChevron) const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSwitch() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(Icons.dark_mode_outlined, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 16),
          const Expanded(child: Text("Chế độ Tối", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
          Switch(value: false, onChanged: (v) {}, activeColor: primaryColor),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushReplacementNamed(context, '/login'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: errorColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: errorColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.logout, color: errorColor, size: 20),
            ),
            const SizedBox(width: 16),
            Text("Đăng xuất", style: TextStyle(color: errorColor, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorialQuote() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 64, horizontal: 40),
      child: Opacity(
        opacity: 0.4,
        child: Column(
          children: [
            Text('"Simplicity is the ultimate sophistication."', textAlign: TextAlign.center, style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14)),
            SizedBox(height: 8),
            Text('CURATED FOR BALANCE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 2)),
          ],
        ),
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
          _buildNavItem(context, Icons.home_outlined, "Home", false, route: '/dashboard'),
          _buildNavItem(context, Icons.check_circle_outline, "Tasks", false, route: '/tasks'),
          _buildNavItem(context, Icons.repeat, "Habits", false, route: '/habits'),
          _buildNavItem(context, Icons.auto_awesome_outlined, "AI", false, route: '/ai'),
          _buildNavItem(context, Icons.person, "Profile", true, route: '/profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, {String? route}) {
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