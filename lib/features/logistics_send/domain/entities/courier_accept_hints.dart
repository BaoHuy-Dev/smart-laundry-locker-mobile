import 'package:equatable/equatable.dart';

/// Gợi ý từ bước Courier chấp nhận đơn — tách khỏi model infrastructure feature khác.
class CourierAcceptHints extends Equatable {
  final String? accessCode;
  final String? lockerLabel;
  final String? cabinetName;
  final String? address;
  final String? recipientName;
  final String? recipientPhone;
  final double? latitude;
  final double? longitude;

  const CourierAcceptHints({
    this.accessCode,
    this.lockerLabel,
    this.cabinetName,
    this.address,
    this.recipientName,
    this.recipientPhone,
    this.latitude,
    this.longitude,
  });

  @override
  List<Object?> get props => [
    accessCode,
    lockerLabel,
    cabinetName,
    address,
    recipientName,
    recipientPhone,
    latitude,
    longitude,
  ];
}
