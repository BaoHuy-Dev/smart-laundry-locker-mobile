// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Store _$StoreFromJson(Map<String, dynamic> json) => _Store(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  address: json['address'] as String,
  phone: json['phone'] as String?,
  openTime: json['openTime'] as String?,
  closeTime: json['closeTime'] as String?,
  image: json['image'] as String?,
  imageUrl: json['imageUrl'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$StoreToJson(_Store instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'address': instance.address,
  'phone': instance.phone,
  'openTime': instance.openTime,
  'closeTime': instance.closeTime,
  'image': instance.image,
  'imageUrl': instance.imageUrl,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};
