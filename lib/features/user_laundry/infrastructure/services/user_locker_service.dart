import 'package:smart_laundry_locker/features/user_laundry/infrastructure/models/user_laundry_models.dart';
import 'package:smart_laundry_locker/features/user_laundry/infrastructure/services/user_gateway_client.dart';

class UserLockerService extends UserGatewayClient {
  UserLockerService(super.apiClient);

  Future<List<UserLaundryStore>> getStores() async {
    final response = await apiClient.get<Map<String, dynamic>>('/api/stores');
    return unwrapList(response)
        .whereType<Map<String, dynamic>>()
        .map(UserLaundryStore.fromJson)
        .where((store) => store.id > 0)
        .toList();
  }

  Future<List<UserLaundryLocker>> getLockersByStore(int storeId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/api/lockers',
      queryParameters: {'storeId': storeId},
    );
    return unwrapList(response)
        .whereType<Map<String, dynamic>>()
        .map(UserLaundryLocker.fromJson)
        .where((locker) => locker.id > 0)
        .toList();
  }

  Future<List<UserLaundryBox>> getBoxes(int lockerId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/api/lockers/$lockerId/boxes',
    );
    return unwrapList(response)
        .whereType<Map<String, dynamic>>()
        .map(UserLaundryBox.fromJson)
        .where((box) => box.id > 0)
        .toList();
  }

  Future<List<UserLaundryBox>> getAvailableBoxes(int lockerId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/api/lockers/$lockerId/boxes/available',
    );
    return unwrapList(response)
        .whereType<Map<String, dynamic>>()
        .map(UserLaundryBox.fromJson)
        .where((box) => box.id > 0)
        .toList();
  }

  Future<void> reportLocker({
    required int lockerId,
    required String reason,
    String? description,
  }) async {
    await apiClient.post<Map<String, dynamic>>(
      '/api/lockers/$lockerId/report',
      data: {'reason': reason, 'description': description},
    );
  }
}
