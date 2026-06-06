// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_courier_location_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCourierLocationDto _$UpdateCourierLocationDtoFromJson(
  Map<String, dynamic> json,
) => UpdateCourierLocationDto(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
);

Map<String, dynamic> _$UpdateCourierLocationDtoToJson(
  UpdateCourierLocationDto instance,
) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
};
