// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCourierLocationResponse _$UpdateCourierLocationResponseFromJson(
  Map<String, dynamic> json,
) => UpdateCourierLocationResponse(
  success: json['success'] as bool? ?? false,
  message: json['message'] as String? ?? '',
);

Map<String, dynamic> _$UpdateCourierLocationResponseToJson(
  UpdateCourierLocationResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
};

RemoveCourierAvailabilityResponse _$RemoveCourierAvailabilityResponseFromJson(
  Map<String, dynamic> json,
) => RemoveCourierAvailabilityResponse(
  success: json['success'] as bool? ?? false,
  message: json['message'] as String? ?? '',
);

Map<String, dynamic> _$RemoveCourierAvailabilityResponseToJson(
  RemoveCourierAvailabilityResponse instance,
) => <String, dynamic>{
  'success': instance.success,
  'message': instance.message,
};

NearestCourierDto _$NearestCourierDtoFromJson(Map<String, dynamic> json) =>
    NearestCourierDto(
      courierId: json['courier_id'] as String,
      distanceKm: (json['distance_km'] as num).toDouble(),
      estimatedTimeMin: (json['estimated_time_min'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$NearestCourierDtoToJson(NearestCourierDto instance) =>
    <String, dynamic>{
      'courier_id': instance.courierId,
      'distance_km': instance.distanceKm,
      'estimated_time_min': instance.estimatedTimeMin,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

FindNearestCouriersResponse _$FindNearestCouriersResponseFromJson(
  Map<String, dynamic> json,
) => FindNearestCouriersResponse(
  total: (json['total'] as num).toInt(),
  couriers: (json['couriers'] as List<dynamic>)
      .map((e) => NearestCourierDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$FindNearestCouriersResponseToJson(
  FindNearestCouriersResponse instance,
) => <String, dynamic>{
  'total': instance.total,
  'couriers': instance.couriers.map((e) => e.toJson()).toList(),
};
