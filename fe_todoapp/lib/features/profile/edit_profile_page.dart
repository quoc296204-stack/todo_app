import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/auth_service.dart';
// TODO: Cập nhật đường dẫn import Service của bạn
// import '../../../data/services/profile_service.dart';

=======
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // Mở comment dòng này nếu dùng Firestore

>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color inputColor = const Color(0xFFEEF1F3); // Đồng bộ màu nền input

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _jobController = TextEditingController();
  final _bioController = TextEditingController();


  String _selectedGender = 'Nam';
  final List<String> _genders = ['Nam', 'Nữ', 'Khác'];

  bool isLoading = false;
  // final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('userName') ?? "";
      _phoneController.text = prefs.getString('userPhone') ?? "";
      _birthdayController.text = prefs.getString('userBirthday') ?? "";
      _jobController.text = prefs.getString('userJob') ?? "";
      _bioController.text = prefs.getString('userBio') ?? "";

      String savedGender = prefs.getString('userGender') ?? "Nam";
      if (_genders.contains(savedGender)) _selectedGender = savedGender;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (_birthdayController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(_birthdayController.text);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: primaryColor),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        _birthdayController.text =
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  // Khai báo _authService ở đầu class _EditProfilePageState
  final AuthService _authService = AuthService();

  Future<void> _handleSaveProfile() async {
    if (_nameController.text.isEmpty) {
      _showSnackBar("Họ tên không được để trống", isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawUserId = prefs.get('userId');

      if (rawUserId == null) {
        _showSnackBar("Không tìm thấy dữ liệu người dùng!", isError: true);
        setState(() => isLoading = false);
        return;
      }

      final userId = int.parse(rawUserId.toString());

      // GỌI HÀM CÓ SẴN CỦA BẠN TỪ AUTH SERVICE
      final updateData = {
        "name": _nameController.text.trim(),
        "phone": _phoneController.text.trim(),
        "birthday": _birthdayController.text.trim(),
        "gender": _selectedGender,
        "job": _jobController.text.trim(),
        "bio": _bioController.text.trim(),
      };

      final result = await _authService.updateProfile(userId, updateData);

      if (!mounted) return;

      if (result['status'] == 200) {
        // Lưu lại dữ liệu mới vào Local
        await prefs.setString('userName', _nameController.text.trim());
        await prefs.setString('userPhone', _phoneController.text.trim());
        await prefs.setString('userBirthday', _birthdayController.text.trim());
        await prefs.setString('userGender', _selectedGender);
        await prefs.setString('userJob', _jobController.text.trim());
        await prefs.setString('userBio', _bioController.text.trim());

        _showSnackBar("Cập nhật hồ sơ thành công!", isError: false);
        Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
      } else {
        // Hiển thị lỗi từ Backend (nếu có)
        String errorMsg = result['body']?['detail'] ?? "Cập nhật thất bại. Vui lòng thử lại";
        _showSnackBar(errorMsg, isError: true);
      }
    } catch (e) {
      _showSnackBar("Lỗi kết nối: $e", isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // Hàm hiển thị thông báo chuẩn như ChangePasswordPage
  void _showSnackBar(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      behavior: SnackBarBehavior.floating, // Floating hiển thị đẹp hơn
    ));
  }

  // --- 1. KHỞI TẠO CÁC CONTROLLER ---
  final TextEditingController _nameController = TextEditingController(text: "Nguyễn Minh Anh");
  final TextEditingController _emailController = TextEditingController(text: "minhanh.dc@example.com");
  final TextEditingController _phoneController = TextEditingController(text: "090 123 4567");
  final TextEditingController _dobController = TextEditingController(text: "1995-08-24");
  final TextEditingController _jobController = TextEditingController(text: "UI/UX Designer");
  final TextEditingController _bioController = TextEditingController(text: "Một người đam mê sáng tạo...");

  // Controller cho phần mật khẩu
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Biến trạng thái cho Giới tính và Loading
  String _selectedGender = "Nữ";
  bool _isLoading = false;

  @override
  void dispose() {
    // Giải phóng bộ nhớ khi huỷ trang
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _jobController.dispose();
    _bioController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- 2. HÀM XỬ LÝ LƯU THAY ĐỔI & FIREBASE ---
  Future<void> _handleSaveProfile() async {
    // Ẩn bàn phím khi bấm lưu
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    try {
      // final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("Vui lòng đăng nhập lại để thực hiện.");

      // Phần 1: Xử lý cập nhật mật khẩu (nếu có nhập)
      if (_newPasswordController.text.isNotEmpty) {
        if (_newPasswordController.text != _confirmPasswordController.text) {
          throw Exception("Mật khẩu xác nhận không khớp!");
        }
        if (_currentPasswordController.text.isEmpty) {
          throw Exception("Vui lòng nhập mật khẩu hiện tại để xác thực!");
        }

        // Thực hiện Re-authenticate
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );
        await user.reauthenticateWithCredential(credential);

        // Đổi mật khẩu mới
        await user.updatePassword(_newPasswordController.text);
      }

      // Phần 2: Cập nhật thông tin cơ bản lên Firestore (Mở comment khi bạn đã set up Firestore)
      /*
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'dob': _dobController.text,
        'job': _jobController.text,
        'gender': _selectedGender,
        'bio': _bioController.text,
      });
      */

      // Nếu cần đổi Email, bạn sẽ phải dùng user.verifyBeforeUpdateEmail(_emailController.text)

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật thông tin thành công!", style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }

    } on FirebaseAuthException catch (e) {
      String message = "Đã xảy ra lỗi hệ thống";
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = "Mật khẩu hiện tại không đúng!";
      } else if (e.code == 'weak-password') {
        message = "Mật khẩu mới quá yếu!";
      } else if (e.code == 'requires-recent-login') {
        message = "Vui lòng đăng xuất và đăng nhập lại trước khi đổi mật khẩu.";
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
<<<<<<< HEAD
      appBar: _buildAppBar(),
=======
      appBar: AppBar(
        backgroundColor: bgColor.withOpacity(0.8),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6366F1)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Cài đặt", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: Center(
              child: Text("DC.", style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w900, fontSize: 18)),
            ),
          )
        ],
      ),

