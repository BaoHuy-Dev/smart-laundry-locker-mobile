import '../config/api_endpoints.dart';
import '../models/api_response.dart';
import '../network/api_client.dart';

class PromotionValidateResponse {
  final int id;
  final String code;
  final String title;
  final String? description;
  final String status;
  final String discountType;
  final double discountValue;
  final double? maxDiscountAmount;
  final double? minOrderAmount;

  PromotionValidateResponse({
    required this.id,
    required this.code,
    required this.title,
    this.description,
    required this.status,
    required this.discountType,
    required this.discountValue,
    this.maxDiscountAmount,
    this.minOrderAmount,
  });

  factory PromotionValidateResponse.fromJson(Map<String, dynamic> json) {
    return PromotionValidateResponse(
      id: json['id'] as int,
      code: json['code'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      discountType: json['discountType'] as String,
      discountValue: (json['discountValue'] as num).toDouble(),
      maxDiscountAmount: (json['maxDiscountAmount'] as num?)?.toDouble(),
      minOrderAmount: (json['minOrderAmount'] as num?)?.toDouble(),
    );
  }
}

/// Promotion Service — replaces promotionService.ts
class PromotionService {
  PromotionService._();

  static final _dio = ApiClient.instance;

  static Future<ApiResponse<PromotionValidateResponse>> validatePromotionCode(
    String code,
  ) async {
    final response = await _dio.get(ApiEndpoints.promotionValidate(code));
    return ApiResponse<PromotionValidateResponse>.fromJson(
      response.data,
      (json) =>
          PromotionValidateResponse.fromJson(json as Map<String, dynamic>),
    );
  }

  static Future<ApiResponse<List<PromotionValidateResponse>>>
  getActivePromotions() async {
    final response = await _dio.get(ApiEndpoints.activePromotions);
    return ApiResponse<List<PromotionValidateResponse>>.fromJson(
      response.data,
      (json) => (json as List<dynamic>)
          .map(
            (item) => PromotionValidateResponse.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  static double calculateDiscount(
    PromotionValidateResponse promotion,
    double orderTotal,
  ) {
    if (orderTotal < (promotion.minOrderAmount ?? 0)) {
      return 0;
    }

    double discount = 0;
    switch (promotion.discountType) {
      case 'PERCENTAGE':
        discount = orderTotal * promotion.discountValue / 100;
        if (promotion.maxDiscountAmount != null) {
          discount = discount > promotion.maxDiscountAmount!
              ? promotion.maxDiscountAmount!
              : discount;
        }
        break;
      case 'FIXED_AMOUNT':
        discount = promotion.discountValue;
        break;
      case 'FREE_SERVICE':
        discount = 0;
        break;
    }

    return discount > orderTotal ? orderTotal : discount;
  }
}
