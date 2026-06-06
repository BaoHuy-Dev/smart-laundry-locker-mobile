import 'package:json_annotation/json_annotation.dart';
import '../../../orders/infrastructure/models/order_model.dart';
import '../../../orders/infrastructure/models/order_detail_model.dart';

part 'responses.g.dart';

@JsonSerializable()
class CourierAcceptResponse {
  @JsonKey(name: 'order_id')
  final String orderId;
  @JsonKey(name: 'order_code')
  final String orderCode;
  @JsonKey(name: 'access_code')
  final String? accessCode;
  @JsonKey(name: 'locker_label')
  final String? lockerLabel;
  @JsonKey(name: 'locker_id')
  final String? lockerId;
  final int? row;
  final int? column;
  @JsonKey(name: 'recipient_name')
  final String? recipientName;
  @JsonKey(name: 'recipient_phone')
  final String? recipientPhone;
  @JsonKey(name: 'cabinet_name')
  final String? cabinetName;
  final String? address;
  final String message;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'receiver_latitude')
  final double? receiverLatitude;
  @JsonKey(name: 'receiver_longitude')
  final double? receiverLongitude;
  @JsonKey(name: 'order')
  final OrderModel? order;
  @JsonKey(name: 'order_details')
  final List<OrderDetailModel>? orderDetails;

  const CourierAcceptResponse({
    required this.orderId,
    required this.orderCode,
    this.accessCode,
    this.lockerLabel,
    this.lockerId,
    this.row,
    this.column,
    this.recipientName,
    this.recipientPhone,
    this.cabinetName,
    this.address,
    required this.message,
    this.latitude,
    this.longitude,
    this.receiverLatitude,
    this.receiverLongitude,
    this.order,
    this.orderDetails,
  });

  factory CourierAcceptResponse.fromJson(Map<String, dynamic> json) {
    String? pick(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
      return null;
    }

    return CourierAcceptResponse(
      orderId: pick(['order_id', 'orderId']) ?? '',
      orderCode: pick(['order_code', 'orderCode']) ?? '',
      accessCode: pick(['access_code', 'accessCode']),
      lockerLabel: pick(['locker_label', 'lockerLabel']),
      lockerId: pick(['locker_id', 'lockerId']),
      row: json['row'] as int?,
      column: json['column'] as int?,
      recipientName: pick(['recipient_name', 'recipientName']),
      recipientPhone: pick(['recipient_phone', 'recipientPhone']),
      cabinetName: pick(['cabinet_name', 'cabinetName']),
      address: pick(['address']),
      message: pick(['message']) ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      receiverLatitude:
          (json['receiver_latitude'] as num? ??
                  json['receiverLatitude'] as num?)
              ?.toDouble(),
      receiverLongitude:
          (json['receiver_longitude'] as num? ??
                  json['receiverLongitude'] as num?)
              ?.toDouble(),
      order: (json['order'] ?? json['Order']) != null
          ? OrderModel.fromJson(
              (json['order'] ?? json['Order']) as Map<String, dynamic>,
            )
          : null,
      orderDetails: (json['order_details'] ?? json['orderDetails']) != null
          ? ((json['order_details'] ?? json['orderDetails']) as List)
                .map(
                  (dynamic e) =>
                      OrderDetailModel.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : null,
    );
  }

  String get formattedPosition {
    if (row == null || column == null) return 'N/A';
    return '${row}x$column';
  }

  Map<String, dynamic> toJson() => {
    'order_id': orderId,
    'order_code': orderCode,
    'access_code': accessCode,
    'locker_label': lockerLabel,
    'locker_id': lockerId,
    'row': row,
    'column': column,
    'recipient_name': recipientName,
    'recipient_phone': recipientPhone,
    'cabinet_name': cabinetName,
    'address': address,
    'message': message,
    'latitude': latitude,
    'longitude': longitude,
    'receiver_latitude': receiverLatitude,
    'receiver_longitude': receiverLongitude,
    'order': order?.toJson(),
    'order_details': orderDetails?.map((e) => e.toJson()).toList(),
  };
}

@JsonSerializable()
class CourierDepositOpenResponse {
  final bool success;
  final String message;

  const CourierDepositOpenResponse({
    required this.success,
    required this.message,
  });

  factory CourierDepositOpenResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return CourierDepositOpenResponse(
      success: (data?['success'] ?? json['success']) as bool? ?? false,
      message: (data?['message'] ?? json['message']) as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => _$CourierDepositOpenResponseToJson(this);
}

@JsonSerializable()
class CourierDepositConfirmResponse {
  final bool success;
  final String message;

  const CourierDepositConfirmResponse({
    required this.success,
    required this.message,
  });

  factory CourierDepositConfirmResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return CourierDepositConfirmResponse(
      success: (data?['success'] ?? json['success']) as bool? ?? false,
      message: (data?['message'] ?? json['message']) as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => _$CourierDepositConfirmResponseToJson(this);
}

@JsonSerializable()
class PickupPackageResponse {
  final bool success;
  final String message;
  @JsonKey(name: 'order_code')
  final String orderCode;
  @JsonKey(name: 'locker_label')
  final String lockerLabel;
  final int? row;
  final int? column;

  const PickupPackageResponse({
    required this.success,
    required this.message,
    required this.orderCode,
    required this.lockerLabel,
    this.row,
    this.column,
  });

  factory PickupPackageResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return PickupPackageResponse(
      success: (data?['success'] ?? json['success']) as bool? ?? false,
      message: (data?['message'] ?? json['message']) as String? ?? '',
      orderCode:
          (data?['order_code'] ??
                  data?['orderCode'] ??
                  json['order_code'] ??
                  json['orderCode'])
              as String? ??
          '',
      lockerLabel:
          (data?['locker_label'] ??
                  data?['lockerLabel'] ??
                  json['locker_label'] ??
                  json['lockerLabel'])
              as String? ??
          '',
      row: json['row'] as int?,
      column: json['column'] as int?,
    );
  }

  String get formattedPosition {
    if (row == null || column == null) return 'N/A';
    return '${row}x$column';
  }

  Map<String, dynamic> toJson() => _$PickupPackageResponseToJson(this);
}

class CourierVerifyCodeResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? order;

  const CourierVerifyCodeResponse({
    required this.success,
    required this.message,
    this.order,
  });

  factory CourierVerifyCodeResponse.fromJson(Map<String, dynamic> json) {
    return CourierVerifyCodeResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      order: json['order'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'order': order,
  };
}

class CourierRejectResponse {
  final bool success;
  final String message;

  const CourierRejectResponse({required this.success, required this.message});

  factory CourierRejectResponse.fromJson(Map<String, dynamic> json) {
    return CourierRejectResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'success': success, 'message': message};
}

@JsonSerializable()
class CourierPickupConfirmResponse {
  final bool success;
  final String message;

  CourierPickupConfirmResponse({required this.success, required this.message});

  factory CourierPickupConfirmResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return CourierPickupConfirmResponse(
      success: (data?['success'] ?? json['success']) as bool? ?? false,
      message: (data?['message'] ?? json['message']) as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => _$CourierPickupConfirmResponseToJson(this);
}