>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
<<<<<<< HEAD
            const Text("Thông tin cá nhân", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
            const SizedBox(height: 32),

            _buildFormSection(
              title: "Chi tiết tài khoản",
              icon: Icons.badge_outlined,
              children: [
                _buildInputField("Họ và tên", _nameController),
                const SizedBox(height: 16),
                _buildInputField("Số điện thoại", _phoneController),
                const SizedBox(height: 16),
                _buildDatePickerField("Ngày sinh (YYYY-MM-DD)"),
                const SizedBox(height: 16),
                _buildGenderDropdown(),
                const SizedBox(height: 16),
                _buildInputField("Vị trí công việc", _jobController),
                const SizedBox(height: 16),
                _buildInputField("Giới thiệu ngắn", _bioController, isTextArea: true),
              ],
            ),

            const SizedBox(height: 48),
            _buildSubmitButton(),
            const SizedBox(height: 60),
=======
            const Text("Chỉnh sửa hồ sơ", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1)),
            const Text("Cập nhật thông tin cá nhân và quản lý bảo mật tài khoản của bạn.", style: TextStyle(color: Colors.grey, fontSize: 14)),

            const SizedBox(height: 32),
            _buildProfileImagePicker(),
            const SizedBox(height: 32),

            _buildFormSection(
              title: "Thông tin cơ bản",
              icon: Icons.person,
              children: [
                _buildInputField("Họ và tên", controller: _nameController),
                _buildInputField("Email", controller: _emailController),
                _buildInputField("Số điện thoại", controller: _phoneController),
                _buildInputField("Ngày sinh", controller: _dobController),
              ],
            ),

            const SizedBox(height: 24),

            _buildFormSection(
              title: "Nghề nghiệp & Giới thiệu",
              icon: Icons.work,
              children: [
                _buildInputField("Vị trí hiện tại", controller: _jobController),
                _buildGenderDropdown(), // Sử dụng widget riêng cho Dropdown
                _buildInputField("Mô tả ngắn", controller: _bioController, isTextArea: true),
              ],
            ),

            const SizedBox(height: 24),

            // Đã mở comment phần Password
            _buildFormSection(
              title: "Đổi mật khẩu",
              icon: Icons.lock_outline,
              children: [
                _buildInputField("Mật khẩu hiện tại", controller: _currentPasswordController, isPassword: true),
                _buildInputField("Mật khẩu mới", controller: _newPasswordController, isPassword: true),
                _buildInputField("Xác nhận mật khẩu mới", controller: _confirmPasswordController, isPassword: true),
              ],
            ),

            const SizedBox(height: 40),
            _buildActionButtons(context),
            const SizedBox(height: 120),
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  PreferredSizeWidget _buildAppBar() => AppBar(
    backgroundColor: bgColor.withOpacity(0.8),
    elevation: 0,
    iconTheme: const IconThemeData(color: Colors.black),
    leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF6366F1)), onPressed: () => Navigator.pop(context)),
    title: const Text("Chỉnh sửa hồ sơ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
  );

