import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

enum PaymentMethod {
  @JsonValue('VNPAY')
  vnpay,
  @JsonValue('MOMO')
  momo,
  @JsonValue('CASH')
  cash,
}

enum PaymentStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('SUCCESS')
  success,
  @JsonValue('FAILED')
  failed,
  @JsonValue('EXPIRED')
  expired,
}

enum RefundStatus {
  @JsonValue('PENDING')
  pending,
  @JsonValue('APPROVED')
  approved,
  @JsonValue('REJECTED')
  rejected,
  @JsonValue('COMPLETED')
  completed,
}

@freezed
abstract class Payment with _$Payment {
  const factory Payment({
    required int id,
    required int orderId,
    required double amount,
    required PaymentMethod method,
    required PaymentStatus status,
    String? transactionId,
    String? paymentUrl,
    String? expiredAt,
    String? paidAt,
    String? createdAt,
    String? updatedAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}

@freezed
abstract class RefundResponse with _$RefundResponse {
  const factory RefundResponse({
    required int id,
    required int paymentId,
    required int orderId,
    required double amount,
    required String reason,
    required RefundStatus status,
    String? rejectionReason,
    int? processedBy,
    required String createdAt,
    String? processedAt,
  }) = _RefundResponse;

  factory RefundResponse.fromJson(Map<String, dynamic> json) =>
      _$RefundResponseFromJson(json);
}
