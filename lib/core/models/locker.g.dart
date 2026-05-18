// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Locker _$LockerFromJson(Map<String, dynamic> json) => _Locker(
  id: (json['id'] as num).toInt(),
  storeId: (json['storeId'] as num).toInt(),
  name: json['name'] as String,
  code: json['code'] as String?,
  location: json['location'] as String?,
  image: json['image'] as String?,
  imageUrl: json['imageUrl'] as String?,
  status:
      $enumDecodeNullable(_$LockerStatusEnumMap, json['status']) ??
      LockerStatus.active,
  totalBoxes: (json['totalBoxes'] as num?)?.toInt() ?? 0,
  availableBoxes: (json['availableBoxes'] as num?)?.toInt() ?? 0,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$LockerToJson(_Locker instance) => <String, dynamic>{
  'id': instance.id,
  'storeId': instance.storeId,
  'name': instance.name,
  'code': instance.code,
  'location': instance.location,
  'image': instance.image,
  'imageUrl': instance.imageUrl,
  'status': _$LockerStatusEnumMap[instance.status]!,
  'totalBoxes': instance.totalBoxes,
  'availableBoxes': instance.availableBoxes,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$LockerStatusEnumMap = {
  LockerStatus.active: 'ACTIVE',
  LockerStatus.maintenance: 'MAINTENANCE',
  LockerStatus.inactive: 'INACTIVE',
};

_Box _$BoxFromJson(Map<String, dynamic> json) => _Box(
  id: (json['id'] as num).toInt(),
  lockerId: (json['lockerId'] as num).toInt(),
  boxNumber: json['boxNumber'] as String,
  size: $enumDecode(_$BoxSizeEnumMap, json['size']),
  status:
      $enumDecodeNullable(_$BoxStatusEnumMap, json['status']) ??
      BoxStatus.available,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$BoxToJson(_Box instance) => <String, dynamic>{
  'id': instance.id,
  'lockerId': instance.lockerId,
  'boxNumber': instance.boxNumber,
  'size': _$BoxSizeEnumMap[instance.size]!,
  'status': _$BoxStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$BoxSizeEnumMap = {
  BoxSize.small: 'SMALL',
  BoxSize.medium: 'MEDIUM',
  BoxSize.large: 'LARGE',
};

const _$BoxStatusEnumMap = {
  BoxStatus.available: 'AVAILABLE',
  BoxStatus.occupied: 'OCCUPIED',
  BoxStatus.reserved: 'RESERVED',
  BoxStatus.maintenance: 'MAINTENANCE',
};

_LockerReport _$LockerReportFromJson(Map<String, dynamic> json) =>
    _LockerReport(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      lockerId: (json['lockerId'] as num).toInt(),
      description: json['description'] as String,
      status:
          $enumDecodeNullable(_$LockerReportStatusEnumMap, json['status']) ??
          LockerReportStatus.pending,
      createdAt: json['createdAt'] as String,
      resolvedAt: json['resolvedAt'] as String?,
    );

Map<String, dynamic> _$LockerReportToJson(_LockerReport instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'lockerId': instance.lockerId,
      'description': instance.description,
      'status': _$LockerReportStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt,
      'resolvedAt': instance.resolvedAt,
    };

const _$LockerReportStatusEnumMap = {
  LockerReportStatus.pending: 'PENDING',
  LockerReportStatus.resolved: 'RESOLVED',
  LockerReportStatus.rejected: 'REJECTED',
};
