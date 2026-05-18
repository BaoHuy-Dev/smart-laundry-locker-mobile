import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/core.dart';
import '../../../core/models/user.dart';
import '../../../core/services/auth_service.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key, this.idToken, this.tempToken, this.method});

  final String? idToken;
  final String? tempToken;
  final String? method;

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _agreeTerms = false;
  bool _isLoading = false;

  bool get _showEmailField => widget.method == 'phone';
  bool get _showPhoneField => widget.method == 'email';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthdayController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final birthday = _birthdayController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || birthday.isEmpty) {
      _showMessage('Vui lòng nhập đầy đủ họ, tên và ngày sinh');
      return;
    }

    final birthdayDate = DateTime.tryParse(birthday);
    if (birthdayDate == null || !birthdayDate.isBefore(DateTime.now())) {
      _showMessage('Ngày sinh phải đúng định dạng YYYY-MM-DD và ở quá khứ');
      return;
    }

    if (_showEmailField &&
        _emailController.text.trim().isNotEmpty &&
        !_emailController.text.trim().contains('@')) {
      _showMessage('Email không hợp lệ');
      return;
    }

    if (_showPhoneField &&
        _phoneController.text.trim().isNotEmpty &&
        _phoneController.text.trim().length < 9) {
      _showMessage('Số điện thoại không hợp lệ');
      return;
    }

    if (!_agreeTerms) {
      _showMessage('Vui lòng đồng ý với điều khoản sử dụng');
      return;
    }

    if ((widget.idToken == null || widget.idToken!.isEmpty) &&
        (widget.tempToken == null || widget.tempToken!.isEmpty)) {
      _showMessage('Phiên đăng ký không hợp lệ. Vui lòng đăng nhập lại.');
      context.go('/auth/login');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final payload = <String, dynamic>{
        'firstName': firstName,
        'lastName': lastName,
        'birthday': birthday,
        if (widget.idToken != null && widget.idToken!.isNotEmpty)
          'idToken': widget.idToken,
        if (widget.tempToken != null && widget.tempToken!.isNotEmpty)
          'tempToken': widget.tempToken,
        if (_showEmailField && _emailController.text.trim().isNotEmpty)
          'email': _emailController.text.trim(),
        if (_showPhoneField && _phoneController.text.trim().isNotEmpty)
          'phoneNumber': _phoneController.text.trim(),
      };

      final response = widget.method == 'email'
          ? await AuthService.emailCompleteRegistration(payload)
          : await AuthService.completeRegistration(payload);

      if (!response.success) {
        _showMessage(response.message ?? 'Đăng ký thất bại');
        return;
      }

      final accessToken = response.data['accessToken'] as String?;
      final refreshToken = response.data['refreshToken'] as String?;
      if (accessToken == null || refreshToken == null) {
        _showMessage('Phản hồi đăng ký thiếu token');
        return;
      }

      await ref
          .read(authNotifierProvider.notifier)
          .login(
            AuthTokens(accessToken: accessToken, refreshToken: refreshToken),
          );

      if (mounted) {
        _showMessage('Đăng ký thành công');
        context.go('/user/home');
      }
    } catch (error) {
      _showMessage(_errorMessage(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _errorMessage(Object error) {
    final text = error.toString();
    if (text.contains('401')) {
      return 'Phiên đăng ký đã hết hạn. Vui lòng đăng nhập lại.';
    }
    if (text.contains('Network')) {
      return 'Không thể kết nối máy chủ. Vui lòng thử lại.';
    }
    return 'Đăng ký thất bại. Vui lòng thử lại.';
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const Icon(
                    Icons.person_add_alt_1,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hoàn tất đăng ký',
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cung cấp thông tin để hoàn tất tài khoản',
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _field(
                        controller: _firstNameController,
                        label: 'Tên *',
                        hint: 'Văn A',
                        icon: Icons.person_outline,
                      ),
                      _field(
                        controller: _lastNameController,
                        label: 'Họ *',
                        hint: 'Nguyễn',
                        icon: Icons.badge_outlined,
                      ),
                      _field(
                        controller: _birthdayController,
                        label: 'Ngày sinh *',
                        hint: '1990-01-15',
                        icon: Icons.calendar_today_outlined,
                        keyboardType: TextInputType.datetime,
                        helper: 'Định dạng: YYYY-MM-DD',
                      ),
                      if (_showEmailField)
                        _field(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'example@email.com',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      if (_showPhoneField)
                        _field(
                          controller: _phoneController,
                          label: 'Số điện thoại',
                          hint: '987654321',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: _agreeTerms,
                        onChanged: (value) =>
                            setState(() => _agreeTerms = value ?? false),
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          'Tôi đồng ý với Điều khoản sử dụng và Chính sách bảo mật',
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _register,
                          child: _isLoading
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Hoàn tất đăng ký'),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _benefitTile(Icons.local_offer, 'Giảm giá đơn đầu tiên'),
                      _benefitTile(Icons.stars, 'Tích điểm đổi quà'),
                      _benefitTile(
                        Icons.notifications_active,
                        'Thông báo theo dõi đơn hàng',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? helper,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helper,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _benefitTile(IconData icon, String text) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: AppColors.successColor),
      title: Text(text),
      contentPadding: EdgeInsets.zero,
    );
  }
}
