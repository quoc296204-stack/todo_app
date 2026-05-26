import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import thư viện này
import 'package:fe_todoapp/main.dart'; // Đảm bảo import đúng đường dẫn main của bạn

void main() {
  testWidgets('App khởi chạy thành công (Smoke Test)', (WidgetTester tester) async {
    // 1. Giả lập giá trị ban đầu cho SharedPreferences
    // Nếu không có dòng này, app sẽ bị crash khi gọi SharedPreferences.getInstance()
    SharedPreferences.setMockInitialValues({'userId': 1, 'userName': 'Test User'});

    // 2. Build app và chờ tất cả các frame load xong
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle(); // Chờ các animation và API call giả lập (nếu có) kết thúc

    // 3. Verify: Kiểm tra xem app có load ra màn hình nào đó không
    // Bạn có thể thay bằng widget chính mà app bạn load lên đầu tiên (ví dụ LoginPage hoặc DashboardPage)
    // Ví dụ: expect(find.byType(DashboardPage), findsOneWidget); 
    
    // Nếu bạn chỉ muốn test xem app có crash không thì đoạn này là đủ:
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}