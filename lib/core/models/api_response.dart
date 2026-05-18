import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

@Freezed(genericArgumentFactories: true)
abstract class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    @Default(false) bool success,
    required T data,
    String? message,
    String? timestamp,
  }) = _ApiResponse;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$ApiResponseFromJson(json, fromJsonT);
}

@Freezed(genericArgumentFactories: true)
abstract class PaginatedResponse<T> with _$PaginatedResponse<T> {
  const factory PaginatedResponse({
    @Default([]) List<T> content,
    @Default(0) int totalElements,
    @Default(0) int totalPages,
    @Default(0) int size,
    @Default(0) int number,
    @Default(false) bool first,
    @Default(false) bool last,
  }) = _PaginatedResponse;

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object?) fromJsonT,
  ) => _$PaginatedResponseFromJson(json, fromJsonT);
}
