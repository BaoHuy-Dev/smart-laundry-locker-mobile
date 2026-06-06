import '../../../../core/enums/app_enums.dart';

class SendPackageDto {
  final String recipientPhone;
  final String recipientName;
  final String itemType;
  final String? lockerId;
  final String? senderAddress;
  final String receiverAddress;
  final String? note;
  final LogisticsType logisticsType;
  final String? pickupAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? receiverLatitude;
  final double? receiverLongitude;
  final String? voucherId;

  const SendPackageDto({
    required this.recipientPhone,
    required this.recipientName,
    required this.itemType,
    this.lockerId,
    this.senderAddress,
    required this.receiverAddress,
    this.note,
    required this.logisticsType,
    this.pickupAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.receiverLatitude,
    this.receiverLongitude,
    this.voucherId,
  });

  Map<String, dynamic> toJson() => {
    'recipientPhone': recipientPhone,
    'recipientName': recipientName,
    'itemType': itemType,
    if (lockerId != null) 'lockerId': lockerId,
    if (senderAddress != null) 'senderAddress': senderAddress,
    'receiverAddress': receiverAddress,
    if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
    'logisticsType': logisticsType.index,
    if (pickupAddress != null) 'pickupAddress': pickupAddress,
    if (pickupLatitude != null) 'pickupLatitude': pickupLatitude,
    if (pickupLongitude != null) 'pickupLongitude': pickupLongitude,
    if (receiverLatitude != null) 'receiverLatitude': receiverLatitude,
    if (receiverLongitude != null) 'receiverLongitude': receiverLongitude,
    if (voucherId != null) 'voucherId': voucherId,
  };
}
