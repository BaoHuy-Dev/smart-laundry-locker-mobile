// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Payment _$PaymentFromJson(Map<String, dynamic> json) => _Payment(
  id: (json['id'] as num).toInt(),
  orderId: (json['orderId'] as num).toInt(),
  amount: (json['amount'] as num).toDouble(),
  method: $enumDecode(_$PaymentMethodEnumMap, json['method']),
  status: $enumDecode(_$PaymentStatusEnumMap, json['status']),
  transactionId: json['transactionId'] as String?,
  paymentUrl: json['paymentUrl'] as String?,
  expiredAt: json['expiredAt'] as String?,
  paidAt: json['paidAt'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$PaymentToJson(_Payment instance) => <String, dynamic>{
  'id': instance.id,
  'orderId': instance.orderId,
  'amount': instance.amount,
  'method': _$PaymentMethodEnumMap[instance.method]!,
  'status': _$PaymentStatusEnumMap[instance.status]!,
  'transactionId': instance.transactionId,
  'paymentUrl': instance.paymentUrl,
  'expiredAt': instance.expiredAt,
  'paidAt': instance.paidAt,
  'createdAt': instance.createdAt,
  'updatedAt': instance.updatedAt,
};

const _$PaymentMethodEnumMap = {
  PaymentMethod.vnpay: 'VNPAY',
  PaymentMethod.momo: 'MOMO',
  PaymentMethod.cash: 'CASH',
};

const _$PaymentStatusEnumMap = {
  PaymentStatus.pending: 'PENDING',
  PaymentStatus.success: 'SUCCESS',
  PaymentStatus.failed: 'FAILED',
  PaymentStatus.expired: 'EXPIRED',
};

_RefundResponse _$RefundResponseFromJson(Map<String, dynamic> json) =>
    _RefundResponse(
      id: (json['id'] as num).toInt(),
      paymentId: (json['paymentId'] as num).toInt(),
      orderId: (json['orderId'] as num).toInt(),
      amount: (json['amount'] as num).toDouble(),
      reason: json['reason'] as String,
      status: $enumDecode(_$RefundStatusEnumMap, json['status']),
      rejectionReason: json['rejectionReason'] as String?,
      processedBy: (json['processedBy'] as num?)?.toInt(),
      createdAt: json['createdAt'] as String,
      processedAt: json['processedAt'] as String?,
    );

Map<String, dynamic> _$RefundResponseToJson(_RefundResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'paymentId': instance.paymentId,
      'orderId': instance.orderId,
      'amount': instance.amount,
      'reason': instance.reason,
      'status': _$RefundStatusEnumMap[instance.status]!,
      'rejectionReason': instance.rejectionReason,
      'processedBy': instance.processedBy,
      'createdAt': instance.createdAt,
      'processedAt': instance.processedAt,
    };

const _$RefundStatusEnumMap = {
  RefundStatus.pending: 'PENDING',
  RefundStatus.approved: 'APPROVED',
  RefundStatus.rejected: 'REJECTED',
  RefundStatus.completed: 'COMPLETED',
};