=======
  // --- CÁC WIDGET CON ---

  Widget _buildProfileImagePicker() {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              image: const DecorationImage(
                image: NetworkImage('https://via.placeholder.com/150'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
            child: const Icon(Icons.photo_camera, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
  Widget _buildFormSection({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildInputField(String label, TextEditingController controller, {bool isTextArea = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: inputColor, borderRadius: BorderRadius.circular(16)),
          child: TextField(
            controller: controller,
            maxLines: isTextArea ? 3 : 1,
            decoration: const InputDecoration(border: InputBorder.none),
=======
  // Cập nhật để nhận TextEditingController
  Widget _buildInputField(String label, {TextEditingController? controller, bool isPassword = false, bool isTextArea = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: controller,
              obscureText: isPassword,
              maxLines: isTextArea ? 4 : 1,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
          ),
        ],
      ),
    );
  }

  // Tách riêng Dropdown để quản lý state dễ hơn
  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("GIỚI TÍNH", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedGender,
                isExpanded: true,
                items: ["Nữ", "Nam", "Khác"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() => _selectedGender = newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
            child: TextButton(
                onPressed: _isLoading ? null : () => Navigator.pop(context),
                child: Text("Hủy", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold))
            )
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            // Khóa nút khi đang tải
            onPressed: _isLoading ? null : _handleSaveProfile,
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
            ),
            // Hiển thị vòng xoay loading khi đang lưu
            child: _isLoading
                ? const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
            )
                : const Text("Lưu thay đổi", style: TextStyle(fontWeight: FontWeight.bold)),
>>>>>>> 5a52b32830a0b79c1c954ac0fc05703032e6414a
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: inputColor, borderRadius: BorderRadius.circular(16)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_birthdayController.text.isEmpty ? "Chọn ngày sinh" : _birthdayController.text,
                  style: TextStyle(color: _birthdayController.text.isEmpty ? Colors.grey : Colors.black),
                ),
                Icon(Icons.calendar_today, color: Colors.grey[500], size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("GIỚI TÍNH", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: inputColor, borderRadius: BorderRadius.circular(16)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedGender,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[500]),
              items: _genders.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (newValue) => setState(() => _selectedGender = newValue!),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() => SizedBox(
    width: double.infinity,
    height: 60,
    child: ElevatedButton(
      onPressed: isLoading ? null : _handleSaveProfile,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
        elevation: 0,
      ),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("Lưu thay đổi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ),
  );
}