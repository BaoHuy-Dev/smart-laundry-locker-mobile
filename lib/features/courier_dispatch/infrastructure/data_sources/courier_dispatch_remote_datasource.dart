import 'package:smart_laundry_locker/features/courier_dispatch/infrastructure/models/responses.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/infrastructure/models/update_courier_location_dto.dart';
import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';

abstract class CourierDispatchRemoteDataSource {
  Future<UpdateCourierLocationResponse> updateLocation(
    UpdateCourierLocationDto dto,
  );
  Future<RemoveCourierAvailabilityResponse> removeAvailability();
  Future<FindNearestCouriersResponse> findNearestCouriers({
    required double latitude,
    required double longitude,
    double maxDistanceKm = 10,
    int limit = 10,
  });
  Future<List<Map<String, dynamic>>> getPendingDispatches();
  Future<Map<String, dynamic>> getCourierActiveDelivery();
}

class CourierDispatchRemoteDataSourceImpl
    implements CourierDispatchRemoteDataSource {
  final Dio _dio;

  CourierDispatchRemoteDataSourceImpl({Dio? dio})
    : _dio = dio ?? DioClient.instance.dio;

  Map<String, dynamic> _extractData(Response<dynamic> response) {
    if (response.data is! Map<String, dynamic>) return {};
    final responseData = response.data as Map<String, dynamic>;
    return responseData['data'] as Map<String, dynamic>? ?? responseData;
  }

  List<Map<String, dynamic>> _extractListData(Response<dynamic> response) {
    var data = response.data;
    if (data is Map<String, dynamic> && data.containsKey('data')) {
      data = data['data'];
    }

    if (data is Map<String, dynamic> && data.containsKey('dispatches')) {
      data = data['dispatches'];
    }

    if (data is List) {
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  @override
  Future<UpdateCourierLocationResponse> updateLocation(
    UpdateCourierLocationDto dto,
  ) async {
    final response = await _dio.post(
      '/dispatch/courier/location',
      data: dto.toJson(),
    );
    return UpdateCourierLocationResponse.fromJson(_extractData(response));
  }

  @override
  Future<RemoveCourierAvailabilityResponse> removeAvailability() async {
    final response = await _dio.delete('/dispatch/courier/location');
    return RemoveCourierAvailabilityResponse.fromJson(_extractData(response));
  }

  @override
  Future<FindNearestCouriersResponse> findNearestCouriers({
    required double latitude,
    required double longitude,
    double maxDistanceKm = 10,
    int limit = 10,
  }) async {
    final response = await _dio.get(
      '/dispatch/couriers/nearest',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'maxDistanceKm': maxDistanceKm,
        'limit': limit,
      },
    );
    return FindNearestCouriersResponse.fromJson(_extractData(response));
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingDispatches() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/dispatch/courier/pending',
    );
    return _extractListData(response);
  }

  @override
  Future<Map<String, dynamic>> getCourierActiveDelivery() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/orders/courier/active',
    );
    return _extractData(response);
  }
}
