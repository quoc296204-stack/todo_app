// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:fe_todoapp/core/constants.dart';
// import 'package:fe_todoapp/data/models/user_model.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class AuthService {
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   static const Duration timeout = Duration(seconds: 10);
//   // Nhớ thay IP máy tính của Hiếu vào đây để máy thật gọi được
//   final String url = "${AppConfig.baseUrl}/auth/login";
//
//   Future<Map<String, dynamic>> register(UserModel user) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/auth/register'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(user.toJson()),
//       );
//       print('=== STATUS CODE: ${response.statusCode} ===');
//       print('=== CHI TIẾT LỖI 422: ${response.body} ===');
//
//       // Giải mã phản hồi từ Backend
//       final Map<String, dynamic> responseBody = jsonDecode(response.body);
//
//       // Trả về một Map chứa cả statusCode và body để UI xử lý
//       return {
//         'status': response.statusCode,
//         'body': responseBody,
//       };
//
//     } catch (e) {
//       // Trả về một Map giả lập lỗi nếu mất kết nối
//       return {
//         'status': 500,
//         'body': {'detail': 'Lỗi kết nối: $e'},
//       };
//     }
//   }
//   // hàm login
//   Future<Map<String, dynamic>> login(String email, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse('${AppConfig.baseUrl}/auth/login'), // Đường dẫn API login
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'email': email,
//           'password': password,
//         }),
//       ).timeout(timeout);
//
//       final data = jsonDecode(response.body);
//
//       if (response.statusCode == 200) {
//         // --- TRÍCH XUẤT ID ---
//         // Dự phòng các trường hợp Backend trả về key khác nhau (id, user_id, hoặc bọc trong object user)
//         int? extractedId = data['id'] ?? data['user_id'];
//         if (extractedId == null && data['user'] != null && data['user'] is Map) {
//           extractedId = data['user']['id'];
//         }
//
//         return {
//           'success': true,
//           'message': 'Đăng nhập thành công',
//           'user': data,          // Giữ nguyên cục data cũ phòng khi bạn cần dùng thông tin khác (tên, avatar...)
//           'id': extractedId,     // Trả thêm key 'id' ra ngoài để UI dùng lưu SharedPreferences
//         };
//       } else {
//         return {'success': false, 'message': data['detail'] ?? 'Sai email hoặc mật khẩu'};
//       }
//     } catch (e) {
//       return {'success': false, 'message': 'Lỗi kết nối server: $e'};
//     }
//   }
//   // hàm update thông tin
//   Future<Map<String, dynamic>> updateProfile(int userId, Map<String, dynamic> updateData) async {
//     try {
//       // Đảm bảo baseUrl của bạn là http://192.168.0.106:8000/api/auth
//       final response = await http.put(
//         Uri.parse('${AppConfig.baseUrl}/auth/update-profile/$userId'),
//         headers: {
//           'Content-Type': 'application/json',
//           // Nếu sau này bạn có dùng Token, hãy thêm nó vào header ở đây
//         },
//         body: jsonEncode(updateData),
//       ).timeout(timeout);
//
//       // Trả về dữ liệu để UI xử lý tiếp
//       return {
//         'status': response.statusCode,
//         'body': jsonDecode(response.body),
//       };
//     } catch (e) {
//       print("Lỗi khi gọi API updateProfile: $e");
//       return {
//         'status': 500,
//         'message': 'Không thể kết nối đến server. Kiểm tra mạng hoặc IP!',
//       };
//     }
//   }
//   Future<Map<String, dynamic>> changePassword(int userId, String oldPwd, String newPwd) async {
//     try {
//       final response = await http.put(
//         Uri.parse('${AppConfig.baseUrl}/auth/change-password/$userId'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           'old_password': oldPwd,
//           'new_password': newPwd,
//         }),
//       ).timeout(timeout);
//       return {'status': response.statusCode, 'body': jsonDecode(response.body)};
//     } catch (e) {
//       return {'status': 500, 'message': 'Lỗi kết nối'};
//     }
//   }
// }
//

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fe_todoapp/core/constants.dart';
import 'package:fe_todoapp/data/models/user_model.dart';
<<<<<<< HEAD
=======
import 'package:firebase_auth/firebase_auth.dart';
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const Duration timeout = Duration(seconds: 10);

