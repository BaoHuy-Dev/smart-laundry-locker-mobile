import 'dart:io';
import 'package:smart_laundry_locker/features/orders/infrastructure/models/order_detail_model.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/verify_courier_code_use_case.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/accept_order_use_case.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/cancel_dispatch_use_case.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/reject_order_use_case.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/confirm_pickup_use_case.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/deposit_confirm_locker_use_case.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/deposit_open_locker_use_case.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/pickup_package_use_case.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/get_active_delivery_use_case.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/courier_cancel_order_use_case.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/order.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/responses.dart';
import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter/foundation.dart';

enum DeliveryPhase { none, pickingUp, headingToLocker, depositing }

class CourierDeliveryProvider extends ChangeNotifier {
  final AcceptOrderUseCase _acceptOrderUseCase;
  final VerifyCourierCodeUseCase _verifyCourierCodeUseCase;
  final CancelDispatchUseCase _cancelDispatchUseCase;
  final RejectOrderUseCase _rejectOrderUseCase;
  final DepositOpenLockerUseCase _depositOpenLockerUseCase;
  final DepositConfirmLockerUseCase _depositConfirmLockerUseCase;
  final ConfirmPickupUseCase _confirmPickupUseCase;
  final PickupPackageUseCase _pickupPackageUseCase;
  final GetActiveDeliveryUseCase _getActiveDeliveryUseCase;
  final CourierCancelOrderUseCase _courierCancelOrderUseCase;

  CourierDeliveryProvider({
    required AcceptOrderUseCase acceptOrderUseCase,
    required VerifyCourierCodeUseCase verifyCourierCodeUseCase,
    required CancelDispatchUseCase cancelDispatchUseCase,
    required RejectOrderUseCase rejectOrderUseCase,
    required DepositOpenLockerUseCase depositOpenLockerUseCase,
    required DepositConfirmLockerUseCase depositConfirmLockerUseCase,
    required ConfirmPickupUseCase confirmPickupUseCase,
    required PickupPackageUseCase pickupPackageUseCase,
    required GetActiveDeliveryUseCase getActiveDeliveryUseCase,
    required CourierCancelOrderUseCase courierCancelOrderUseCase,
  }) : _acceptOrderUseCase = acceptOrderUseCase,
       _verifyCourierCodeUseCase = verifyCourierCodeUseCase,
       _cancelDispatchUseCase = cancelDispatchUseCase,
       _rejectOrderUseCase = rejectOrderUseCase,
       _depositOpenLockerUseCase = depositOpenLockerUseCase,
       _depositConfirmLockerUseCase = depositConfirmLockerUseCase,
       _confirmPickupUseCase = confirmPickupUseCase,
       _pickupPackageUseCase = pickupPackageUseCase,
       _getActiveDeliveryUseCase = getActiveDeliveryUseCase,
       _courierCancelOrderUseCase = courierCancelOrderUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  CourierAcceptResponse? _activeOrder;
  CourierAcceptResponse? get activeOrder => _activeOrder;

  String? _activeDispatchId;
  String? get activeDispatchId => _activeDispatchId;

  DeliveryPhase _phase = DeliveryPhase.none;
  DeliveryPhase get phase => _phase;

  File? _evidenceImage;
  File? get evidenceImage => _evidenceImage;

  String? _destinationLockerLabel;
  String? get destinationLockerLabel => _destinationLockerLabel;

  String? get destinationLockerIdForDeposit {
    final v = _destinationLockerLabel?.trim();
    return v != null && v.isNotEmpty ? v : null;
  }

  OrderDetailModel? get latestDetail {
    if (_activeOrder == null ||
        _activeOrder!.orderDetails == null ||
        _activeOrder!.orderDetails!.isEmpty) {
      return null;
    }
    final details = List<OrderDetailModel>.from(_activeOrder!.orderDetails!);
    // Sort descending by createdAt to get newest first
    details.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return details.first;
  }

  String? get lockerIdForDeposit {
    final detail = latestDetail;
    final lockerId = detail?.lockerId?.trim() ?? _activeOrder?.lockerId?.trim();
    if (lockerId != null && lockerId.isNotEmpty) return lockerId;

    final label =
        detail?.lockerLabel?.trim() ?? _activeOrder?.lockerLabel?.trim();
    if (label != null && label.isNotEmpty) return label;

    return null;
  }

