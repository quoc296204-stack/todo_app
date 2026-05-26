import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/services/auth_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // --- CẤU HÌNH MÀU ---
  final Color primaryColor = const Color(0xFF4647D3);
  final Color bgColor = const Color(0xFFF5F7F9);
  final Color inputColor = const Color(0xFFEEF1F3);

  // --- CONTROLLERS ---
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _jobController = TextEditingController();
  final _bioController = TextEditingController();

  String _selectedGender = 'Nam';
  final List<String> _genders = ['Nam', 'Nữ', 'Khác'];
  bool isLoading = false;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _birthdayController.dispose();
    _jobController.dispose();
    _bioController.dispose();
    super.dispose();
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
    try {
      if (_birthdayController.text.isNotEmpty) {
        initialDate = DateTime.parse(_birthdayController.text);
      }
    } catch (_) {}

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthdayController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _handleSaveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar("Họ tên không được để trống", isError: true);
      return;
    }

    setState(() => isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawUserId = prefs.get('userId');

      if (rawUserId == null) {
        _showSnackBar("Lỗi: Không tìm thấy ID người dùng", isError: true);
        setState(() => isLoading = false);
        return;
      }

      final userId = int.parse(rawUserId.toString());

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
        await prefs.setString('userName', _nameController.text.trim());
        await prefs.setString('userPhone', _phoneController.text.trim());
        await prefs.setString('userBirthday', _birthdayController.text.trim());
        await prefs.setString('userGender', _selectedGender);
        await prefs.setString('userJob', _jobController.text.trim());
        await prefs.setString('userBio', _bioController.text.trim());

        _showSnackBar("Cập nhật hồ sơ thành công!", isError: false);
        Future.delayed(const Duration(seconds: 1), () => Navigator.pop(context));
      } else {
        _showSnackBar(result['body']?['detail'] ?? "Cập nhật thất bại", isError: true);
      }
    } catch (e) {
      _showSnackBar("Lỗi kết nối: $e", isError: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showSnackBar(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF6366F1)), onPressed: () => Navigator.pop(context)),
        title: const Text("Chỉnh sửa hồ sơ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
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
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection({required String title, required IconData icon, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: primaryColor, size: 20), const SizedBox(width: 8), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

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
                Text(_birthdayController.text.isEmpty ? "Chọn ngày sinh" : _birthdayController.text, style: TextStyle(color: _birthdayController.text.isEmpty ? Colors.grey : Colors.black)),
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
              items: _genders.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
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
      style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)), elevation: 0),
      child: isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text("Lưu thay đổi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    ),
  );
}