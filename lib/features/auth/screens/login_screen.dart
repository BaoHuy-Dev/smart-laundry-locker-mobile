import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/core.dart';
import '../../../core/firebase/firebase_auth_service.dart';
import '../../../core/models/user.dart';
import '../../../core/services/auth_service.dart';
import '../providers/auth_provider.dart';

enum LoginMethod { email, phone }

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();

  LoginMethod _method = LoginMethod.email;
  bool _isOtpSent = false;
  bool _isLoading = false;
  int _countdown = 0;
  String? _verificationId;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _switchMethod(LoginMethod method) {
    setState(() {
      _method = method;
      _isOtpSent = false;
      _otpController.clear();
      _countdown = 0;
      _verificationId = null;
    });
    _timer?.cancel();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_countdown <= 1) {
        timer.cancel();
        setState(() => _countdown = 0);
      } else {
        setState(() => _countdown -= 1);
      }
    });
  }

  Future<void> _handleAction() async {
    if (_method == LoginMethod.email) {
      if (_isOtpSent) {
        await _verifyEmailOtp();
      } else {
        await _sendEmailOtp();
      }
      return;
    }

    if (_isOtpSent) {
      await _verifyPhoneOtp();
    } else {
      await _sendPhoneOtp();
    }
  }

  Future<void> _sendEmailOtp() async {
    final email = _emailController.text.trim();
    if (!email.contains('@')) {
      _showMessage('Vui lòng nhập email hợp lệ');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await AuthService.sendEmailOtp(email);
      if (response.success) {
        setState(() => _isOtpSent = true);
        _startCountdown();
        _showMessage('Mã OTP đã được gửi đến email của bạn');
      } else {
        _showMessage(response.message ?? 'Không thể gửi OTP');
      }
    } catch (error) {
      _showMessage(_errorMessage(error, 'Không thể gửi OTP'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyEmailOtp() async {
    final email = _emailController.text.trim();
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showMessage('Vui lòng nhập đủ 6 số OTP');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await AuthService.verifyEmailOtp(email, otp);
      if (!response.success) {
        _showMessage(response.message ?? 'Xác thực OTP thất bại');
        return;
      }
      await _handleBackendLoginResponse(response.data, method: 'email');
    } catch (error) {
      _showMessage(_errorMessage(error, 'Xác thực OTP thất bại'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sendPhoneOtp() async {
    final phone = _formatVietnamesePhone(_phoneController.text.trim());
    if (phone == null) {
      _showMessage('Vui lòng nhập số điện thoại hợp lệ');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseAuthService.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: _completePhoneCredential,
        verificationFailed: (error) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          _showMessage(error.message ?? 'Gửi mã OTP thất bại');
        },
        codeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _isOtpSent = true;
            _isLoading = false;
          });
          _startCountdown();
          _showMessage('Mã OTP đã được gửi đến số điện thoại');
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (error) {
      _showMessage(_errorMessage(error, 'Không thể gửi OTP điện thoại'));
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyPhoneOtp() async {
    final verificationId = _verificationId;
    final otp = _otpController.text.trim();
    if (verificationId == null || otp.length != 6) {
      _showMessage('Vui lòng nhập đủ 6 số OTP');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final credential = FirebaseAuthService.getCredential(
        verificationId: verificationId,
        smsCode: otp,
      );
      await _completePhoneCredential(credential);
    } catch (error) {
      _showMessage(_errorMessage(error, 'Xác thực số điện thoại thất bại'));
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _completePhoneCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await FirebaseAuthService.signInWithCredential(
        credential,
      );
      final idToken = await userCredential.user?.getIdToken();
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Không lấy được Firebase ID token');
      }

      final response = await AuthService.phoneLogin(idToken);
      if (!response.success) {
        _showMessage(response.message ?? 'Đăng nhập thất bại');
        return;
      }

      await _handleBackendLoginResponse(
        response.data,
        method: 'phone',
        idToken: idToken,
      );
    } catch (error) {
      _showMessage(_errorMessage(error, 'Đăng nhập thất bại'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBackendLoginResponse(
    Map<String, dynamic> data, {
    required String method,
    String? idToken,
  }) async {
    if (!mounted) return;

    final isNewUser = data['newUser'] as bool? ?? false;
    if (isNewUser) {
      final queryParameters = <String, String>{'method': method};
      if (idToken != null) queryParameters['idToken'] = idToken;
      if (data['tempToken'] != null) {
        queryParameters['tempToken'] = data['tempToken'].toString();
      }
      context.pushNamed('register', queryParameters: queryParameters);
      return;
    }

    final accessToken = data['accessToken'] as String?;
    final refreshToken = data['refreshToken'] as String?;
    if (accessToken == null || refreshToken == null) {
      _showMessage('Phản hồi đăng nhập thiếu token');
      return;
    }

    await ref
        .read(authNotifierProvider.notifier)
        .login(
          AuthTokens(accessToken: accessToken, refreshToken: refreshToken),
        );
    if (mounted) context.go('/user/home');
  }

  Future<void> _handleOAuth(String provider) async {
    final baseUrl = EnvConfig.apiUrl.replaceFirst(RegExp(r'/api$'), '');
    final redirect = Uri.encodeComponent('laundrylocker://auth/callback');
    final url = Uri.parse(
      '$baseUrl/oauth2/authorization/$provider?redirect_uri=$redirect',
    );
    final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
    if (!launched) {
      _showMessage('Không thể mở đăng nhập $provider');
    }
  }

  Future<void> _resendOtp() async {
    if (_countdown > 0) return;
    if (_method == LoginMethod.email) {
      await _sendEmailOtp();
    } else {
      await _sendPhoneOtp();
    }
  }

  String? _formatVietnamesePhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.length < 9) return null;
    if (cleaned.startsWith('+')) return cleaned;
    if (cleaned.startsWith('0')) return '+84${cleaned.substring(1)}';
    return '+84$cleaned';
  }

  String _errorMessage(Object error, String fallback) {
    final text = error.toString();
    if (text.contains('Network')) {
      return 'Không thể kết nối máy chủ. Vui lòng kiểm tra backend và mạng.';
    }
    return fallback;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isEmail = _method == LoginMethod.email;
    final title = _isOtpSent ? 'Nhập mã xác thực' : 'Đăng nhập';

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Text(
                'Lock.R Locker',
                style: AppTypography.textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Locker thông minh, tiện lợi',
                style: AppTypography.textTheme.bodyLarge?.copyWith(
                  color: AppColors.primaryLight,
                ),
              ),
              const SizedBox(height: 32),
              SegmentedButton<LoginMethod>(
                segments: const [
                  ButtonSegment(
                    value: LoginMethod.email,
                    icon: Icon(Icons.email_outlined),
                    label: Text('Email'),
                  ),
                  ButtonSegment(
                    value: LoginMethod.phone,
                    icon: Icon(Icons.phone_android),
                    label: Text('Số điện thoại'),
                  ),
                ],
                selected: {_method},
                onSelectionChanged: _isLoading
                    ? null
                    : (selection) => _switchMethod(selection.first),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: AppTypography.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),
              if (!_isOtpSent)
                TextField(
                  controller: isEmail ? _emailController : _phoneController,
                  keyboardType: isEmail
                      ? TextInputType.emailAddress
                      : TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: isEmail ? 'Email' : 'Số điện thoại',
                    prefixIcon: Icon(
                      isEmail ? Icons.email_outlined : Icons.phone_outlined,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _handleAction(),
                )
              else ...[
                Text(
                  isEmail
                      ? 'Mã OTP đã gửi đến ${_emailController.text.trim()}'
                      : 'Mã OTP đã gửi đến ${_phoneController.text.trim()}',
                  style: AppTypography.textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: AppTypography.textTheme.headlineSmall?.copyWith(
                    letterSpacing: 8,
                    fontWeight: FontWeight.w800,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'OTP',
                    counterText: '',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _handleAction(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _countdown > 0 || _isLoading ? null : _resendOtp,
                    child: Text(
                      _countdown > 0
                          ? 'Gửi lại sau ${_countdown}s'
                          : 'Gửi lại mã OTP',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isLoading ? null : _handleAction,
                child: _isLoading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isOtpSent ? 'Xác thực' : 'Gửi mã OTP'),
              ),
              if (isEmail && !_isOtpSent)
                TextButton(
                  onPressed: () => context.push('/auth/forgot-password'),
                  child: const Text('Quên mật khẩu?'),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Hoặc đăng nhập với',
                      style: AppTypography.textTheme.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleOAuth('google'),
                      icon: const Icon(Icons.g_mobiledata),
                      label: const Text('Google'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleOAuth('facebook'),
                      icon: const Icon(Icons.facebook),
                      label: const Text('Facebook'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _handleOAuth('zalo'),
                child: const Text('Zalo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
