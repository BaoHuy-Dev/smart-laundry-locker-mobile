import 'package:smart_laundry_locker/features/orders/infrastructure/models/responses/orders_response.dart';

class CourierOrderItem {
  final String orderId;
  final String? dispatchId;
  final String orderCode;
  final String status;
  final String? originCabinetId;
  final String? destinationCabinetId;
  final DateTime? updatedAt;
  final double accumulatedFee;

  const CourierOrderItem({
    required this.orderId,
    required this.dispatchId,
    required this.orderCode,
    required this.status,
    required this.originCabinetId,
    required this.destinationCabinetId,
    required this.updatedAt,
    required this.accumulatedFee,
  });

  factory CourierOrderItem.fromJson(Map<String, dynamic> json) {
    String readString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
      return '';
    }

    DateTime? parseDate(dynamic raw) {
      if (raw is String) return DateTime.tryParse(raw)?.toLocal();
      return null;
    }

    double parseDouble(dynamic raw) {
      if (raw is num) return raw.toDouble();
      if (raw is String) return double.tryParse(raw) ?? 0;
      return 0;
    }

    return CourierOrderItem(
      orderId: readString(['orderId', 'order_id', 'id']),
      dispatchId:
          json['dispatchId']?.toString() ??
          json['dispatch_id']?.toString() ??
          json['dispatch']?.toString(),
      orderCode: readString(['orderCode', 'code', 'order_code']),
      status: (json['status'] ?? '').toString(),
      originCabinetId: json['originCabinetId']?.toString(),
      destinationCabinetId: json['destinationCabinetId']?.toString(),
      updatedAt: parseDate(json['updatedAt'] ?? json['createdAt']),
      accumulatedFee: parseDouble(json['accumulatedFee']),
    );
  }
}

class CourierOrderHistoryResponse {
  final List<CourierOrderItem> items;

  const CourierOrderHistoryResponse({required this.items});
}

class CourierTodayStatsResponse {
  final int completedToday;
  final int deliveringToday;

  const CourierTodayStatsResponse({
    required this.completedToday,
    required this.deliveringToday,
  });
}

class CourierMeResponse {
  final List<OrderDetailResponse> orders;
  final PaginationData pagination;

  const CourierMeResponse({required this.orders, required this.pagination});

  factory CourierMeResponse.fromJson(Map<String, dynamic> json) {
    return CourierMeResponse(
      orders: (json['orders'] as List? ?? [])
          .map((e) => OrderDetailResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationData.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }
}
