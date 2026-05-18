import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

enum NotificationType {
  @JsonValue('ORDER_CREATED')
  orderCreated,
  @JsonValue('ORDER_CONFIRMED')
  orderConfirmed,
  @JsonValue('ORDER_COLLECTED')
  orderCollected,
  @JsonValue('ORDER_PROCESSING')
  orderProcessing,
  @JsonValue('ORDER_READY')
  orderReady,
  @JsonValue('ORDER_RETURNED')
  orderReturned,
  @JsonValue('ORDER_COMPLETED')
  orderCompleted,
  @JsonValue('ORDER_CANCELED')
  orderCanceled,
  @JsonValue('PAYMENT_SUCCESS')
  paymentSuccess,
  @JsonValue('PAYMENT_FAILED')
  paymentFailed,
  @JsonValue('SYSTEM')
  system,
}

@freezed
abstract class AppNotification with _$AppNotification {
  const factory AppNotification({
    required int id,
    required int userId,
    required String title,
    required String body,
    required NotificationType type,
    @Default(false) bool isRead,
    Map<String, dynamic>? data,
    String? createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);
}
