import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_laundry_locker/features/courier_registration/application/use_cases/submit_courier_application_use_case.dart';
import 'package:smart_laundry_locker/features/courier_registration/application/use_cases/check_courier_status_use_case.dart';
import 'package:smart_laundry_locker/features/courier_registration/domain/entities/courier_application_entity.dart';

class CourierRegistrationProvider extends ChangeNotifier {
  final SubmitCourierApplicationUseCase _submitUseCase;
  final CheckCourierStatusUseCase _checkStatusUseCase;

  CourierRegistrationProvider({
    required SubmitCourierApplicationUseCase submitUseCase,
    required CheckCourierStatusUseCase checkStatusUseCase,
  }) : _submitUseCase = submitUseCase,
       _checkStatusUseCase = checkStatusUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCheckingStatus = false;
  bool get isCheckingStatus => _isCheckingStatus;

  String? _error;
  String? get error => _error;

  bool _isSuccess = false;
  bool get isSuccess => _isSuccess;

  CourierApplicationEntity? _applicationResult;
  CourierApplicationEntity? get applicationResult => _applicationResult;

  // status đơn hiện tại (null = chưa đăng ký)
  CourierApplicationEntity? _currentApplication;
  CourierApplicationEntity? get currentApplication => _currentApplication;

  String _legalName = '';
  String get legalName => _legalName;

  String _licensePlate = '';
  String get licensePlate => _licensePlate;

  String _vehicleType = 'MOTORBIKE'; // mặc định
  String get vehicleType => _vehicleType;

  File? _frontVehicleImage;
  File? get frontVehicleImage => _frontVehicleImage;

  File? _backVehicleImage;
  File? get backVehicleImage => _backVehicleImage;

  File? _portraitImage;
  File? get portraitImage => _portraitImage;

  bool _agreeToTerms = false;
  bool get agreeToTerms => _agreeToTerms;

  bool get isFormValid {
    return _legalName.trim().isNotEmpty &&
        _licensePlate.trim().isNotEmpty &&
        _vehicleType.isNotEmpty &&
        _frontVehicleImage != null &&
        _backVehicleImage != null &&
        _portraitImage != null &&
        _agreeToTerms;
  }

  void setLegalName(String value) {
    _legalName = value;
    notifyListeners();
  }

  void setLicensePlate(String value) {
    _licensePlate = value;
    notifyListeners();
  }

  void setVehicleType(String value) {
    _vehicleType = value;
    notifyListeners();
  }

  void setAgreeToTerms(bool value) {
    _agreeToTerms = value;
    notifyListeners();
  }

  Future<void> pickFrontVehicleImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        _frontVehicleImage = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Không thể chọn ảnh: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> pickBackVehicleImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        _backVehicleImage = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Không thể chọn ảnh: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> pickPortraitImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        _portraitImage = File(pickedFile.path);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Không thể chọn ảnh: ${e.toString()}';
      notifyListeners();
    }
  }

  void removeFrontVehicleImage() {
    _frontVehicleImage = null;
    notifyListeners();
  }

  void removeBackVehicleImage() {
    _backVehicleImage = null;
    notifyListeners();
  }

  void removePortraitImage() {
    _portraitImage = null;
    notifyListeners();
  }

  Future<void> submitApplication() async {
    if (!isFormValid) {
      _error = 'Vui lòng điền đầy đủ thông tin và chọn đủ 3 ảnh';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _isSuccess = false;
    notifyListeners();

    final params = SubmitCourierApplicationParams(
      legalName: _legalName.trim(),
      licensePlate: _licensePlate.trim(),
      vehicleType: _vehicleType,
      frontVehicleImagePath: _frontVehicleImage!.path,
      backVehicleImagePath: _backVehicleImage!.path,
      portraitImagePath: _portraitImage!.path,
    );

    final result = await _submitUseCase(params);

    result.fold(
      (failure) {
        _isLoading = false;
        _error = failure.message;
        _isSuccess = false;
        notifyListeners();
      },
      (entity) {
        _isLoading = false;
        _error = null;
        _isSuccess = true;
        _applicationResult = entity;
        // auto update currentApplication sau khi submit thành công
        _currentApplication = entity;
        notifyListeners();
      },
    );
  }

  // check application status
  Future<void> checkStatus({required String userId}) async {
    _isCheckingStatus = true;
    _error = null;
    notifyListeners();

    final params = CheckCourierStatusParams(userId: userId);
    final result = await _checkStatusUseCase(params);

    result.fold(
      (failure) {
        _isCheckingStatus = false;
        _error = failure.message;
        _currentApplication = null;
        notifyListeners();
      },
      (entity) {
        _isCheckingStatus = false;
        _error = null;
        _currentApplication = entity; // null nếu chưa đăng ký
        notifyListeners();
      },
    );
  }

  // refresh status (gọi lại checkStatus)
  Future<void> refreshStatus({required String userId}) async {
    await checkStatus(userId: userId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _isCheckingStatus = false;
    _error = null;
    _isSuccess = false;
    _applicationResult = null;
    _currentApplication = null;
    _legalName = '';
    _licensePlate = '';
    _vehicleType = 'MOTORBIKE';
    _frontVehicleImage = null;
    _backVehicleImage = null;
    _portraitImage = null;
    _agreeToTerms = false;
    notifyListeners();
  }
}
