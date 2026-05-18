// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  id: (json['id'] as num).toInt(),
  fullName: json['fullName'] as String?,
  firstName: json['firstName'] as String?,
  lastName: json['lastName'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  avatarUrl: json['avatarUrl'] as String?,
  imageUrl: json['imageUrl'] as String?,
  image: json['image'] as String?,
  joinDate: json['joinDate'] as String?,
  emailVerified: json['emailVerified'] as bool? ?? false,
  phoneVerified: json['phoneVerified'] as bool? ?? false,
  provider: json['provider'] as String?,
  role: $enumDecodeNullable(_$UserRoleEnumMap, json['role']) ?? UserRole.user,
  isActive: json['isActive'] as bool? ?? true,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'email': instance.email,
  'phoneNumber': instance.phoneNumber,
  'avatarUrl': instance.avatarUrl,
  'imageUrl': instance.imageUrl,
  'image': instance.image,
  'joinDate': instance.joinDate,
  'emailVerified': instance.emailVerified,
  'phoneVerified': instance.phoneVerified,
  'provider': instance.provider,
  'role': _$UserRoleEnumMap[instance.role]!,
  'isActive': instance.isActive,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$UserRoleEnumMap = {
  UserRole.user: 'USER',
  UserRole.staff: 'STAFF',
  UserRole.partner: 'PARTNER',
  UserRole.admin: 'ADMIN',
};

_AuthTokens _$AuthTokensFromJson(Map<String, dynamic> json) => _AuthTokens(
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
);

Map<String, dynamic> _$AuthTokensToJson(_AuthTokens instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };
