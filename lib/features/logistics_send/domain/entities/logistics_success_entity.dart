class LogisticsSuccessEntity {
  final String? orderId;
  final String orderCode;
  final int amountVnd;
  final String? otpCode;
  final String? lockerLabel;
  final String? cabinetName;
  final String? cabinetAddress;
  final String receiverName;
  final String receiverPhone;
  final String? note;
  final double? latitude;
  final double? longitude;
  final String? receiverAddress;
  final String? logisticsType;
  final String? locationSendId;
  final String? locationSendName;
  final double? locationSendLatitude;
  final double? locationSendLongitude;
  final String? pickupAddress;

  const LogisticsSuccessEntity({
    this.orderId,
    required this.orderCode,
    required this.amountVnd,
    this.otpCode,
    this.lockerLabel,
    this.cabinetName,
    this.cabinetAddress,
    required this.receiverName,
    required this.receiverPhone,
    this.note,
    this.latitude,
    this.longitude,
    this.receiverAddress,
    this.logisticsType,
    this.locationSendId,
    this.locationSendName,
    this.locationSendLatitude,
    this.locationSendLongitude,
    this.pickupAddress,
  });

  bool get missingOtpOrLockerInfo {
    final noOtp = otpCode == null || otpCode!.trim().isEmpty;
    final noLocker = lockerLabel == null || lockerLabel!.trim().isEmpty;
    final noCabinet =
        (cabinetName == null || cabinetName!.trim().isEmpty) &&
        (cabinetAddress == null || cabinetAddress!.trim().isEmpty);
    return noOtp || noLocker || noCabinet;
  }

  String get directionsQuery {
    final parts = <String>[
      if (cabinetName != null && cabinetName!.trim().isNotEmpty)
        cabinetName!.trim(),
      if (cabinetAddress != null && cabinetAddress!.trim().isNotEmpty)
        cabinetAddress!.trim(),
    ];
    return parts.join(', ');
  }

  static const LogisticsSuccessEntity preview = LogisticsSuccessEntity(
    orderCode: 'ORD-A1B2C3D4',
    amountVnd: 15000,
    otpCode: '482913',
    lockerLabel: 'R3-C2',
    cabinetName: 'AISL Cabinet Lê Văn Việt',
    cabinetAddress: '123 Đường ABC, Quận 9, TP.HCM',
    receiverName: 'Nguyễn Văn A',
    receiverPhone: '0901234567',
    note: 'Hàng dễ vỡ, vui lòng giao trong giờ hành chính.',
    latitude: 10.8412,
    longitude: 106.8099,
  );
}
