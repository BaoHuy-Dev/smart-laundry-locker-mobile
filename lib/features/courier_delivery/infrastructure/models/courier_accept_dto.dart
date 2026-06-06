import 'package:json_annotation/json_annotation.dart';

part 'courier_accept_dto.g.dart';

@JsonSerializable()
class CourierAcceptDto {
  final String dispatchId;

  const CourierAcceptDto({required this.dispatchId});

  factory CourierAcceptDto.fromJson(Map<String, dynamic> json) =>
      _$CourierAcceptDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CourierAcceptDtoToJson(this);
}
