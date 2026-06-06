import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/entities/courier_accept_hints.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/entities/logistics_success_entity.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/params/logistics_success_load_params.dart';
import 'package:smart_laundry_locker/features/orders/application/use_cases/get_order_detail_use_case.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/order_detail.dart';
import 'package:dartz/dartz.dart' hide Order;

class GetLogisticsSuccessUseCase {
  GetLogisticsSuccessUseCase(this._getOrderDetail);

  final GetOrderDetailUseCase _getOrderDetail;

  Future<Either<Failure, LogisticsSuccessEntity>> call(
    LogisticsSuccessLoadParams input,
  ) async {
    final hints = input.courierHints;
    final orderId = input.orderId?.trim();

    if (orderId == null || orderId.isEmpty) {
      return Right(_fromPaymentOnly(input, hints));
    }

    final result = await _getOrderDetail(orderId);
    return result.fold(Left.new, (data) {
      final detail = _pickDetail(data.orderDetails);
      return Right(
        _mergeOrder(
          input: input,
          orderCode: data.order.orderCode,
          totalCollected: data.order.totalCollected,
          detail: detail,
          hints: hints,
        ),
      );
    });
  }

  OrderDetail? _pickDetail(List<OrderDetail> details) {
    if (details.isEmpty) return null;
    return details.first;
  }

  LogisticsSuccessEntity _mergeOrder({
    required LogisticsSuccessLoadParams input,
    required String orderCode,
    required double totalCollected,
    required OrderDetail? detail,
    required CourierAcceptHints? hints,
  }) {
    final amount = input.totalCollectedVnd > 0
        ? input.totalCollectedVnd
        : totalCollected.round();

    final otp = _firstNonEmpty([hints?.accessCode, detail?.accessCode]);
    final locker = _firstNonEmpty([
      hints?.lockerLabel,
      detail?.formattedLockerLabel,
    ]);
    final cabName = _firstNonEmpty([
      hints?.cabinetName,
      detail?.locationSendName,
      detail?.cabinetName,
    ]);
    final cabAddr = _firstNonEmpty([
      hints?.address,
      detail?.cabinetAddress,
      detail?.pickupAddress,
    ]);

    final recvName =
        _firstNonEmpty([
          detail?.receiverName,
          hints?.recipientName,
          input.recipientName,
        ]) ??
        input.recipientName;

    final recvPhone =
        _firstNonEmpty([
          detail?.receiverEmail,
          hints?.recipientPhone,
          input.recipientPhone,
        ]) ??
        input.recipientPhone;

    final note = _firstNonEmpty([detail?.note, input.note]);

    final lat = hints?.latitude ?? detail?.locationSendLatitude;
    final lng = hints?.longitude ?? detail?.locationSendLongitude;

    return LogisticsSuccessEntity(
      orderId: detail?.orderId,
      orderCode: orderCode.trim().isNotEmpty
          ? orderCode.trim()
          : _orderCodeFromDispatch(input.dispatchId),
      amountVnd: amount,
      otpCode: otp,
      lockerLabel: locker,
      cabinetName: cabName,
      cabinetAddress: cabAddr,
      receiverName: recvName,
      receiverPhone: recvPhone,
      note: note,
      latitude: lat,
      longitude: lng,
      locationSendId: detail?.locationSendId,
      locationSendName: detail?.locationSendName,
      locationSendLatitude: detail?.locationSendLatitude,
      locationSendLongitude: detail?.locationSendLongitude,
      pickupAddress: detail?.pickupAddress,
    );
  }

  LogisticsSuccessEntity _fromPaymentOnly(
    LogisticsSuccessLoadParams input,
    CourierAcceptHints? hints,
  ) {
    final otp = _firstNonEmpty([hints?.accessCode]);
    final locker = _firstNonEmpty([hints?.lockerLabel]);
    final cabName = _firstNonEmpty([hints?.cabinetName]);
    final cabAddr = _firstNonEmpty([hints?.address]);

    final recvName =
        _firstNonEmpty([hints?.recipientName, input.recipientName]) ??
        input.recipientName;

    final recvPhone =
        _firstNonEmpty([hints?.recipientPhone, input.recipientPhone]) ??
        input.recipientPhone;

    return LogisticsSuccessEntity(
      orderId: input.orderId,
      orderCode: _orderCodeFromDispatch(input.dispatchId),
      amountVnd: input.totalCollectedVnd,
      otpCode: otp,
      lockerLabel: locker,
      cabinetName: cabName,
      cabinetAddress: cabAddr,
      receiverName: recvName,
      receiverPhone: recvPhone,
      note: input.note,
      latitude: hints?.latitude,
      longitude: hints?.longitude,
    );
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }

  String _orderCodeFromDispatch(String dispatchId) {
    final idUpper = dispatchId.toUpperCase().trim();
    if (idUpper.isEmpty) return 'ORD';
    if (idUpper.length > 8) return 'ORD-${idUpper.substring(0, 8)}';
    return 'ORD-$idUpper';
  }
}
