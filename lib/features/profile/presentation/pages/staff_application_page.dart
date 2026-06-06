import 'dart:io';
import 'dart:typed_data';

import 'package:smart_laundry_locker/core/constants/app_colors.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/profile/presentation/providers/profile_injection.dart';
import 'package:smart_laundry_locker/features/staff_application/application/use_cases/submit_staff_application_use_case.dart';
import 'package:smart_laundry_locker/features/staff_application/domain/entities/vehicle_type.dart';
import 'package:smart_laundry_locker/features/staff_application/presentation/providers/staff_application_injection.dart';
import 'package:smart_laundry_locker/features/staff_application/presentation/providers/staff_application_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class StaffApplicationPage extends StatefulWidget {
  const StaffApplicationPage({super.key});

  @override
  State<StaffApplicationPage> createState() => _StaffApplicationPageState();
}

class EmployeeRegistrationPage extends StaffApplicationPage {
  const EmployeeRegistrationPage({super.key});
}

class _StaffApplicationPageState extends State<StaffApplicationPage> {
  final _formKey = GlobalKey<FormState>();

  final _legalNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _roleController = TextEditingController();

  String? _vehicleTypeId;
  DateTime? _dob;
  String? _dobError;

  final ImagePicker _imagePicker = ImagePicker();

  XFile? _portraitImage;
  XFile? _frontVehicleImage;
  XFile? _rearVehicleImage;
  XFile? _sideVehicleImage;

  late final StaffApplicationProvider _staffApplicationProvider;

  @override
  void initState() {
    super.initState();
    _staffApplicationProvider = StaffApplicationInjection.provideProvider(
      ApiClient(),
    );
    _prefillUserInfo();
    _staffApplicationProvider.fetchVehicleTypes();
  }

  Future<void> _prefillUserInfo() async {
    final repository = ProfileInjection.provideProfileRepository(ApiClient());
    final profileResult = await repository.getProfile();
    if (!mounted) return;

    profileResult.fold((_) {}, (profile) {
      _legalNameController.text = profile.fullName;
      _phoneController.text = profile.phoneNumber;
    });
  }

  @override
  void dispose() {
    _legalNameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _licensePlateController.dispose();
    _roleController.dispose();
    _staffApplicationProvider.dispose();
    super.dispose();
  }

