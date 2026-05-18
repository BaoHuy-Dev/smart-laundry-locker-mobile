import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/core.dart';
import '../../../core/services/auth_service.dart';

enum ForgotPasswordStep { email, reset }

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  ForgotPasswordStep _step = ForgotPasswordStep.email;
  bool _isLoading = false;
  bool _showPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      _showMessage('Vui lòng nhập email hợp lệ');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await AuthService.forgotPassword(email);
      if (response.success) {
        setState(() => _step = ForgotPasswordStep.reset);
        _showMessage('Mã OTP đã được gửi đến email của bạn');
      } else {
        _showMessage(response.message ?? 'Không thể gửi OTP');
      }
    } catch (_) {
      _showMessage('Không thể gửi OTP. Vui lòng thử lại');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final otp = _otpController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (otp.length != 6) {
      _showMessage('Vui lòng nhập mã OTP 6 số');
      return;
    }
    if (password.length < 6) {
      _showMessage('Mật khẩu mới phải có ít nhất 6 ký tự');
      return;
    }
    if (password != confirm) {
      _showMessage('Mật khẩu xác nhận không khớp');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await AuthService.resetPassword(
        email: _emailController.text.trim(),
        otp: otp,
        newPassword: password,
      );
      if (response.success) {
        _showMessage('Mật khẩu đã được đặt lại');
        if (mounted) context.pop();
      } else {
        _showMessage(response.message ?? 'Không thể đặt lại mật khẩu');
      }
    } catch (_) {
      _showMessage('Đặt lại mật khẩu thất bại. Vui lòng thử lại');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isEmailStep = _step == ForgotPasswordStep.email;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const Icon(Icons.lock_reset, color: Colors.white, size: 52),
                  const SizedBox(height: 12),
                  Text(
                    'Quên mật khẩu',
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isEmailStep
                        ? 'Nhập email để nhận mã xác thực'
                        : 'Nhập OTP và mật khẩu mới',
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isEmailStep) ...[
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email đã đăng ký',
                            hintText: 'example@email.com',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _isLoading ? null : _sendOtp,
                          child: _buttonChild('Gửi mã OTP'),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.infoColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Mã OTP đã gửi đến ${_emailController.text.trim()}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.infoColor),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            labelText: 'Mã OTP',
                            counterText: '',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: !_showPassword,
                          decoration: InputDecoration(
                            labelText: 'Mật khẩu mới',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () => setState(
                                () => _showPassword = !_showPassword,
                              ),
                              icon: Icon(
                                _showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: !_showPassword,
                          decoration: const InputDecoration(
                            labelText: 'Xác nhận mật khẩu mới',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _isLoading ? null : _resetPassword,
                          child: _buttonChild('Đặt lại mật khẩu'),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : _sendOtp,
                          child: const Text('Gửi lại mã OTP'),
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: const Text('Quay lại đăng nhập'),
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

  Widget _buttonChild(String label) {
    return _isLoading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);
  }
}
