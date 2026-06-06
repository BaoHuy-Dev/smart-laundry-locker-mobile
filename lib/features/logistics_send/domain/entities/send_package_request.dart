import '../../../../core/enums/app_enums.dart';

class SendPackageRequest {
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

  const SendPackageRequest({
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

  SendPackageRequest copyWith({String? voucherId}) {
    return SendPackageRequest(
      recipientPhone: recipientPhone,
      recipientName: recipientName,
      itemType: itemType,
      lockerId: lockerId,
      senderAddress: senderAddress,
      receiverAddress: receiverAddress,
      note: note,
      logisticsType: logisticsType,
      pickupAddress: pickupAddress,
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      receiverLatitude: receiverLatitude,
      receiverLongitude: receiverLongitude,
      voucherId: voucherId ?? this.voucherId,
    );
  }
}