  Future<void> _showSubmitSuccessDialog() async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Đơn đăng ký của bạn đã được gửi đi',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vui lòng chờ đến khi có thông báo mới từ hệ thống.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0A2342),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shadowColor: Colors.black.withValues(alpha: 0.10),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Đóng'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDob(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  int _ageInYears(DateTime dob, DateTime now) {
    int years = now.year - dob.year;
    final hasHadBirthdayThisYear =
        (now.month > dob.month) ||
        (now.month == dob.month && now.day >= dob.day);
    if (!hasHadBirthdayThisYear) years -= 1;
    return years;
  }

  DateTime? _tryParseDobText(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;

    final parts = text.split('/');
    if (parts.length != 3) return null;

    final day = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final year = int.tryParse(parts[2]);
    if (day == null || month == null || year == null) return null;

    final parsed = DateTime(year, month, day);
    final isValid =
        parsed.year == year &&
        parsed.month == month &&
        parsed.day == day &&
        !parsed.isAfter(DateTime.now());
    return isValid ? parsed : null;
  }

  Future<void> _pickDob() async {
    if (!mounted) return;
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 18, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 100, 1, 1),
      lastDate: now,
      helpText: 'Chọn ngày sinh',
      confirmText: 'Chọn',
      cancelText: 'Hủy',
      builder: (context, child) {
        final light = ThemeData.light();
        return Theme(
          data: light.copyWith(
            dialogBackgroundColor: AppColors.white,
            colorScheme: light.colorScheme.copyWith(
              primary: AppColors.success,
              onPrimary: AppColors.white,
              surface: AppColors.white,
              onSurface: AppColors.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;
    setState(() {
      _dob = DateTime(picked.year, picked.month, picked.day);
      _dobController.text = _formatDob(_dob!);
      _dobError = null;
    });
  }

  void _onDobTextChanged(String value) {
    final text = value.trim();
    if (text.isEmpty) {
      setState(() {
        _dob = null;
        _dobError = null;
      });
      return;
    }

    final parsed = _tryParseDobText(text);
    if (parsed == null) {
      setState(() {
        _dob = null;
        // Chỉ báo lỗi khi user đã nhập tương đối đủ, tránh báo quá sớm
        _dobError = text.length >= 8
            ? 'Định dạng ngày sinh phải là DD/MM/YYYY'
            : null;
      });
      return;
    }

    final age = _ageInYears(parsed, DateTime.now());
    setState(() {
      _dob = parsed;
      _dobError = age < 18 ? 'Bạn phải đủ 18 tuổi để đăng ký' : null;
    });
  }

  Future<void> _handleSubmit() async {
    final legalName = _legalNameController.text.trim();
    final licensePlate = _licensePlateController.text.trim();
    final role = _roleController.text.trim();
    final vehicleTypeId = _vehicleTypeId;

    DateTime? dob = _dob;
    if (dob == null && _dobController.text.trim().isNotEmpty) {
      dob = _tryParseDobText(_dobController.text);
      if (dob != null) {
        _dob = dob;
      }
    }
    if (dob == null) {
      setState(() {
        _dobError = _dobController.text.trim().isEmpty
            ? 'Vui lòng chọn ngày sinh'
            : 'Định dạng ngày sinh phải là DD/MM/YYYY';
      });
      SmartDialog.showToast(
        _dobController.text.trim().isEmpty
            ? 'Vui lòng chọn ngày sinh.'
            : 'Ngày sinh không hợp lệ.',
      );
      return;
    }
    final age = _ageInYears(dob, DateTime.now());
    if (age < 18) {
      setState(() {
        _dobError = 'Bạn phải đủ 18 tuổi để đăng ký';
      });
      SmartDialog.showToast('Bạn phải đủ 18 tuổi để đăng ký.');
      return;
    }

    if (legalName.isEmpty ||
        licensePlate.isEmpty ||
        role.isEmpty ||
        vehicleTypeId == null ||
        vehicleTypeId.isEmpty) {
      SmartDialog.showToast('Vui lòng điền đủ thông tin bắt buộc.');
      return;
    }

    if (_frontVehicleImage == null ||
        _rearVehicleImage == null ||
        _portraitImage == null) {
      SmartDialog.showToast(
        'Vui lòng chọn đủ 3 ảnh: Mặt trước xe, Mặt sau xe, Ảnh chân dung.',
      );
      return;
    }

    final params = SubmitStaffApplicationParams(
      legalName: legalName,
      licensePlate: licensePlate,
      vehicleTypeId: vehicleTypeId,
      role: role,
      frontVehicleImagePath: _frontVehicleImage!.path,
      backVehicleImagePath: _rearVehicleImage!.path,
      portraitImagePath: _portraitImage!.path,
    );

    final app = await _staffApplicationProvider.submit(params);
    if (!mounted) return;

    final failure = _staffApplicationProvider.failure;
    if (app == null && failure != null) {
      final message = failure.message;
      final isConflict =
          failure.code == '409' ||
          message.toLowerCase().contains('đang chờ') ||
          message.toLowerCase().contains('pending');
      SmartDialog.showToast(
        isConflict
            ? 'Bạn đã có đơn đang chờ xử lý.'
            : (message.isNotEmpty ? message : 'Gửi đơn thất bại.'),
      );
      return;
    }

    await _showSubmitSuccessDialog();
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = AppColors.success;
    final inputTextStyle = theme.textTheme.bodyMedium?.copyWith(
      color: Colors.black87,
    );

    return ChangeNotifierProvider.value(
      value: _staffApplicationProvider,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Đăng ký trở thành nhân viên'),
          foregroundColor: Colors.black,
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSectionCard(
                        title: '1. Thông tin cá nhân',
                        children: [
                          _buildTextField(
                            controller: _legalNameController,
                            label: 'Họ và tên',
                            hintText: 'Nguyễn Văn A',
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            style: inputTextStyle,
                            readOnly: true,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _phoneController,
                            label: 'Số điện thoại',
                            hintText: '0981234567',
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            style: inputTextStyle,
                            readOnly: true,
                          ),
                          const SizedBox(height: 12),
                          _buildDateField(
                            label: 'Ngày sinh',
                            hintText: 'DD/MM/YYYY',
                            style: inputTextStyle,
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            label: 'Khu vực hoạt động',
                            hintText: 'Thu Duc, Quan 9',
                            textInputAction: TextInputAction.next,
                            style: inputTextStyle,
                          ),
                          const SizedBox(height: 12),
                          _buildRoleTextField(
                            controller: _roleController,
                            style: inputTextStyle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: '2. Thông tin phương tiện',
                        children: [
                          const Text(
                            'Chỉ điền khi bạn muốn đăng ký trở thành Tài xế Giao hàng',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Consumer<StaffApplicationProvider>(
                            builder: (context, provider, child) {
                              if (provider.isLoadingVehicles) {
                                return Row(
                                  children: const [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Đang tải danh sách loại xe...',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                );
                              }

                              if (provider.vehicleTypes.isEmpty) {
                                return const Text(
                                  'Không tải được danh sách loại xe. Vui lòng thử lại sau.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                );
                              }

                              return _buildDropdownField(
                                label: 'Loại xe',
                                value: _vehicleTypeId,
                                options: provider.vehicleTypes,
                                onChanged: (value) {
                                  setState(() {
                                    _vehicleTypeId = value;
                                  });
                                  if (value != null) {
                                    debugPrint('Selected Vehicle ID: $value');
                                  }
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            controller: _licensePlateController,
                            label: 'Biển số xe',
                            hintText: '29A-123.45',
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.next,
                            style: inputTextStyle,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSectionCard(
                        title: '3. Ảnh hồ sơ',
                        children: [
                          const Text(
                            'Ảnh chân dung',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildImagePickerBox(
                                type: _ImageType.portrait,
                                label: 'Chọn ảnh chân dung',
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Ảnh phương tiện',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Thêm ảnh phương tiện khi bạn muốn trở thành Tài xế Giao hàng',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _buildImagePickerBox(
                                type: _ImageType.frontVehicle,
                                label: 'Ảnh mặt trước xe',
                              ),
                              _buildImagePickerBox(
                                type: _ImageType.rearVehicle,
                                label: 'Ảnh mặt sau xe',
                              ),
                              _buildImagePickerBox(
                                type: _ImageType.sideVehicle,
                                label: 'Ảnh mặt ngang xe',
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              Consumer<StaffApplicationProvider>(
                builder: (context, provider, child) {
                  if (!provider.isLoading) return const SizedBox.shrink();
                  return Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.15),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            color: AppColors.background,
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 0,
                  shadowColor: Colors.black.withValues(alpha: 0.15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _handleSubmit,
                child: const Text('Gửi đơn đăng ký'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onPickImage(String type) async {
    if (!mounted) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
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
                        LucideIcons.camera,
                        color: Colors.black,
                      ),
                      title: const Text(
                        'Chụp ảnh mới',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () => Navigator.pop(context, ImageSource.camera),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        LucideIcons.image,
                        color: Colors.black,
                      ),
                      title: const Text(
                        'Chọn từ thư viện',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onTap: () => Navigator.pop(context, ImageSource.gallery),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (source == null) return;

    final picked = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (picked == null || !mounted) return;

    final compressed = await _compressImageForUpload(picked);
    if (!mounted) return;
    final finalFile = compressed ?? picked;

    setState(() {
      switch (type) {
        case _ImageType.portrait:
          _portraitImage = finalFile;
          break;
        case _ImageType.frontVehicle:
          _frontVehicleImage = finalFile;
          break;
        case _ImageType.rearVehicle:
          _rearVehicleImage = finalFile;
          break;
        case _ImageType.sideVehicle:
          _sideVehicleImage = finalFile;
          break;
      }
    });
  }

  Future<XFile?> _compressImageForUpload(XFile input) async {
    try {
      final originalBytes = await input.readAsBytes();

      Uint8List? compressed = await FlutterImageCompress.compressWithList(
        originalBytes,
        minWidth: 1280,
        minHeight: 1280,
        quality: 70,
        format: CompressFormat.jpeg,
      );

      if (compressed.length > 700 * 1024) {
        compressed = await FlutterImageCompress.compressWithList(
          compressed,
          minWidth: 1024,
          minHeight: 1024,
          quality: 55,
          format: CompressFormat.jpeg,
        );
      }

      final outPath =
          '${Directory.systemTemp.path}/staff_${DateTime.now().microsecondsSinceEpoch}.jpg';
      final outFile = File(outPath);
      await outFile.writeAsBytes(compressed, flush: true);
      return XFile(outPath);
    } catch (_) {
      return null;
    }
  }

  void _removePickedImage(String type) {
    setState(() {
      switch (type) {
        case _ImageType.portrait:
          _portraitImage = null;
          break;
        case _ImageType.frontVehicle:
          _frontVehicleImage = null;
          break;
        case _ImageType.rearVehicle:
          _rearVehicleImage = null;
          break;
        case _ImageType.sideVehicle:
          _sideVehicleImage = null;
          break;
      }
    });
  }

  XFile? _getPickedImage(String type) {
    switch (type) {
      case _ImageType.portrait:
        return _portraitImage;
      case _ImageType.frontVehicle:
        return _frontVehicleImage;
      case _ImageType.rearVehicle:
        return _rearVehicleImage;
      case _ImageType.sideVehicle:
        return _sideVehicleImage;
    }
    return null;
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      color: Colors.white,
      elevation: 0.5,
      shadowColor: AppColors.success.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.success.withValues(alpha: 0.20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    String? hintText,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      suffixIcon: suffixIcon,
      errorText: errorText,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.success, width: 1.5),
      ),
    );
  }

  Widget _buildTextField({
    TextEditingController? controller,
    required String label,
    String? hintText,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextStyle? style,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          style: style ?? const TextStyle(color: Colors.black87),
          decoration: _inputDecoration(hintText: hintText),
        ),
      ],
    );
  }

  Widget _buildRoleTextField({
    required TextEditingController controller,
    TextStyle? style,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Vai trò',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: style ?? const TextStyle(color: Colors.black87),
          decoration: _inputDecoration(
            hintText: 'Nhân viên giao hàng, Kỹ thuật viên...',
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    String? hintText,
    TextStyle? style,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _dobController,
          keyboardType: TextInputType.datetime,
          style: style ?? const TextStyle(color: Colors.black87),
          decoration: _inputDecoration(
            hintText: hintText,
            errorText: _dobError,
            suffixIcon: IconButton(
              icon: const Icon(Icons.calendar_today_outlined),
              onPressed: _pickDob,
            ),
          ),
          onChanged: _onDobTextChanged,
        ),
      ],
    );
  }

  void _showVehicleTypePicker({
    required List<VehicleType> options,
    required String? currentValue,
    required ValueChanged<String?> onSelected,
  }) {
    int initialIndex = options.indexWhere((opt) => opt.id == currentValue);
    if (initialIndex == -1) initialIndex = 0;

    showCupertinoModalPopup<void>(
      context: context,
      builder: (innerContext) => Container(
        height: 300,
        padding: const EdgeInsets.only(top: 6),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(innerContext).viewInsets.bottom,
        ),
        color: Colors.white,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.white, width: 0.0),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: const Text(
                        'Hủy',
                        style: TextStyle(color: Colors.grey),
                      ),
                      onPressed: () => Navigator.pop(innerContext),
                    ),
                    CupertinoButton(
                      child: const Text(
                        'Chọn',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        if (options.isNotEmpty) {
                          onSelected(options[initialIndex].id);
                        }
                        Navigator.pop(innerContext);
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(
                    initialItem: initialIndex,
                  ),
                  onSelectedItemChanged: (int selectedIndex) {
                    initialIndex = selectedIndex;
                  },
                  children: List<Widget>.generate(options.length, (int index) {
                    return Center(
                      child: Text(
                        options[index].name,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<VehicleType> options,
    required ValueChanged<String?> onChanged,
  }) {
    final selectedOption = options.cast<VehicleType?>().firstWhere(
      (opt) => opt?.id == value,
      orElse: () => null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showVehicleTypePicker(
            options: options,
            currentValue: value,
            onSelected: onChanged,
          ),
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: _inputDecoration().copyWith(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              suffixIcon: const Icon(
                LucideIcons.chevronDown,
                size: 18,
                color: Colors.grey,
              ),
            ),
            child: Text(
              selectedOption?.name ?? 'Chọn',
              style: TextStyle(
                color: selectedOption != null
                    ? Colors.black87
                    : Colors.grey.shade400,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePickerBox({required String type, required String label}) {
    final picked = _getPickedImage(type);

    return SizedBox(
      width: 110,
      height: 110,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onPickImage(type),
          borderRadius: BorderRadius.circular(12),
          splashColor: AppColors.success.withValues(alpha: 0.12),
          highlightColor: AppColors.success.withValues(alpha: 0.06),
          child: _DashedBorder(
            radius: 12,
            color: AppColors.success.withValues(alpha: 0.35),
            strokeWidth: 1,
            dashWidth: 6,
            dashSpace: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: picked == null
                        ? Container(
                            color: Colors.grey.shade50,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    LucideIcons.plus,
                                    color: AppColors.success,
                                    size: 22,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Image.file(File(picked.path), fit: BoxFit.cover),
                  ),
                  if (picked != null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Material(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _removePickedImage(type),
                          child: Padding(
                            padding: const EdgeInsets.all(6),
                            child: Icon(
                              LucideIcons.x,
                              size: 16,
                              color: Colors.red.shade600,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ImageType {
  static const portrait = 'portrait';
  static const frontVehicle = 'frontVehicle';
  static const rearVehicle = 'rearVehicle';
  static const sideVehicle = 'sideVehicle';
}

class _DashedBorder extends StatelessWidget {
  final Widget child;
  final double radius;
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  const _DashedBorder({
    required this.child,
    required this.radius,
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        radius: radius,
        color: color,
        strokeWidth: strokeWidth,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
      ),
      child: child,
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final double radius;
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  const _DashedBorderPainter({
    required this.radius,
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final path = Path()..addRRect(rrect);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeWidth = strokeWidth;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.radius != radius ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashSpace != dashSpace;
  }
}
