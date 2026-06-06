import 'package:json_annotation/json_annotation.dart';

part 'responses.g.dart';

@JsonSerializable()
class UpdateCourierLocationResponse {
  @JsonKey(defaultValue: false)
  final bool success;
  @JsonKey(defaultValue: '')
  final String message;

  const UpdateCourierLocationResponse({
    required this.success,
    required this.message,
  });

  factory UpdateCourierLocationResponse.fromJson(Map<String, dynamic> json) =>
      _$UpdateCourierLocationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCourierLocationResponseToJson(this);
}

@JsonSerializable()
class RemoveCourierAvailabilityResponse {
  @JsonKey(defaultValue: false)
  final bool success;
  @JsonKey(defaultValue: '')
  final String message;

  const RemoveCourierAvailabilityResponse({
    required this.success,
    required this.message,
  });

  factory RemoveCourierAvailabilityResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$RemoveCourierAvailabilityResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$RemoveCourierAvailabilityResponseToJson(this);
}

@JsonSerializable()
class NearestCourierDto {
  @JsonKey(name: 'courier_id')
  final String courierId;
  @JsonKey(name: 'distance_km')
  final double distanceKm;
  @JsonKey(name: 'estimated_time_min')
  final double estimatedTimeMin;
  final double latitude;
  final double longitude;

  const NearestCourierDto({
    required this.courierId,
    required this.distanceKm,
    required this.estimatedTimeMin,
    required this.latitude,
    required this.longitude,
  });

  factory NearestCourierDto.fromJson(Map<String, dynamic> json) =>
      _$NearestCourierDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NearestCourierDtoToJson(this);
}

@JsonSerializable()
class FindNearestCouriersResponse {
  final int total;
  final List<NearestCourierDto> couriers;

  const FindNearestCouriersResponse({
    required this.total,
    required this.couriers,
  });

  factory FindNearestCouriersResponse.fromJson(Map<String, dynamic> json) =>
      _$FindNearestCouriersResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FindNearestCouriersResponseToJson(this);
}
