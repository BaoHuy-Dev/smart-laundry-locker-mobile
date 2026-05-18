import 'package:freezed_annotation/freezed_annotation.dart';

part 'service.freezed.dart';
part 'service.g.dart';

enum ServiceCategory {
  @JsonValue('STORAGE')
  storage,
  @JsonValue('LAUNDRY')
  laundry,
}

enum ServiceType {
  @JsonValue('STANDARD_DROPOFF')
  standardDropoff,
  @JsonValue('OVERNIGHT')
  overnight,
  @JsonValue('EXPRESS_2H')
  express2h,
  @JsonValue('MONTHLY_STUDENT')
  monthlyStudent,
  @JsonValue('MONTHLY_SHIPPER')
  monthlyShipper,
  @JsonValue('LAUNDRY')
  laundry,
  @JsonValue('ADDITIONAL_FEE')
  additionalFee,
}

enum PricingType {
  @JsonValue('FIXED')
  fixed,
  @JsonValue('PER_WEIGHT')
  perWeight,
  @JsonValue('PER_PIECE')
  perPiece,
}

@freezed
abstract class LaundryService with _$LaundryService {
  const factory LaundryService({
    required int id,
    int? storeId,
    required String name,
    String? description,
    ServiceCategory? category,
    ServiceType? serviceType,
    required double price,
    double? pricePerUnit,
    double? maxPrice,
    required String unit,
    int? estimatedTime,
    int? estimatedHours,
    @Default(false) bool isAddon,
    @Default(false) bool isMonthlyPackage,
    String? image,
    String? imageUrl,
    @Default(true) bool isActive,
    String? createdAt,
    String? updatedAt,
  }) = _LaundryService;

  factory LaundryService.fromJson(Map<String, dynamic> json) =>
      _$LaundryServiceFromJson(json);
}

@freezed
abstract class PromotionInfo with _$PromotionInfo {
  const factory PromotionInfo({
    required String code,
    required String title,
    required String
    discountType, // 'PERCENTAGE', 'FIXED_AMOUNT', 'FREE_SERVICE'
    required double discountValue,
    double? maxDiscountAmount,
    required double calculatedDiscount,
    required bool applied,
    String? message,
  }) = _PromotionInfo;

  factory PromotionInfo.fromJson(Map<String, dynamic> json) =>
      _$PromotionInfoFromJson(json);
}

@freezed
abstract class PriceBreakdown with _$PriceBreakdown {
  const factory PriceBreakdown({
    required double basePrice,
    double? storageFee,
    double? overtimeFee,
    double? shippingFee,
    double? originalPrice,
    String? promotionCode,
    double? promotionDiscount,
    double? discount,
    double? finalPrice,
    List<PromotionInfo>? appliedPromotions,
    String? note,
  }) = _PriceBreakdown;

  factory PriceBreakdown.fromJson(Map<String, dynamic> json) =>
      _$PriceBreakdownFromJson(json);
}

@freezed
abstract class EstimatedPrice with _$EstimatedPrice {
  const factory EstimatedPrice({
    required double minPrice,
    required double maxPrice,
    double? estimatedWeight,
    String? note,
  }) = _EstimatedPrice;

  factory EstimatedPrice.fromJson(Map<String, dynamic> json) =>
      _$EstimatedPriceFromJson(json);
}
