import 'package:fe_todoapp/features/dashboard/dashboard_page.dart';
import 'package:fe_todoapp/features/profile/edit_profile_page.dart';
import 'package:fe_todoapp/features/profile/profile_page.dart';
import 'package:fe_todoapp/features/task/task_page.dart';
import 'package:flutter/material.dart';

import 'features/ai/ai_page.dart';
import 'features/auth/login/login_page.dart';
import 'features/auth/register/register_page.dart';
import 'features/habit/habit_page.dart';
import 'features/profile/profile_page.dart';
import 'features/profile/productivity_report_page.dart';
import 'features/task/task_detail_page.dart';
import 'features/profile/notification_settings_page.dart';
import 'features/profile/support_page.dart';

import 'dart:io';

// class fixx server ảnh
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
// Widget gốc của toàn bộ ứng dụng
class PersonalAiManagerApp extends StatelessWidget {
  const PersonalAiManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Tên ứng dụng
      title: 'Digital Curator',
      theme: ThemeData(
        useMaterial3: true,
      ),
      // Route đầu tiên khi mở app
      // App sẽ hiển thị màn hình login trước
      initialRoute: '/dashboard',
      // Danh sách các route của ứng dụng
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/tasks': (context) => const TaskPage(),
        '/task_detail': (context) => const TaskDetailPage(),
        '/habits': (context) => const HabitPage(),
        '/ai': (context) => const AiPage(),
        '/profile' : (context) => const ProfilePage(),
        '/edit_profile' : (context) => const EditProfilePage(),
        '/productivity_report': (context) => const ProductivityReportPage(),
        '/notification_settings': (context) => const NotificationSettingsPage(),
        '/support' : (context) => const SupportPage(),
      },
    );
  }
}