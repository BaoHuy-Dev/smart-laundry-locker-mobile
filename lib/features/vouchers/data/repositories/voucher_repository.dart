import 'package:smart_laundry_locker/core/network/api_client.dart';
import '../models/voucher_model.dart';

class VoucherRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<VoucherModel>> getMyVouchers({String? status}) async {
    try {
      final queryParams = <String, String>{};
      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _apiClient.get(
        '/promotions/vouchers/my',
        queryParameters: queryParams,
      );

      final data = response.data;
      final List<dynamic> items = data['items'] ?? [];

      return items.map((item) => VoucherModel.fromJson(item)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> useVoucher(String voucherId) async {
    try {
      final response = await _apiClient.post(
        '/promotions/vouchers/$voucherId/use',
        data: {},
      );
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}
