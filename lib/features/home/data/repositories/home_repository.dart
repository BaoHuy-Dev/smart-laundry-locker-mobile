import 'package:smart_laundry_locker/core/network/api_client.dart';
import '../models/advertisement_model.dart';
import '../models/blog_model.dart';

class HomeRepository {
  final ApiClient _apiClient;

  HomeRepository(this._apiClient);

  Future<List<AdvertisementModel>> getActiveAdvertisements() async {
    try {
      final response = await _apiClient.get(
        '/advertisements',
        queryParameters: {'onlyActive': 'true', 'target': 'APP'},
      );

      final List<dynamic> items = response.data['items'] ?? [];
      return items.map((e) => AdvertisementModel.fromJson(e)).toList();
    } catch (e) {
      print("Error loading advertisements: $e");
      return [];
    }
  }

  Future<List<BlogModel>> getRecentBlogs() async {
    try {
      final response = await _apiClient.get(
        '/blogs',
        queryParameters: {'page': 1, 'limit': 5, 'status': 'PUBLISHED'},
      );

      final List<dynamic> items = response.data['items'] ?? [];
      return items.map((e) => BlogModel.fromJson(e)).toList();
    } catch (e) {
      print("Error loading blogs: $e");
      return [];
    }
  }
}
