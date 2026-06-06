class DispatchStatusResponse {
  final String status;
  final String? courierId;
  final String? courierName;
  final String? courierPhone;
  final String? orderCode;
  final String? orderId;

  const DispatchStatusResponse({
    required this.status,
    this.courierId,
    this.courierName,
    this.courierPhone,
    this.orderCode,
    this.orderId,
  });

  factory DispatchStatusResponse.fromJson(Map<String, dynamic> json) {
    // Handle potential nesting in 'data' field from ApiClient
    final data = json['data'] as Map<String, dynamic>? ?? json;

    return DispatchStatusResponse(
      status: (data['status'] ?? data['Status'])?.toString() ?? 'ERROR',
      courierId: data['courierId']?.toString(),
      courierName: data['courierName']?.toString(),
      courierPhone: data['courierPhone']?.toString(),
      orderCode: data['orderCode']?.toString(),
      orderId: data['orderId']?.toString(),
    );
  }
}
