import 'package:json_annotation/json_annotation.dart';

part 'pickup_package_dto.g.dart';

@JsonSerializable()
class PickupPackageDto {
  final String accessCode;

  const PickupPackageDto({required this.accessCode});

  factory PickupPackageDto.fromJson(Map<String, dynamic> json) =>
      _$PickupPackageDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PickupPackageDtoToJson(this);
}
