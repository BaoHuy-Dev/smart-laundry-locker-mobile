import 'package:json_annotation/json_annotation.dart';

part 'courier_pickup_confirm_dto.g.dart';

@JsonSerializable()
class CourierPickupConfirmDto {
  final String orderCode;
  final List<String>? imageUrls;

  CourierPickupConfirmDto({required this.orderCode, this.imageUrls});

  factory CourierPickupConfirmDto.fromJson(Map<String, dynamic> json) =>
      _$CourierPickupConfirmDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CourierPickupConfirmDtoToJson(this);
}
