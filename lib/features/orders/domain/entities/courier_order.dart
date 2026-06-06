import 'package:equatable/equatable.dart';

class CourierOrder extends Equatable {
  final String orderId;

  final String? dispatchId;

  final String orderCode;
  final String status;
  final String? originCabinetId;
  final String? destinationCabinetId;
  final String originName;
  final String destinationName;
  final DateTime? time;
  final double income;

  const CourierOrder({
    required this.orderId,
    required this.dispatchId,
    required this.orderCode,
    required this.status,
    this.originCabinetId,
    this.destinationCabinetId,
    required this.originName,
    required this.destinationName,
    required this.time,
    required this.income,
  });

  bool get isCompleted => status.toUpperCase() == 'COMPLETED';

  bool get isProcessing {
    final s = status.toUpperCase();
    return s == 'ACTIVE' || s == 'IN_TRANSIT' || s == 'AWAITING_COURIER';
  }

  @override
  List<Object?> get props => [
    orderId,
    dispatchId,
    orderCode,
    status,
    originCabinetId,
    destinationCabinetId,
    originName,
    destinationName,
    time,
    income,
  ];
}
