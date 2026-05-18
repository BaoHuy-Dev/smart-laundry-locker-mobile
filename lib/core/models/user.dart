import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

enum UserRole {
  @JsonValue('USER')
  user,
  @JsonValue('STAFF')
  staff,
  @JsonValue('PARTNER')
  partner,
  @JsonValue('ADMIN')
  admin,
}

@freezed
abstract class User with _$User {
  const factory User({
    required int id,
    @Deprecated('Use firstName and lastName instead') String? fullName,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    String? imageUrl,
    String? image,
    String? joinDate,
    @Default(false) bool emailVerified,
    @Default(false) bool phoneVerified,
    String? provider,
    @Default(UserRole.user) UserRole role,
    @Default(true) bool isActive,
    String? createdAt,
    String? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
abstract class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}
