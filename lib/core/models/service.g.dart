// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LaundryService _$LaundryServiceFromJson(Map<String, dynamic> json) =>
    _LaundryService(
      id: (json['id'] as num).toInt(),
      storeId: (json['storeId'] as num?)?.toInt(),
      name: json['name'] as String,
      description: json['description'] as String?,
      category: $enumDecodeNullable(_$ServiceCategoryEnumMap, json['category']),
      serviceType: $enumDecodeNullable(
        _$ServiceTypeEnumMap,
        json['serviceType'],
      ),
      price: (json['price'] as num).toDouble(),
      pricePerUnit: (json['pricePerUnit'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      unit: json['unit'] as String,
      estimatedTime: (json['estimatedTime'] as num?)?.toInt(),
      estimatedHours: (json['estimatedHours'] as num?)?.toInt(),
      isAddon: json['isAddon'] as bool? ?? false,
      isMonthlyPackage: json['isMonthlyPackage'] as bool? ?? false,
      image: json['image'] as String?,
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$LaundryServiceToJson(_LaundryService instance) =>
    <String, dynamic>{
      'id': instance.id,
      'storeId': instance.storeId,
      'name': instance.name,
      'description': instance.description,
      'category': _$ServiceCategoryEnumMap[instance.category],
      'serviceType': _$ServiceTypeEnumMap[instance.serviceType],
      'price': instance.price,
      'pricePerUnit': instance.pricePerUnit,
      'maxPrice': instance.maxPrice,
      'unit': instance.unit,
      'estimatedTime': instance.estimatedTime,
      'estimatedHours': instance.estimatedHours,
      'isAddon': instance.isAddon,
      'isMonthlyPackage': instance.isMonthlyPackage,
      'image': instance.image,
      'imageUrl': instance.imageUrl,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

const _$ServiceCategoryEnumMap = {
  ServiceCategory.storage: 'STORAGE',
  ServiceCategory.laundry: 'LAUNDRY',
};

const _$ServiceTypeEnumMap = {
  ServiceType.standardDropoff: 'STANDARD_DROPOFF',
  ServiceType.overnight: 'OVERNIGHT',
  ServiceType.express2h: 'EXPRESS_2H',
  ServiceType.monthlyStudent: 'MONTHLY_STUDENT',
  ServiceType.monthlyShipper: 'MONTHLY_SHIPPER',
  ServiceType.laundry: 'LAUNDRY',
  ServiceType.additionalFee: 'ADDITIONAL_FEE',
};

_PromotionInfo _$PromotionInfoFromJson(Map<String, dynamic> json) =>
    _PromotionInfo(
      code: json['code'] as String,
      title: json['title'] as String,
      discountType: json['discountType'] as String,
      discountValue: (json['discountValue'] as num).toDouble(),
      maxDiscountAmount: (json['maxDiscountAmount'] as num?)?.toDouble(),
      calculatedDiscount: (json['calculatedDiscount'] as num).toDouble(),
      applied: json['applied'] as bool,
      message: json['message'] as String?,
    );

Map<String, dynamic> _$PromotionInfoToJson(_PromotionInfo instance) =>
    <String, dynamic>{
      'code': instance.code,
      'title': instance.title,
      'discountType': instance.discountType,
      'discountValue': instance.discountValue,
      'maxDiscountAmount': instance.maxDiscountAmount,
      'calculatedDiscount': instance.calculatedDiscount,
      'applied': instance.applied,
      'message': instance.message,
    };

_PriceBreakdown _$PriceBreakdownFromJson(Map<String, dynamic> json) =>
    _PriceBreakdown(
      basePrice: (json['basePrice'] as num).toDouble(),
      storageFee: (json['storageFee'] as num?)?.toDouble(),
      overtimeFee: (json['overtimeFee'] as num?)?.toDouble(),
      shippingFee: (json['shippingFee'] as num?)?.toDouble(),
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      promotionCode: json['promotionCode'] as String?,
      promotionDiscount: (json['promotionDiscount'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      finalPrice: (json['finalPrice'] as num?)?.toDouble(),
      appliedPromotions: (json['appliedPromotions'] as List<dynamic>?)
          ?.map((e) => PromotionInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$PriceBreakdownToJson(_PriceBreakdown instance) =>
    <String, dynamic>{
      'basePrice': instance.basePrice,
      'storageFee': instance.storageFee,
      'overtimeFee': instance.overtimeFee,
      'shippingFee': instance.shippingFee,
      'originalPrice': instance.originalPrice,
      'promotionCode': instance.promotionCode,
      'promotionDiscount': instance.promotionDiscount,
      'discount': instance.discount,
      'finalPrice': instance.finalPrice,
      'appliedPromotions': instance.appliedPromotions
          ?.map((e) => e.toJson())
          .toList(),
      'note': instance.note,
    };

_EstimatedPrice _$EstimatedPriceFromJson(Map<String, dynamic> json) =>
    _EstimatedPrice(
      minPrice: (json['minPrice'] as num).toDouble(),
      maxPrice: (json['maxPrice'] as num).toDouble(),
      estimatedWeight: (json['estimatedWeight'] as num?)?.toDouble(),
      note: json['note'] as String?,
    );

Map<String, dynamic> _$EstimatedPriceToJson(_EstimatedPrice instance) =>
    <String, dynamic>{
      'minPrice': instance.minPrice,
      'maxPrice': instance.maxPrice,
      'estimatedWeight': instance.estimatedWeight,
      'note': instance.note,
    };
