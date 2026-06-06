class PendingDispatch {
  final String id;
  final String senderId;
  final String recipientPhone;
  final String recipientName;
  final String? note;
  final String itemType;
  final String logisticsType;
  final String lockerId;
  final String lockerLabel;
  final String cabinetId;
  final String cabinetName;
  final String senderAddress;
  final String receiverAddress;
  final DateTime createdAt;

  PendingDispatch({
    required this.id,
    required this.senderId,
    required this.recipientPhone,
    required this.recipientName,
    this.note,
    required this.itemType,
    required this.logisticsType,
    required this.lockerId,
    required this.lockerLabel,
    required this.cabinetId,
    required this.cabinetName,
    required this.senderAddress,
    required this.receiverAddress,
    required this.createdAt,
  });

  factory PendingDispatch.fromJson(Map<String, dynamic> json) {
    return PendingDispatch(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      recipientPhone: json['recipientPhone'] as String,
      recipientName: json['recipientName'] as String,
      note: json['note'] as String?,
      itemType: json['itemType'] as String,
      logisticsType:
          json['logisticsType'] == 1 ||
              json['logisticsType'] == 'HOME_TO_LOCKER'
          ? 'HOME_TO_LOCKER'
          : 'LOCKER_TO_LOCKER',
      lockerId: json['lockerId'] as String,
      lockerLabel: json['lockerLabel'] as String,
      cabinetId: json['cabinetId'] as String,
      cabinetName: json['cabinetName'] as String,
      senderAddress: json['senderAddress'] as String,
      receiverAddress: json['receiverAddress'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'recipientPhone': recipientPhone,
      'recipientName': recipientName,
      'note': note,
      'itemType': itemType,
      'logisticsType': logisticsType,
      'lockerId': lockerId,
      'lockerLabel': lockerLabel,
      'cabinetId': cabinetId,
      'cabinetName': cabinetName,
      'senderAddress': senderAddress,
      'receiverAddress': receiverAddress,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
