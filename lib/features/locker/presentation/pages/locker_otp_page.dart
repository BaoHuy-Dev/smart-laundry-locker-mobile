import 'package:smart_laundry_locker/core/theme/shadcn_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

class LockerOtpPage extends StatefulWidget {
  const LockerOtpPage({super.key});

  @override
  State<LockerOtpPage> createState() => _LockerOtpPageState();
}

class _LockerOtpPageState extends State<LockerOtpPage> {
  final _otpController = TextEditingController();
  final _hiddenFocusNode = FocusNode();

  @override
  void dispose() {
    _otpController.dispose();
    _hiddenFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        FocusScope.of(context).requestFocus(_hiddenFocusNode);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhận hàng'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const Icon(
              Icons.lock_person_outlined,
              size: 72,
              color: AISLShadcnTheme.navyPrimary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nhập mã OTP',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vui lòng nhập mã OTP được gửi tới điện thoại của bạn để mở tủ.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 32),

            // Hidden TextField để nhập OTP, hiển thị qua 6 ô
            TextField(
              controller: _otpController,
              focusNode: _hiddenFocusNode,
              keyboardType:
                  TextInputType.text, // Changed to text to allow alphanumeric
              textCapitalization: TextCapitalization
                  .characters, // Optional: auto-capitalize letters
              maxLength: 6,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(color: Colors.transparent),
              cursorColor: Colors.transparent,
            ),

            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                FocusScope.of(context).requestFocus(_hiddenFocusNode);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  final isFocused =
                      _otpController.text.length == index &&
                      _hiddenFocusNode.hasFocus;
                  final isFilled = index < _otpController.text.length;
                  final char = isFilled ? _otpController.text[index] : '';

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 44,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isFocused
                            ? AISLShadcnTheme.navyPrimary
                            : (isFilled
                                  ? AISLShadcnTheme.navyPrimary.withOpacity(0.4)
                                  : Colors.grey.shade300),
                        width: isFocused ? 2 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      char,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(
              height: 64,
            ), // Replaced Spacer() with fixed spacing to allow scrolling

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onVerifyPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AISLShadcnTheme.navyPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const StadiumBorder(),
                  elevation: 3,
                ),
                child: const Text(
                  'Xác nhận',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _onVerifyPressed() {
    // TODO: Gọi API xác thực OTP thật.
    SmartDialog.showToast('Đang xác thực OTP...');
  }
}
