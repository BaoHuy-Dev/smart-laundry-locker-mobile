import 'package:smart_laundry_locker/features/user_laundry/infrastructure/models/user_laundry_models.dart';
import 'package:smart_laundry_locker/features/user_laundry/infrastructure/services/user_gateway_client.dart';

class UserLaundryService extends UserGatewayClient {
  UserLaundryService(super.apiClient);

  Future<List<UserLaundryServiceItem>> getServices({
    String? category,
    int? storeId,
  }) async {
    final query = <String, dynamic>{};
    if (category != null && category.isNotEmpty) query['category'] = category;
    if (storeId != null) query['storeId'] = storeId;

    final response = await apiClient.get<Map<String, dynamic>>(
      '/api/services',
      queryParameters: query.isEmpty ? null : query,
    );
    return unwrapList(response)
        .whereType<Map<String, dynamic>>()
        .map(UserLaundryServiceItem.fromJson)
        .where((service) => service.id > 0 && service.active)
        .toList();
  }
}
