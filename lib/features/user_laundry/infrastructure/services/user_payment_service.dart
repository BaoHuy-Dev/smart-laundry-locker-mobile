import 'package:smart_laundry_locker/features/user_laundry/infrastructure/models/user_laundry_models.dart';
import 'package:smart_laundry_locker/features/user_laundry/infrastructure/services/user_gateway_client.dart';

class UserPaymentService extends UserGatewayClient {
  UserPaymentService(super.apiClient);

  Future<UserLaundryPayment> createPayment({
    required int orderId,
    required double amount,
    String method = 'MOMO',
    String? bankCode,
    String language = 'vn',
    String? description,
  }) async {
    final userId = await currentUserId();
    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/payments',
      data: {
        'orderId': orderId,
        'userId': userId,
        'amount': amount,
        'method': method,
        'bankCode': bankCode,
        'language': language,
        'description': description,
      },
    );
    return UserLaundryPayment.fromJson(unwrapMap(response));
  }

  Future<List<UserLaundryPayment>> getPaymentsByOrder(int orderId) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/api/payments/order/$orderId',
    );
    return unwrapList(response)
        .whereType<Map<String, dynamic>>()
        .map(UserLaundryPayment.fromJson)
        .where((payment) => payment.id > 0)
        .toList();
  }
}