  String? get recipientNameForDeposit {
    final detail = latestDetail;
    final value =
        detail?.receiverName?.trim() ?? _activeOrder?.recipientName?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  String? get recipientPhoneForDeposit {
    final detail = latestDetail;
    final value =
        detail?.receiverPhone?.trim() ?? _activeOrder?.recipientPhone?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<bool> acceptOrder(String dispatchId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _acceptOrderUseCase(dispatchId);

    return result.fold(
      (failure) {
        _isLoading = false;
        _error = failure.message;
        notifyListeners();
        return false;
      },
      (orderData) {
        _isLoading = false;
        _activeOrder = orderData;
        _activeDispatchId = dispatchId;
        _phase = DeliveryPhase.pickingUp;
        _destinationLockerLabel = null;
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> verifyCourierCode(String code) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _verifyCourierCodeUseCase(code);

    return result.fold(
      (failure) {
        _isLoading = false;
        _error = failure.message;
        notifyListeners();
        return false;
      },
      (resp) {
        _isLoading = false;
        // In the split flow, verification returns the order details
        if (resp.order != null) {
          _activeOrder = CourierAcceptResponse.fromJson(resp.order!);
          _phase = DeliveryPhase.pickingUp;
        }
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> pickupPackage(String accessCode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _pickupPackageUseCase(accessCode);

    return result.fold(
      (failure) {
        _isLoading = false;
        _error = failure.message;
        notifyListeners();
        return false;
      },
      (resp) {
        _isLoading = false;
        _destinationLockerLabel = resp.lockerLabel.trim();
        notifyListeners();
        return true;
      },
    );
  }

  Future<void> refreshActiveDelivery() async {
    try {
      final json = await _getActiveDeliveryUseCase();
      json.fold((failure) {}, (data) {
        _activeOrder = data;
        _inferPhase();
        notifyListeners();
      });
    } catch (_) {}
  }

  Future<bool> confirmPickup({bool isHomePickup = false}) async {
    if (_activeOrder == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    List<String> imageUrls = const [];
    if (isHomePickup) {
      if (_evidenceImage == null) {
        _isLoading = false;
        _error = 'Vui lòng chụp ảnh xác nhận lấy hàng tại nhà.';
        notifyListeners();
        return false;
      }
      final uploadResult = await _depositConfirmLockerUseCase.uploadEvidence(
        _evidenceImage!,
      );
      final uploadedUrl = uploadResult.fold<String?>((_) => null, (url) => url);
      if (uploadedUrl == null || uploadedUrl.isEmpty) {
        _isLoading = false;
        _error = 'Không thể upload ảnh bằng chứng. Vui lòng thử lại.';
        notifyListeners();
        return false;
      }
      imageUrls = [uploadedUrl];
    }

    final result = await _confirmPickupUseCase(
      _activeOrder!.orderCode,
      imageUrls: imageUrls.isNotEmpty ? imageUrls : null,
    );

    return result.fold(
      (failure) {
        _isLoading = false;
        _error = failure.message;
        notifyListeners();
        return false;
      },
      (success) async {
        if (success) {
          // Clear image after successful upload
          _evidenceImage = null;
          await refreshActiveDelivery();
        }
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  void markArrivedAtLocker() {
    if (_phase == DeliveryPhase.headingToLocker) {
      _phase = DeliveryPhase.depositing;
      notifyListeners();
    }
  }

  Future<bool> openLocker(String lockerId, {String? orderCode}) async {
    final effectiveOrderCode = orderCode ?? _activeOrder?.orderCode;
    if (effectiveOrderCode == null || effectiveOrderCode.trim().isEmpty) {
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _depositOpenLockerUseCase(
      effectiveOrderCode,
      lockerId,
    );

    return result.fold(
      (failure) {
        _isLoading = false;
        _error = failure.message;
        notifyListeners();
        return false;
      },
      (success) {
        _isLoading = false;
        notifyListeners();
        return success;
      },
    );
  }

  void setEvidenceImage(File image) {
    _evidenceImage = image;
    notifyListeners();
  }

  Future<bool> confirmDeposit({
    required String recipientPhone,
    required String recipientName,
    required String lockerId,
  }) async {
    if (_activeOrder == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    List<String> imageUrls = const [];
    if (_evidenceImage == null) {
      _isLoading = false;
      _error = 'Vui lòng chụp ít nhất 1 ảnh bằng chứng trước khi xác nhận.';
      notifyListeners();
      return false;
    }

    final uploadResult = await _depositConfirmLockerUseCase.uploadEvidence(
      _evidenceImage!,
    );
    final uploadedUrl = uploadResult.fold<String?>((_) => null, (url) => url);
    if (uploadedUrl == null || uploadedUrl.isEmpty) {
      _isLoading = false;
      _error = 'Không thể upload ảnh bằng chứng. Vui lòng thử lại.';
      notifyListeners();
      return false;
    }
    imageUrls = [uploadedUrl];

    final result = await _depositConfirmLockerUseCase(
      orderCode: _activeOrder!.orderCode,
      recipientPhone: recipientPhone,
      recipientName: recipientName,
      lockerId: lockerId,
      imageUrls: imageUrls,
    );

    return result.fold(
      (failure) {
        _isLoading = false;
        _error = failure.message;
        notifyListeners();
        return false;
      },
      (success) {
        _isLoading = false;
        if (success) {
          // Delivery complete, reset state
          reset();
        }
        notifyListeners();
        return success;
      },
    );
  }

  Future<bool> cancelDispatchForIssue() async {
    final dispatchId = _activeDispatchId;
    if (dispatchId == null || dispatchId.isEmpty) {
      _error = 'Không tìm thấy dispatchId để hủy điều phối.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _cancelDispatchUseCase(dispatchId);
      _isLoading = false;
      final success = result.fold((_) => false, (value) => value);
      if (success) {
        reset();
      } else {
        _error = result.fold(
          (f) => f.message,
          (_) => 'Không thể hủy điều phối lúc này.',
        );
      }
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<Either<Failure, bool>> cancelDispatch(String dispatchId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _cancelDispatchUseCase(dispatchId);
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<bool> rejectOrder(String dispatchId, {String? reason}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _rejectOrderUseCase(dispatchId, reason: reason);
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchActiveDeliveryDetail() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _getActiveDeliveryUseCase();
    result.fold(
      (failure) {
        _error = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (orderData) {
        _activeOrder = orderData;
        _isLoading = false;
        _inferPhase();
        notifyListeners();
      },
    );
  }

  void _inferPhase() {
    if (_activeOrder == null) {
      _phase = DeliveryPhase.none;
      return;
    }

    final detail = latestDetail;
    if (detail == null) {
      _phase = DeliveryPhase.pickingUp;
      return;
    }

    final status = detail.status.toUpperCase();
    final hasBeenPickedUp =
        _activeOrder!.orderDetails?.any(
          (d) => d.pickedUpAt != null || d.status.toUpperCase() == 'PICKED_UP',
        ) ??
        false;

    // Use hasBeenPickedUp as the mandatory check for moving past pickup phase
    if (hasBeenPickedUp) {
      if (status == 'OCCUPIED') {
        _phase = DeliveryPhase.depositing;
      } else if (_phase == DeliveryPhase.depositing) {
        _phase = DeliveryPhase.depositing;
      } else {
        _phase = DeliveryPhase.headingToLocker;
      }
    } else {
      // Not picked up yet
      _phase = DeliveryPhase.pickingUp;
    }
  }

  void updateActiveOrder(CourierAcceptResponse order) {
    _activeOrder = order;
    _phase = DeliveryPhase.pickingUp;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _error = null;
    _activeOrder = null;
    _activeDispatchId = null;
    _phase = DeliveryPhase.none;
    _evidenceImage = null;
    _destinationLockerLabel = null;
    notifyListeners();
  }

  Future<bool> cancelOrder(String orderId, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _courierCancelOrderUseCase(orderId, reason);

    return result.fold(
      (Failure failure) {
        _isLoading = false;
        _error = failure.message;
        notifyListeners();
        return false;
      },
      (Order order) {
        _isLoading = false;
        // If the cancelled order is the active one, reset state
        if (_activeOrder?.orderId == order.id) {
          reset();
        }
        notifyListeners();
        return true;
      },
    );
  }
}
