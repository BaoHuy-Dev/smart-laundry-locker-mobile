import 'package:json_annotation/json_annotation.dart';

part 'update_courier_location_dto.g.dart';

@JsonSerializable()
class UpdateCourierLocationDto {
  final double latitude;
  final double longitude;

  const UpdateCourierLocationDto({
    required this.latitude,
    required this.longitude,
  });

  factory UpdateCourierLocationDto.fromJson(Map<String, dynamic> json) =>
      _$UpdateCourierLocationDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UpdateCourierLocationDtoToJson(this);
}
