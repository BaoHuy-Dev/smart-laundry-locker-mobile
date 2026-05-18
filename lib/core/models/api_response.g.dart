// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiResponse<T> _$ApiResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _ApiResponse<T>(
  success: json['success'] as bool? ?? false,
  data: fromJsonT(json['data']),
  message: json['message'] as String?,
  timestamp: json['timestamp'] as String?,
);

Map<String, dynamic> _$ApiResponseToJson<T>(
  _ApiResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'success': instance.success,
  'data': toJsonT(instance.data),
  'message': instance.message,
  'timestamp': instance.timestamp,
};

_PaginatedResponse<T> _$PaginatedResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => _PaginatedResponse<T>(
  content:
      (json['content'] as List<dynamic>?)?.map(fromJsonT).toList() ?? const [],
  totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
  totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
  size: (json['size'] as num?)?.toInt() ?? 0,
  number: (json['number'] as num?)?.toInt() ?? 0,
  first: json['first'] as bool? ?? false,
  last: json['last'] as bool? ?? false,
);

Map<String, dynamic> _$PaginatedResponseToJson<T>(
  _PaginatedResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'content': instance.content.map(toJsonT).toList(),
  'totalElements': instance.totalElements,
  'totalPages': instance.totalPages,
  'size': instance.size,
  'number': instance.number,
  'first': instance.first,
  'last': instance.last,
};
