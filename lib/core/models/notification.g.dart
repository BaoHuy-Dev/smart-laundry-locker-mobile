// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    _AppNotification(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      title: json['title'] as String,
      body: json['body'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      isRead: json['isRead'] as bool? ?? false,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$AppNotificationToJson(_AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'title': instance.title,
      'body': instance.body,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'isRead': instance.isRead,
      'data': instance.data,
      'createdAt': instance.createdAt,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.orderCreated: 'ORDER_CREATED',
  NotificationType.orderConfirmed: 'ORDER_CONFIRMED',
  NotificationType.orderCollected: 'ORDER_COLLECTED',
  NotificationType.orderProcessing: 'ORDER_PROCESSING',
  NotificationType.orderReady: 'ORDER_READY',
  NotificationType.orderReturned: 'ORDER_RETURNED',
  NotificationType.orderCompleted: 'ORDER_COMPLETED',
  NotificationType.orderCanceled: 'ORDER_CANCELED',
  NotificationType.paymentSuccess: 'PAYMENT_SUCCESS',
  NotificationType.paymentFailed: 'PAYMENT_FAILED',
  NotificationType.system: 'SYSTEM',
};
