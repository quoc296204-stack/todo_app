import 'package:flutter/material.dart';
import 'dart:io';

// Import các trang tính năng
import 'package:fe_todoapp/features/dashboard/dashboard_page.dart';
import 'package:fe_todoapp/features/profile/edit_profile_page.dart';
import 'package:fe_todoapp/features/profile/profile_page.dart';
import 'package:fe_todoapp/features/task/task_page.dart';
import 'package:fe_todoapp/features/ai/ai_page.dart';
import 'package:fe_todoapp/features/auth/login/login_page.dart';
import 'package:fe_todoapp/features/auth/register/register_page.dart';
import 'package:fe_todoapp/features/habit/habit_page.dart';
import 'package:fe_todoapp/features/profile/productivity_report_page.dart';
import 'package:fe_todoapp/features/task/task_detail_page.dart';
import 'package:fe_todoapp/features/profile/notification_settings_page.dart';
import 'package:fe_todoapp/features/profile/support_page.dart';

import 'features/profile/change_password_page.dart';

// Class fix server ảnh cho Android Emulator
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(const PersonalAiManagerApp());
}

class PersonalAiManagerApp extends StatelessWidget {
  const PersonalAiManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Digital Curator',
      theme: ThemeData(
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(), // Đã dọn dẹp lỗi const
        '/tasks': (context) => const TaskPage(),
        '/habits': (context) => const HabitPage(),
        '/ai': (context) => const AiPage(),

        // Route này dành cho trang thông tin cá nhân tổng quan
        '/profile' : (context) => const ProfilePage(),

        // Route này dành cho trang chỉnh sửa thông tin[cite: 4, 5]
        '/edit_profile' : (context) => const EditProfilePage(),

        // BẠN CẦN THÊM DÒNG NÀY: Route mới cho trang đổi mật khẩu
        '/change_password' : (context) => const ChangePasswordPage(),

        '/productivity_report': (context) => const ProductivityReportPage(),
        '/notification_settings': (context) => const NotificationSettingsPage(),
        '/support' : (context) => const SupportPage(),
        '/task_detail': (context) => const TaskDetailPage(),
      },
    );
  }
}