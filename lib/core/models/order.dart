import 'package:freezed_annotation/freezed_annotation.dart';

import 'locker.dart';
import 'service.dart';

part 'order.freezed.dart';
part 'order.g.dart';

enum OrderType {
  @JsonValue('STANDARD_DROPOFF')
  standardDropoff,
  @JsonValue('LAUNDRY')
  laundry,
  @JsonValue('STORAGE')
  storage,
}

enum OrderStatus {
  @JsonValue('INITIALIZED')
  initialized,
  @JsonValue('WAITING')
  waiting,
  @JsonValue('COLLECTED')
  collected,
  @JsonValue('PROCESSING')
  processing,
  @JsonValue('READY')
  ready,
  @JsonValue('RETURNED')
  returned,
  @JsonValue('COMPLETED')
  completed,
  @JsonValue('CANCELED')
  canceled,
}

@freezed
abstract class Order with _$Order {
  const factory Order({
    required int id,
    String? orderCode,
    required int userId,
    OrderType? type,
    ServiceCategory? serviceCategory,
    PricingType? pricingType,
    required int lockerId,
    Locker? locker,
    String? lockerName,
    String? lockerCode,
    required int boxId,
    int? boxNumber,
    int? sendBoxNumber,
    int? receiveBoxNumber,
    List<OrderBox>? boxes,
    required OrderStatus status,
    String? pin,
    String? pinCode,

    Map<String, dynamic>? customer,

    int? senderId,
    String? senderName,
    String? senderPhone,

    int? receiverId,
    String? receiverName,
    String? receiverPhone,

    required double totalAmount,
    double? totalPrice,
    double? originalPrice,
    double? storagePrice,
    dynamic estimatedPrice, // Can be EstimatedPrice or double based on RN type
    double? actualPrice,
    double? discountAmount,
    PriceBreakdown? priceBreakdown,

    String? promotionCode,
    List<String>? appliedPromotionCodes,
    double? promotionDiscount,
    double? discount,
    PromotionInfo? promotionInfo,
    Map<String, dynamic>? promotion,

    double? estimatedWeight,
    double? actualWeight,
    String? weightUnit,

    bool? isOvertime,
    double? overtimeHours,
    double? extraFee,

    bool? isPaid,
    bool? paymentRequired,
    Map<String, dynamic>? payment,

    String? nextAction,
    String? nextActionMessage,

    List<OrderItem>? items,
    List<OrderItem>? orderDetails,
    List<LaundryService>? services,
    String? customerNote,
    String? staffNote,
    String? deliveryAddress,

    String? expiresAt,
    String? intendedReceiveAt,
    String? pickupDeadline,
    String? createdAt,
    String? updatedAt,
    String? confirmedAt,
    String? collectedAt,
    String? processedAt,
    String? readyAt,
    String? returnedAt,
    String? completedAt,
    String? canceledAt,
    String? cancelReason,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

@freezed
abstract class OrderBox with _$OrderBox {
  const factory OrderBox({
    required int id,
    required String boxNumber,
    required String size,
  }) = _OrderBox;

  factory OrderBox.fromJson(Map<String, dynamic> json) =>
      _$OrderBoxFromJson(json);
}

@freezed
abstract class OrderItem with _$OrderItem {
  const factory OrderItem({
    required int id,
    required int serviceId,
    required String serviceName,
    required int quantity,
    required double price,
    required double subtotal,
  }) = _OrderItem;

  factory OrderItem.fromJson(Map<String, dynamic> json) =>
      _$OrderItemFromJson(json);
}

@freezed
abstract class OrderTrackingDetail with _$OrderTrackingDetail {
  const factory OrderTrackingDetail({
    required int orderId,
    required OrderStatus status,
    required String statusDescription,
    String? pinCode,
    String? lockerName,
    String? lockerCode,
    int? boxNumber,
    required String createdAt,
    required String updatedAt,
    String? estimatedReadyAt,
    String? completedAt,
    required bool isPaid,
    required String nextAction,
  }) = _OrderTrackingDetail;

  factory OrderTrackingDetail.fromJson(Map<String, dynamic> json) =>
      _$OrderTrackingDetailFromJson(json);
}

@freezed
abstract class OrderTimelineEvent with _$OrderTimelineEvent {
  const factory OrderTimelineEvent({
    required String status,
    required String title,
    required String description,
    required String timestamp,
    String? icon,
    String? color,
    String? actor,
    String? metadata,
  }) = _OrderTimelineEvent;

  factory OrderTimelineEvent.fromJson(Map<String, dynamic> json) =>
      _$OrderTimelineEventFromJson(json);
}

@freezed
abstract class OrderTimelineResponse with _$OrderTimelineResponse {
  const factory OrderTimelineResponse({
    required int orderId,
    required String currentStatus,
    String? estimatedCompletion,
    required double progressPercentage,
    required List<OrderTimelineEvent> events,
    String? nextAction,
    String? nextActionActor,
  }) = _OrderTimelineResponse;

  factory OrderTimelineResponse.fromJson(Map<String, dynamic> json) =>
      _$OrderTimelineResponseFromJson(json);
}