<<<<<<< HEAD
=======
  // ---------------------------------------------------------
  // 1. ĐĂNG KÝ (FIREBASE + BACKEND)
  // ---------------------------------------------------------
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
  Future<Map<String, dynamic>> register(UserModel user) async {
    try {
      // BƯỚC 1: Tạo tài khoản trên Firebase trước
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );

      // BẮT BUỘC: Đợi lấy token xong mới chạy tiếp
      String? token = await userCredential.user?.getIdToken(true);

      // In ra để debug (nếu thấy chữ null là lỗi từ máy ảo)
      print("=== TOKEN LÀ: $token ===");

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/register'),
<<<<<<< HEAD
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );
      print('=== STATUS CODE: ${response.statusCode} ===');
      print('=== CHI TIẾT LỖI 422: ${response.body} ===');

      // Giải mã phản hồi từ Backend
      final Map<String, dynamic> responseBody = jsonDecode(response.body);

      // Trả về một Map chứa cả statusCode và body để UI xử lý
      return {
        'status': response.statusCode,
        'body': responseBody,
      };

    } catch (e) {
      // Trả về một Map giả lập lỗi nếu mất kết nối
      return {
        'status': 500,
        'body': {'detail': 'Lỗi kết nối: $e'},
      };
=======
        headers: {
          'Content-Type': 'application/json',
          // ĐẢM BẢO CHỮ "Bearer " CÓ KHOẢNG TRẮNG Ở GIỮA
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(user.toJson()),
      ).timeout(timeout);

      print('=== STATUS CODE: ${response.statusCode} ===');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'status': response.statusCode,
          'body': jsonDecode(response.body),
        };
      } else {
        // RẤT QUAN TRỌNG: Nếu Backend lỗi, xóa user trên Firebase để tránh lệch data
        await userCredential.user?.delete();
        return {
          'status': response.statusCode,
          'body': jsonDecode(response.body),
        };
      }

    } on FirebaseAuthException catch (e) {
      // Xử lý lỗi riêng của Firebase
      String errorMessage = 'Đăng ký thất bại';
      if (e.code == 'weak-password') errorMessage = 'Mật khẩu quá yếu (cần ít nhất 6 ký tự).';
      else if (e.code == 'email-already-in-use') errorMessage = 'Email này đã được sử dụng.';
      else if (e.code == 'invalid-email') errorMessage = 'Định dạng email không hợp lệ.';

      return {'status': 400, 'body': {'detail': errorMessage}};
    } catch (e) {
      return {'status': 500, 'body': {'detail': 'Lỗi kết nối: $e'}};
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
    }
  }

  // ---------------------------------------------------------
  // 2. ĐĂNG NHẬP (FIREBASE + BACKEND)
  // ---------------------------------------------------------
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      // BƯỚC 1: Đăng nhập bằng Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

// BẮT BUỘC: Đợi lấy token xong mới chạy tiếp
      String? token = await userCredential.user?.getIdToken(true);

      print("=== TOKEN FIREBASE TRƯỚC KHI GỬI (LOGIN): $token ===");

      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          // ĐẢM BẢO CHỮ "Bearer " CÓ KHOẢNG TRẮNG Ở GIỮA
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(timeout);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
<<<<<<< HEAD
        // --- TRÍCH XUẤT ID ---
        // Dự phòng các trường hợp Backend trả về key khác nhau (id, user_id, hoặc bọc trong object user)
