import 'package:json_annotation/json_annotation.dart';

part 'courier_deposit_dtos.g.dart';

@JsonSerializable()
class CourierDepositOpenDto {
  final String orderCode;
  final String lockerId;

  const CourierDepositOpenDto({
    required this.orderCode,
    required this.lockerId,
  });

  factory CourierDepositOpenDto.fromJson(Map<String, dynamic> json) =>
      _$CourierDepositOpenDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CourierDepositOpenDtoToJson(this);
}

@JsonSerializable()
class CourierDepositConfirmDto {
  final String orderCode;
  final String recipientPhone;
  final String recipientName;
  final String lockerId;
  final List<String>? imageUrls;

  const CourierDepositConfirmDto({
    required this.orderCode,
    required this.recipientPhone,
    required this.recipientName,
    required this.lockerId,
    this.imageUrls,
  });

  factory CourierDepositConfirmDto.fromJson(Map<String, dynamic> json) =>
      _$CourierDepositConfirmDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CourierDepositConfirmDtoToJson(this);
}
