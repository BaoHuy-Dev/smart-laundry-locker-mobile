class RequestSendPackageResult {
  final String dispatchId;
  final String? orderId;
  final String status;
  final String message;

  const RequestSendPackageResult({
    required this.dispatchId,
    this.orderId,
    required this.status,
    required this.message,
  });
}
