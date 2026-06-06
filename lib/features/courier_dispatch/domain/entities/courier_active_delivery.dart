class CourierActiveDelivery {
  final String orderId;
  final String orderCode;
  final String accessCode;
  final String lockerLabel;
  final String cabinetName;
  final String address;
  final String message;
  final double latitude;
  final double longitude;
  final String status;
  final String recipientName;
  final String recipientPhone;

  CourierActiveDelivery({
    required this.orderId,
    required this.orderCode,
    required this.accessCode,
    required this.lockerLabel,
    required this.cabinetName,
    required this.address,
    required this.message,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.recipientName,
    required this.recipientPhone,
  });

  factory CourierActiveDelivery.fromJson(Map<String, dynamic> json) {
    return CourierActiveDelivery(
      orderId: (json['order_id'] as String?) ?? '',
      orderCode: (json['order_code'] as String?) ?? '',
      accessCode: (json['access_code'] as String?) ?? '',
      lockerLabel: (json['locker_label'] as String?) ?? '',
      cabinetName: (json['cabinet_name'] as String?) ?? '',
      address: (json['address'] as String?) ?? '',
      message: (json['message'] as String?) ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      status: (json['status'] as String?) ?? '',
      recipientName: (json['recipient_name'] as String?) ?? '',
      recipientPhone: (json['recipient_phone'] as String?) ?? '',
    );
  }
}
