import 'package:freezed_annotation/freezed_annotation.dart';

part 'locker.freezed.dart';
part 'locker.g.dart';

enum LockerStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('MAINTENANCE')
  maintenance,
  @JsonValue('INACTIVE')
  inactive,
}

enum BoxSize {
  @JsonValue('SMALL')
  small,
  @JsonValue('MEDIUM')
  medium,
  @JsonValue('LARGE')
  large,
}

enum BoxStatus {
  @JsonValue('AVAILABLE')
  available,
  @JsonValue('OCCUPIED')
  occupied,
  @JsonValue('RESERVED')
  reserved,
  @JsonValue('MAINTENANCE')
  maintenance,
}

enum LockerReportStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('RESOLVED')
  resolved,
  @JsonValue('REJECTED')
  rejected,
}

@freezed
abstract class Locker with _$Locker {
  const factory Locker({
    required int id,
    required int storeId,
    required String name,
    String? code,
    String? location,
    String? image,
    String? imageUrl,
    @Default(LockerStatus.active) LockerStatus status,
    @Default(0) int totalBoxes,
    @Default(0) int availableBoxes,
    String? createdAt,
    String? updatedAt,
  }) = _Locker;

  factory Locker.fromJson(Map<String, dynamic> json) => _$LockerFromJson(json);
}

@freezed
abstract class Box with _$Box {
  const factory Box({
    required int id,
    required int lockerId,
    required String boxNumber,
    required BoxSize size,
    @Default(BoxStatus.available) BoxStatus status,
    String? createdAt,
    String? updatedAt,
  }) = _Box;

  factory Box.fromJson(Map<String, dynamic> json) => _$BoxFromJson(json);
}

@freezed
abstract class LockerReport with _$LockerReport {
  const factory LockerReport({
    required int id,
    required int userId,
    required int lockerId,
    required String description,
    @Default(LockerReportStatus.pending) LockerReportStatus status,
    required String createdAt,
    String? resolvedAt,
  }) = _LockerReport;

  factory LockerReport.fromJson(Map<String, dynamic> json) =>
      _$LockerReportFromJson(json);
}
