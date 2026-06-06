import 'package:smart_laundry_locker/features/logistics_send/domain/entities/courier_accept_hints.dart';
import 'package:equatable/equatable.dart';

class LogisticsSuccessLoadParams extends Equatable {
  const LogisticsSuccessLoadParams({
    this.orderId,
    required this.dispatchId,
    required this.totalCollectedVnd,
    required this.recipientName,
    required this.recipientPhone,
    this.note,
    this.courierHints,
  });

  final String? orderId;
  final String dispatchId;
  final int totalCollectedVnd;
  final String recipientName;
  final String recipientPhone;
  final String? note;
  final CourierAcceptHints? courierHints;

  @override
  List<Object?> get props => [
    orderId,
    dispatchId,
    totalCollectedVnd,
    recipientName,
    recipientPhone,
    note,
    courierHints,
  ];
}
