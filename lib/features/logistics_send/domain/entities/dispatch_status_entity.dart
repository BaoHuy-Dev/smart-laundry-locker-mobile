class DispatchStatusEntity {
  final String status;
  final String? courierId;
  final String? courierName;
  final String? courierPhone;
  final String? orderCode;
  final String? orderId;

  const DispatchStatusEntity({
    required this.status,
    this.courierId,
    this.courierName,
    this.courierPhone,
    this.orderCode,
    this.orderId,
  });
}
