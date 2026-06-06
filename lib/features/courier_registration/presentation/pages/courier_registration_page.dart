import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smart_laundry_locker/core/constants/app_colors.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/courier_registration/presentation/providers/courier_registration_injection.dart';
import 'package:smart_laundry_locker/features/courier_registration/presentation/providers/courier_registration_provider.dart';
import 'package:smart_laundry_locker/features/courier_registration/presentation/pages/courier_registration_status_page.dart';
import 'package:go_router/go_router.dart';

class CourierRegistrationPage extends StatefulWidget {
  const CourierRegistrationPage({super.key});

  @override
  State<CourierRegistrationPage> createState() =>
      _CourierRegistrationPageState();
}

class _CourierRegistrationPageState extends State<CourierRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _legalNameController = TextEditingController();
  final _licensePlateController = TextEditingController();

  late CourierRegistrationProvider _provider;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    _provider = CourierRegistrationInjection.provideProvider(apiClient);
  }

  @override
  void dispose() {
    _legalNameController.dispose();
    _licensePlateController.dispose();
    _provider.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_provider.agreeToTerms) {
      SmartDialog.showToast('Vui lòng đồng ý với điều khoản sử dụng');
      return;
    }

    if (!_provider.isFormValid) {
      SmartDialog.showToast('Vui lòng điền đầy đủ thông tin và chọn đủ 3 ảnh');
      return;
    }

    _provider.submitApplication();
  }

  void _showImageSourceDialog({required Function(ImageSource) onSelected}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Wrap(
              runSpacing: 16,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(
                      Icons.photo_library,
                      color: Colors.black,
                    ),
                    title: const Text(
                      'Chọn từ thư viện',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(ImageSource.gallery);
                    },
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 1.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.camera_alt, color: Colors.black),
                    title: const Text(
                      'Chụp ảnh',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(ImageSource.camera);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: AppColors.background,
        // ======= TEST ONLY: START =======
        // Removed AppBar to eliminate duplicate header row
        // ======= TEST ONLY: END =======
        // appBar: AppBar(
        //   title: const Text('Đăng ký Tài xế'),
        //   backgroundColor: AppColors.surface,
        //   foregroundColor: AppColors.onBackground,
        //   elevation: 0,
        // ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Main title in body
                  const Text(
                    'Đăng ký trở thành Người Vận Chuyển',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Instructions text
                  const Text(
                    'Vui lòng điền đầy đủ thông tin và tải lên các hình ảnh yêu cầu',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Legal Name Field
                  _buildTextField(
                    controller: _legalNameController,
                    label: 'Họ và tên',
                    hintText: 'Nguyễn Văn A',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập họ và tên';
                      }
                      return null;
                    },
                    onChanged: (value) => _provider.setLegalName(value),
                  ),
                  const SizedBox(height: 20),

                  // License Plate Field
                  _buildTextField(
                    controller: _licensePlateController,
                    label: 'Biển số xe',
                    hintText: '59A-12345',
                    icon: Icons.directions_car_outlined,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Vui lòng nhập biển số xe';
                      }
                      return null;
                    },
                    onChanged: (value) => _provider.setLicensePlate(value),
                  ),
                  const SizedBox(height: 20),

                  // Vehicle Type Selection
                  _buildVehicleTypeSelector(),
                  const SizedBox(height: 32),

                  // Image Upload Section
                  const Text(
                    'Hình ảnh yêu cầu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onBackground,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Front Vehicle Image
                  _buildImageUploader(
                    label: 'Ảnh xe mặt trước',
                    image: _provider.frontVehicleImage,
                    onPick: () => _showImageSourceDialog(
                      onSelected: (source) =>
                          _provider.pickFrontVehicleImage(source: source),
                    ),
                    onRemove: () => _provider.removeFrontVehicleImage(),
                  ),
                  const SizedBox(height: 16),

                  // Back Vehicle Image
                  _buildImageUploader(
                    label: 'Ảnh xe mặt sau',
                    image: _provider.backVehicleImage,
                    onPick: () => _showImageSourceDialog(
                      onSelected: (source) =>
                          _provider.pickBackVehicleImage(source: source),
                    ),
                    onRemove: () => _provider.removeBackVehicleImage(),
                  ),
                  const SizedBox(height: 16),

                  // Portrait Image
                  _buildImageUploader(
                    label: 'Ảnh chân dung',
                    image: _provider.portraitImage,
                    onPick: () => _showImageSourceDialog(
                      onSelected: (source) =>
                          _provider.pickPortraitImage(source: source),
                    ),
                    onRemove: () => _provider.removePortraitImage(),
                  ),
                  const SizedBox(height: 24),

                  // Terms & Conditions Checkbox
                  Consumer<CourierRegistrationProvider>(
                    builder: (context, provider, child) {
                      return Row(
                        children: [
                          Checkbox(
                            value: provider.agreeToTerms,
                            onChanged: (value) {
                              provider.setAgreeToTerms(value ?? false);
                            },
                            activeColor: AppColors.success,
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                provider.setAgreeToTerms(
                                  !provider.agreeToTerms,
                                );
                              },
                              child: const Text(
                                'Tôi đồng ý với điều khoản sử dụng',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  Consumer<CourierRegistrationProvider>(
                    builder: (context, provider, child) {
                      final bool canSubmit =
                          provider.isFormValid && !provider.isLoading;
                      return ElevatedButton(
                        onPressed: canSubmit ? _handleSubmit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: AppColors.grey300,
                          disabledForegroundColor: AppColors.grey500,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.white,
                                  ),
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Đăng Ký',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.send, size: 20),
                                ],
                              ),
                      );
                    },
                  ),

                  // Error Message
                  Consumer<CourierRegistrationProvider>(
                    builder: (context, provider, child) {
                      if (provider.error != null) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            provider.error!,
                            style: const TextStyle(
                              color: AppColors.error,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Success Message & Navigation
                  Consumer<CourierRegistrationProvider>(
                    builder: (context, provider, child) {
                      if (provider.isSuccess &&
                          provider.applicationResult != null) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          SmartDialog.showToast(
                            'Đăng ký thành công! Đơn của bạn đang được xử lý.',
                          );
                          // sử dụng user id từ đơn đăng ký
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CourierRegistrationStatusPage(
                                userId: provider.applicationResult!.userId,
                              ),
                            ),
                          );
                        });
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: AppColors.onSurfaceVariant),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.success, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleTypeSelector() {
    return Consumer<CourierRegistrationProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loại phương tiện',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildVehicleTypeChip(
                    label: 'Xe đạp',
                    value: 'BIKE',
                    selectedValue: provider.vehicleType,
                    onSelected: (value) => provider.setVehicleType(value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildVehicleTypeChip(
                    label: 'Xe máy',
                    value: 'MOTORBIKE',
                    selectedValue: provider.vehicleType,
                    onSelected: (value) => provider.setVehicleType(value),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildVehicleTypeChip(
                    label: 'Ô tô',
                    value: 'CAR',
                    selectedValue: provider.vehicleType,
                    onSelected: (value) => provider.setVehicleType(value),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildVehicleTypeChip({
    required String label,
    required String value,
    required String selectedValue,
    required Function(String) onSelected,
  }) {
    final isSelected = selectedValue == value;
    return InkWell(
      onTap: () => onSelected(value),
      borderRadius: BorderRadius.circular(12),
      splashColor: AppColors.success.withOpacity(0.1),
      highlightColor: AppColors.success.withOpacity(0.05),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.success : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.success : AppColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildImageUploader({
    required String label,
    File? image,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 8),
        if (image != null)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  image,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: AppColors.white),
                  style: IconButton.styleFrom(backgroundColor: AppColors.error),
                  onPressed: onRemove,
                ),
              ),
            ],
          )
        else
          InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.outlineVariant,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 48,
                    color: AppColors.onSurfaceVariant,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Chọn ảnh',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
