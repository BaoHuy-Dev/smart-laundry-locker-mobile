class VoucherModel {
  final String id;
  final String code;
  final String status; // UNUSED, USED, EXPIRED
  final DateTime? expiresAt;
  final double rewardValue;
  final String campaignId;
  final String campaignTitle;
  final String rewardType;
  final String giftDescription;

  VoucherModel({
    required this.id,
    required this.code,
    required this.status,
    this.expiresAt,
    required this.rewardValue,
    required this.campaignId,
    required this.campaignTitle,
    required this.rewardType,
    required this.giftDescription,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      id: json['id'] ?? '',
      code: json['code'] ?? '',
      status: json['status'] ?? 'UNUSED',
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())
          : null,
      rewardValue:
          double.tryParse((json['rewardValue'] ?? 0).toString()) ?? 0.0,
      campaignId: json['campaignId'] ?? '',
      campaignTitle: json['campaignTitle'] ?? '',
      rewardType: json['rewardType'] ?? '',
      giftDescription: json['giftDescription'] ?? '',
    );
  }
}
