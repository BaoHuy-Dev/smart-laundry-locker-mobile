import 'package:dio/dio.dart';
import 'package:smart_laundry_locker/core/network/dio_client.dart';

/// Thin typed gateway client for the locker flow (Phase 1+2 backend).
/// All calls go through the API gateway with the JWT already attached
/// by [DioClient]/AuthInterceptor.
class LockerOpsService {
  LockerOpsService({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  Future<List<Map<String, dynamic>>> _list(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final res = await _dio.get(path, queryParameters: query);
    final data = res.data?['data'];
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return const [];
  }

  Future<Map<String, dynamic>> _map(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? query,
  }) async {
    final res = await _dio.request(
      path,
      data: body,
      queryParameters: query,
      options: Options(method: method),
    );
    final data = res.data?['data'];
    return data is Map<String, dynamic> ? data : <String, dynamic>{};
  }

  // ---- Catalogue ----
  Future<List<Map<String, dynamic>>> lockers() => _list('/api/lockers');

  Future<List<Map<String, dynamic>>> lockersByStore(int storeId) =>
      _list('/api/lockers', query: {'storeId': storeId});

  Future<Map<String, dynamic>> locker(int lockerId) =>
      _map('GET', '/api/lockers/$lockerId');

  Future<Map<String, dynamic>> layout(int lockerId) =>
      _map('GET', '/api/lockers/$lockerId/layout');

  // ---- Customer orders ----
  Future<List<Map<String, dynamic>>> myOrders() =>
      _list('/api/orders/my-orders');

  Future<Map<String, dynamic>> createSend({
    required int lockerId,
    required String receiverPhone,
    String? receiverName,
    String? note,
    String? promotionCode,
  }) => _map(
    'POST',
    '/api/orders/send',
    body: {
      'lockerId': lockerId,
      'receiverPhone': receiverPhone,
      'receiverName': receiverName,
      'note': note,
      // Forward-compatible: backend ignores unknown fields today; will apply
      // once the send DTO accepts a promotion code.
      if (promotionCode != null) 'promotionCode': promotionCode,
    },
  );

  Future<Map<String, dynamic>> createRental({
    required int lockerId,
    required String cellType,
    required int hours,
    String? note,
    String? promotionCode,
  }) => _map(
    'POST',
    '/api/orders/rental',
    body: {
      'lockerId': lockerId,
      'cellType': cellType,
      'hours': hours,
      'note': note,
      if (promotionCode != null) 'promotionCode': promotionCode,
    },
  );

  // ---- Promotions / loyalty / payments ----
  /// Validate a promo code. Returns `{code, valid, promotion:{...}}`.
  Future<Map<String, dynamic>> validatePromotion(String code) =>
      _map('GET', '/api/promotions/validate/$code');

  /// Current user's loyalty account: `{id, userId, points, stamps, tier}`.
  Future<Map<String, dynamic>> loyaltyPoints() =>
      _map('GET', '/api/loyalty/points');

  /// Payments recorded for an order (latest first by convention).
  Future<List<Map<String, dynamic>>> paymentsByOrder(int orderId) =>
      _list('/api/payments/order/$orderId');

  Future<Map<String, dynamic>> confirmDrop(int orderId) =>
      _map('PUT', '/api/orders/$orderId/confirm');

  Future<Map<String, dynamic>> completePickup(int orderId) =>
      _map('PUT', '/api/orders/$orderId/complete');

  Future<Map<String, dynamic>> endRental(int orderId) =>
      _map('POST', '/api/orders/$orderId/pickup-storage');

  Future<Map<String, dynamic>> extendRental(int orderId, int hours) => _map(
    'POST',
    '/api/orders/$orderId/extend-rental',
    body: {'hours': hours},
  );

  Future<Map<String, dynamic>> cancelOrder(int orderId) =>
      _map('PUT', '/api/orders/$orderId/cancel');

  Future<Map<String, dynamic>> delegate(
    int orderId, {
    required String phone,
    String? name,
    String? note,
  }) => _map(
    'POST',
    '/api/orders/$orderId/delegate',
    body: {'phone': phone, 'name': name, 'note': note},
  );

  Future<Map<String, dynamic>> reportFault(int boxId, String reason) =>
      _map('POST', '/api/boxes/$boxId/fault', body: {'reason': reason});

  /// All fault reports the signed-in customer has filed, newest first.
  Future<List<Map<String, dynamic>>> myReports() =>
      _list('/api/lockers/my-reports');

  /// Recreate a COMPLETED/CANCELED order with the same parameters
  /// (locker, receiver, cell type/hours) and a fresh PIN/QR.
  Future<Map<String, dynamic>> reorder(int orderId) =>
      _map('POST', '/api/orders/$orderId/reorder');

  /// Simulated/real cabinet unlock: verifies [pinCode] against [boxId] then
  /// asks the IoT layer to open the door. See `IotService.unlock` backend-side.
  Future<Map<String, dynamic>> unlock(int lockerId, int boxId, String pinCode) =>
      _map(
        'POST',
        '/api/iot/unlock',
        body: {'lockerId': lockerId, 'boxId': boxId, 'pinCode': pinCode},
      );

  // ---- Manager ----
  Future<List<Map<String, dynamic>>> managerStats() =>
      _list('/api/manage/lockers/stats');

  Future<List<Map<String, dynamic>>> managerOrders({
    String? status,
    String? type,
  }) => _list(
    '/api/manage/orders',
    query: {
      if (status != null && status.isNotEmpty) 'status': status,
      if (type != null && type.isNotEmpty) 'type': type,
    },
  );

  // ---- Maintenance ----
  Future<List<Map<String, dynamic>>> faults() =>
      _list('/api/maintenance/faults');

  Future<List<Map<String, dynamic>>> reports({bool mine = false}) =>
      _list('/api/maintenance/reports', query: {'mine': mine});

  Future<Map<String, dynamic>> claimReport(int reportId) =>
      _map('PUT', '/api/maintenance/reports/$reportId/claim');

  Future<Map<String, dynamic>> resolveReport(int reportId) =>
      _map('PUT', '/api/maintenance/reports/$reportId/resolve');

  Future<Map<String, dynamic>> clearFault(int boxId) =>
      _map('POST', '/api/maintenance/boxes/$boxId/clear-fault');

  /// Ngưng dùng ô có chủ đích (bảo trì/đóng). Ô bị loại khỏi mọi reserve.
  Future<Map<String, dynamic>> outOfService(int boxId, {String? reason}) =>
      _map(
        'POST',
        '/api/maintenance/boxes/$boxId/out-of-service',
        body: reason == null ? null : {'reason': reason},
      );

  /// Đưa ô vào trạng thái đang vệ sinh/khử khuẩn.
  Future<Map<String, dynamic>> cleaning(int boxId) =>
      _map('POST', '/api/maintenance/boxes/$boxId/cleaning');

  /// Khôi phục ô từ OUT_OF_SERVICE/CLEANING về AVAILABLE.
  Future<Map<String, dynamic>> returnToService(int boxId) =>
      _map('POST', '/api/maintenance/boxes/$boxId/return-to-service');

  /// Nhật ký xử lý của 1 phiếu bảo trì (work-log nhiều bước).
  Future<List<Map<String, dynamic>>> reportLogs(int reportId) =>
      _list('/api/maintenance/reports/$reportId/logs');

  Future<Map<String, dynamic>> addReportLog(int reportId, String note) => _map(
    'POST',
    '/api/maintenance/reports/$reportId/logs',
    body: {'note': note},
  );

  /// Lịch bảo trì phòng ngừa (mỗi mục kèm cờ `due`).
  Future<List<Map<String, dynamic>>> maintenanceSchedules() =>
      _list('/api/maintenance/schedules');

  /// KTV đánh dấu đã kiểm tra xong 1 lịch → dời mốc đến hạn kế tiếp.
  Future<Map<String, dynamic>> completeSchedule(int scheduleId) =>
      _map('POST', '/api/maintenance/schedules/$scheduleId/complete');

  /// Human-readable message from an [ApiResponse] error payload.
  static String errorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
      if (error.response?.statusCode == 403) {
        return 'Bạn không có quyền thực hiện thao tác này';
      }
      return 'Lỗi kết nối máy chủ';
    }
    return 'Đã xảy ra lỗi';
  }
}