=======
        // TRÍCH XUẤT ID như code cũ của bạn
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
        int? extractedId = data['id'] ?? data['user_id'];
        if (extractedId == null && data['user'] != null && data['user'] is Map) {
          extractedId = data['user']['id'];
        }

        return {
          'success': true,
          'message': 'Đăng nhập thành công',
<<<<<<< HEAD
          'user': data,          // Giữ nguyên cục data cũ phòng khi bạn cần dùng thông tin khác (tên, avatar...)
          'id': extractedId,     // Trả thêm key 'id' ra ngoài để UI dùng lưu SharedPreferences
=======
          'user': data,
          'id': extractedId,
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
        };
      } else {
        return {'success': false, 'message': data['detail'] ?? 'Lỗi từ Backend'};
      }
    } on FirebaseAuthException catch (e) {
      // DÒNG MỚI: In ra màn hình xem Firebase chửi lỗi gì
      print("=== FIREBASE BÁO LỖI: ${e.code} - ${e.message} ===");

      String errorMessage = 'Sai email hoặc mật khẩu';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'Tài khoản hoặc mật khẩu không chính xác';
      }
      return {'success': false, 'message': errorMessage};
    } catch (e) {
      // Bắt các lỗi khác (như rớt mạng)
      print("=== LỖI KHÁC: $e ===");
      return {'success': false, 'message': 'Lỗi kết nối server: $e'};
    }
  }

  // ---------------------------------------------------------
  // 3. CẬP NHẬT THÔNG TIN
  // ---------------------------------------------------------
  Future<Map<String, dynamic>> updateProfile(int userId, Map<String, dynamic> updateData) async {
    try {
      // Lấy token hiện tại của user đang đăng nhập
      String? token = await _auth.currentUser?.getIdToken();
      print("=== TOKEN FIREBASE MỚI LẤY ĐƯỢC: $token ===");

      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/auth/update-profile/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // <-- Bọc token bảo vệ API
        },
        body: jsonEncode(updateData),
      ).timeout(timeout);

      return {
        'status': response.statusCode,
        'body': jsonDecode(response.body),
      };
    } catch (e) {
      print("Lỗi khi gọi API updateProfile: $e");
      return {
        'status': 500,
        'message': 'Không thể kết nối đến server. Kiểm tra mạng hoặc IP!',
      };
    }
  }

  // ---------------------------------------------------------
  // 4. ĐỔI MẬT KHẨU (FIREBASE + BACKEND)
  // ---------------------------------------------------------
  Future<Map<String, dynamic>> changePassword(int userId, String oldPwd, String newPwd) async {
    try {
      User? user = _auth.currentUser;
      String? token = await user?.getIdToken();

      if (user != null) {
        // BƯỚC 1: Đổi mật khẩu trên hệ thống Firebase (BẮT BUỘC)
        // Firebase yêu cầu đăng nhập lại (re-authenticate) trước khi đổi pass để bảo mật
        AuthCredential credential = EmailAuthProvider.credential(email: user.email!, password: oldPwd);
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPwd);
      }

      // BƯỚC 2: Cập nhật dưới Backend (nếu Backend của bạn có lưu pass)
      final response = await http.put(
        Uri.parse('${AppConfig.baseUrl}/auth/change-password/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'old_password': oldPwd,
          'new_password': newPwd,
        }),
      ).timeout(timeout);

      return {'status': response.statusCode, 'body': jsonDecode(response.body)};
    } on FirebaseAuthException catch (e) {
      return {'status': 400, 'message': 'Lỗi đổi mật khẩu: ${e.message}'};
    } catch (e) {
      return {'status': 500, 'message': 'Lỗi kết nối'};
    }
  }

  // ---------------------------------------------------------
  // 5. TIỆN ÍCH (Mới thêm)
  // ---------------------------------------------------------
  // Hàm này giúp lấy Token để dùng ở các Service khác (như Task, Habit)
  Future<String?> getToken() async {
    User? user = _auth.currentUser;
    return user != null ? await user.getIdToken(true) : null;
  }
}
