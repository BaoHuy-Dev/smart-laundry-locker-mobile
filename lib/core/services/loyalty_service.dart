import '../config/api_endpoints.dart';
import '../models/api_response.dart';
import '../network/api_client.dart';

class LoyaltyAccount {
  final int id;
  final int userId;
  final String userName;
  final int pointsBalance;
  final int pointsValueVnd;
  final int totalPointsEarned;
  final int totalPointsRedeemed;
  final double totalAmountSpent;
  final String? createdAt;
  final String? updatedAt;

  const LoyaltyAccount({
    required this.id,
    required this.userId,
    required this.userName,
    required this.pointsBalance,
    required this.pointsValueVnd,
    required this.totalPointsEarned,
    required this.totalPointsRedeemed,
    required this.totalAmountSpent,
    this.createdAt,
    this.updatedAt,
  });

  factory LoyaltyAccount.fromJson(Map<String, dynamic> json) {
    return LoyaltyAccount(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      userName: json['userName'] as String? ?? '',
      pointsBalance:
          json['pointsBalance'] as int? ?? json['points'] as int? ?? 0,
      pointsValueVnd: json['pointsValueVnd'] as int? ?? 0,
      totalPointsEarned: json['totalPointsEarned'] as int? ?? 0,
      totalPointsRedeemed: json['totalPointsRedeemed'] as int? ?? 0,
      totalAmountSpent: (json['totalAmountSpent'] as num?)?.toDouble() ?? 0,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

class StampCard {
  final int id;
  final int userId;
  final String stampType;
  final int? serviceId;
  final String serviceName;
  final String? boxSize;
  final int stampsRequired;
  final int currentStamps;
  final int freeRewardsAvailable;
  final int totalStampsEarned;
  final int totalRewardsRedeemed;
  final double progressPercentage;

  const StampCard({
    required this.id,
    required this.userId,
    required this.stampType,
    this.serviceId,
    required this.serviceName,
    this.boxSize,
    required this.stampsRequired,
    required this.currentStamps,
    required this.freeRewardsAvailable,
    required this.totalStampsEarned,
    required this.totalRewardsRedeemed,
    required this.progressPercentage,
  });

  factory StampCard.fromJson(Map<String, dynamic> json) {
    return StampCard(
      id: json['id'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      stampType: json['stampType'] as String? ?? '',
      serviceId: json['serviceId'] as int?,
      serviceName: json['serviceName'] as String? ?? '',
      boxSize: json['boxSize'] as String?,
      stampsRequired: json['stampsRequired'] as int? ?? 0,
      currentStamps: json['currentStamps'] as int? ?? 0,
      freeRewardsAvailable: json['freeRewardsAvailable'] as int? ?? 0,
      totalStampsEarned: json['totalStampsEarned'] as int? ?? 0,
      totalRewardsRedeemed: json['totalRewardsRedeemed'] as int? ?? 0,
      progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0,
    );
  }
}

class LoyaltySummary {
  final LoyaltyAccount pointsAccount;
  final List<StampCard> stampCards;
  final int totalRedeemableValue;
  final int totalFreeRewards;

  const LoyaltySummary({
    required this.pointsAccount,
    required this.stampCards,
    required this.totalRedeemableValue,
    required this.totalFreeRewards,
  });

  factory LoyaltySummary.fromJson(Map<String, dynamic> json) {
    return LoyaltySummary(
      pointsAccount: LoyaltyAccount.fromJson(
        Map<String, dynamic>.from(json['pointsAccount'] as Map? ?? const {}),
      ),
      stampCards: (json['stampCards'] as List<dynamic>? ?? const [])
          .map((item) => StampCard.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalRedeemableValue: json['totalRedeemableValue'] as int? ?? 0,
      totalFreeRewards: json['totalFreeRewards'] as int? ?? 0,
    );
  }
}

class RewardItem {
  final int id;
  final String name;
  final String description;
  final int pointsRequired;
  final String type;
  final String value;
  final String? imageUrl;
  final bool canRedeem;
  final int? remainingQuantity;
  final String? expiresAt;
  final String minimumTier;
  final String category;

  const RewardItem({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsRequired,
    required this.type,
    required this.value,
    this.imageUrl,
    required this.canRedeem,
    this.remainingQuantity,
    this.expiresAt,
    required this.minimumTier,
    required this.category,
  });

  factory RewardItem.fromJson(Map<String, dynamic> json) {
    return RewardItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pointsRequired: json['pointsRequired'] as int? ?? 0,
      type: json['type'] as String? ?? 'DISCOUNT',
      value: json['value']?.toString() ?? '',
      imageUrl: json['imageUrl'] as String?,
      canRedeem: json['canRedeem'] as bool? ?? false,
      remainingQuantity: json['remainingQuantity'] as int?,
      expiresAt: json['expiresAt'] as String?,
      minimumTier: json['minimumTier'] as String? ?? 'BRONZE',
      category: json['category'] as String? ?? '',
    );
  }
}

class RedeemedReward {
  final int id;
  final String rewardName;
  final int pointsSpent;
  final String? redeemedAt;
  final String? code;
  final String status;
  final String? expiresAt;
  final String? usedAt;

  const RedeemedReward({
    required this.id,
    required this.rewardName,
    required this.pointsSpent,
    this.redeemedAt,
    this.code,
    required this.status,
    this.expiresAt,
    this.usedAt,
  });

  factory RedeemedReward.fromJson(Map<String, dynamic> json) {
    return RedeemedReward(
      id: json['id'] as int? ?? 0,
      rewardName:
          json['rewardName'] as String? ?? json['name'] as String? ?? '',
      pointsSpent: json['pointsSpent'] as int? ?? 0,
      redeemedAt: json['redeemedAt'] as String?,
      code: json['code'] as String? ?? json['rewardCode'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      expiresAt: json['expiresAt'] as String?,
      usedAt: json['usedAt'] as String?,
    );
  }
}

class RewardsResponse {
  final int currentPoints;
  final String membershipTier;
  final int pointsToNextTier;
  final List<RewardItem> availableRewards;
  final List<RedeemedReward> redeemedRewards;

  const RewardsResponse({
    required this.currentPoints,
    required this.membershipTier,
    required this.pointsToNextTier,
    required this.availableRewards,
    required this.redeemedRewards,
  });

  factory RewardsResponse.fromJson(Map<String, dynamic> json) {
    return RewardsResponse(
      currentPoints: json['currentPoints'] as int? ?? 0,
      membershipTier: json['membershipTier'] as String? ?? '',
      pointsToNextTier: json['pointsToNextTier'] as int? ?? 0,
      availableRewards: (json['availableRewards'] as List<dynamic>? ?? const [])
          .map((item) => RewardItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      redeemedRewards: (json['redeemedRewards'] as List<dynamic>? ?? const [])
          .map((item) => RedeemedReward.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PointTransaction {
  final int id;
  final String type;
  final int points;
  final String description;
  final int? orderId;
  final String? createdAt;

  const PointTransaction({
    required this.id,
    required this.type,
    required this.points,
    required this.description,
    this.orderId,
    this.createdAt,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'] as int? ?? 0,
      type: json['type'] as String? ?? '',
      points: json['points'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      orderId: json['orderId'] as int?,
      createdAt: json['createdAt'] as String?,
    );
  }
}

class ExpiringPoints {
  final int expiringPoints;
  final String? expiringDate;
  final List<String> recommendations;

  const ExpiringPoints({
    required this.expiringPoints,
    this.expiringDate,
    required this.recommendations,
  });

  factory ExpiringPoints.fromJson(Map<String, dynamic> json) {
    return ExpiringPoints(
      expiringPoints: json['expiringPoints'] as int? ?? 0,
      expiringDate: json['expiringDate'] as String?,
      recommendations: (json['recommendations'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

class LoyaltyService {
  LoyaltyService._();

  static final _dio = ApiClient.instance;

  static Future<ApiResponse<LoyaltySummary>> getLoyaltySummary() async {
    final response = await _dio.get(ApiEndpoints.loyaltySummary);
    return ApiResponse<LoyaltySummary>.fromJson(
      response.data,
      (json) => LoyaltySummary.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<LoyaltyAccount>> getPointsAccount() async {
    final response = await _dio.get(ApiEndpoints.loyaltyPoints);
    return ApiResponse<LoyaltyAccount>.fromJson(
      response.data,
      (json) => LoyaltyAccount.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<PaginatedResponse<PointTransaction>>>
  getPointsHistory({int page = 0, int size = 20}) async {
    final response = await _dio.get(
      ApiEndpoints.loyaltyPointsHistory,
      queryParameters: {'page': page, 'size': size},
    );
    return ApiResponse<PaginatedResponse<PointTransaction>>.fromJson(
      response.data,
      (json) => PaginatedResponse<PointTransaction>.fromJson(
        json as Map<String, dynamic>,
        (item) => PointTransaction.fromJson(item as Map<String, dynamic>),
      ),
    );
  }

  static Future<ApiResponse<List<StampCard>>> getStampCards() async {
    final response = await _dio.get(ApiEndpoints.loyaltyStamps);
    return ApiResponse<List<StampCard>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map((item) => StampCard.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static Future<ApiResponse<RewardsResponse>> getAvailableRewards() async {
    final response = await _dio.get(ApiEndpoints.loyaltyRewards);
    return ApiResponse<RewardsResponse>.fromJson(
      response.data,
      (json) => RewardsResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<RedeemedReward>> redeemReward(int rewardId) async {
    final response = await _dio.post(ApiEndpoints.redeemReward(rewardId));
    return ApiResponse<RedeemedReward>.fromJson(
      response.data,
      (json) => RedeemedReward.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<ExpiringPoints>> getExpiringPoints() async {
    final response = await _dio.get(ApiEndpoints.loyaltyExpiringPoints);
    return ApiResponse<ExpiringPoints>.fromJson(
      response.data,
      (json) => ExpiringPoints.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<PointTransaction>> redeemPoints(
    int orderId,
    int points,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.redeemPoints,
      data: {'orderId': orderId, 'points': points},
    );
    return ApiResponse<PointTransaction>.fromJson(
      response.data,
      (json) => PointTransaction.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<Map<String, dynamic>>> redeemStampReward(
    int stampCardId,
    int orderId,
  ) async {
    final response = await _dio.post(
      ApiEndpoints.redeemStamp,
      data: {'stampCardId': stampCardId, 'orderId': orderId},
    );
    return ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );
  }
}
