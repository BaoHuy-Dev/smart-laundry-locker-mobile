import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/staff_application/application/use_cases/get_staff_application_status_use_case.dart';
import 'package:smart_laundry_locker/features/staff_application/application/use_cases/submit_staff_application_use_case.dart';
import 'package:smart_laundry_locker/features/staff_application/domain/entities/staff_application.dart';
import 'package:smart_laundry_locker/features/staff_application/domain/entities/vehicle_type.dart';
import 'package:smart_laundry_locker/features/staff_application/domain/repositories/staff_application_repository.dart';
import 'package:flutter/foundation.dart';

class StaffApplicationProvider extends ChangeNotifier {
  final SubmitStaffApplicationUseCase _submitUseCase;
  final GetStaffApplicationStatusUseCase _getStatusUseCase;
  final StaffApplicationRepository _repository;

  StaffApplicationProvider({
    required SubmitStaffApplicationUseCase submitUseCase,
    required GetStaffApplicationStatusUseCase getStatusUseCase,
    required StaffApplicationRepository repository,
  }) : _submitUseCase = submitUseCase,
       _getStatusUseCase = getStatusUseCase,
       _repository = repository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Failure? _failure;
  Failure? get failure => _failure;

  StaffApplication? _application;
  StaffApplication? get application => _application;

  List<VehicleType> _vehicleTypes = [];
  List<VehicleType> get vehicleTypes => _vehicleTypes;

  bool _isLoadingVehicles = false;
  bool get isLoadingVehicles => _isLoadingVehicles;

  Future<StaffApplication?> loadStatus(String userId) async {
    _failure = null;
    notifyListeners();

    final result = await _getStatusUseCase(userId);
    return result.fold(
      (f) {
        _failure = f;
        _application = null;
        notifyListeners();
        return null;
      },
      (app) {
        _failure = null;
        _application = app;
        notifyListeners();
        return app;
      },
    );
  }

  Future<StaffApplication?> submit(SubmitStaffApplicationParams params) async {
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final result = await _submitUseCase(params);
    return result.fold(
      (f) {
        _isLoading = false;
        _failure = f;
        notifyListeners();
        return null;
      },
      (app) {
        _isLoading = false;
        _failure = null;
        _application = app;
        notifyListeners();
        return app;
      },
    );
  }

  void clearError() {
    _failure = null;
    notifyListeners();
  }

  Future<void> fetchVehicleTypes() async {
    _isLoadingVehicles = true;
    notifyListeners();

    final result = await _repository.getVehicleTypes();
    result.fold(
      (f) {
        _isLoadingVehicles = false;
        _failure = f;
        notifyListeners();
      },
      (list) {
        _isLoadingVehicles = false;
        _failure = null;
        _vehicleTypes = list;
        notifyListeners();
      },
    );
  }
}
