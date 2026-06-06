class RequestSendPackageResponse {
  final String dispatchId;
  final String? orderId;
  final String status;
  final String message;

  const RequestSendPackageResponse({
    required this.dispatchId,
    this.orderId,
    required this.status,
    required this.message,
  });

  factory RequestSendPackageResponse.fromJson(Map<String, dynamic> json) {
    String pick(String key1, String key2) =>
        (json[key1] ?? json[key2])?.toString() ?? '';

    String? pickNullable(String key1, String key2) {
      final v = json[key1] ?? json[key2];
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    return RequestSendPackageResponse(
      dispatchId: pick('dispatch_id', 'dispatchId'),
      orderId: pickNullable('order_id', 'orderId'),
      status: (json['status'] ?? json['Status'])?.toString() ?? '',
      message: (json['message'] ?? json['Message'])?.toString() ?? '',
    );
  }
}
