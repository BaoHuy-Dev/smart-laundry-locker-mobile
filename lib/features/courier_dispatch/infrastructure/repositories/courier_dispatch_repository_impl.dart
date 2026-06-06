import 'package:smart_laundry_locker/features/courier_dispatch/domain/entities/courier_active_delivery.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/domain/entities/courier_nearest_search.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/domain/entities/pending_dispatch.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/domain/repositories/courier_dispatch_repository.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/infrastructure/data_sources/courier_dispatch_remote_datasource.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/infrastructure/models/update_courier_location_dto.dart';

class CourierDispatchRepositoryImpl implements CourierDispatchRepository {
  final CourierDispatchRemoteDataSource _remoteDataSource;

  CourierDispatchRepositoryImpl({
    CourierDispatchRemoteDataSource? remoteDataSource,
  }) : _remoteDataSource =
           remoteDataSource ?? CourierDispatchRemoteDataSourceImpl();

  @override
  Future<void> updateLocation(double latitude, double longitude) async {
    final dto = UpdateCourierLocationDto(
      latitude: latitude,
      longitude: longitude,
    );
    final response = await _remoteDataSource.updateLocation(dto);
    if (!response.success) {
      throw Exception(response.message);
    }
  }

  @override
  Future<void> removeAvailability() async {
    final response = await _remoteDataSource.removeAvailability();
    if (!response.success) {
      throw Exception(response.message);
    }
  }

  @override
  Future<List<CourierNearestSearch>> findNearestCouriers(
    double latitude,
    double longitude, {
    double maxDistanceKm = 10,
    int limit = 10,
  }) async {
    final response = await _remoteDataSource.findNearestCouriers(
      latitude: latitude,
      longitude: longitude,
      maxDistanceKm: maxDistanceKm,
      limit: limit,
    );

    return response.couriers
        .map(
          (dto) => CourierNearestSearch(
            courierId: dto.courierId,
            distanceKm: dto.distanceKm,
            estimatedTimeMin: dto.estimatedTimeMin,
            latitude: dto.latitude,
            longitude: dto.longitude,
          ),
        )
        .toList();
  }

  @override
  Future<List<PendingDispatch>> getPendingDispatches() async {
    final rawData = await _remoteDataSource.getPendingDispatches();
    return rawData.map((e) => PendingDispatch.fromJson(e)).toList();
  }

  @override
  Future<CourierActiveDelivery> getCourierActiveDelivery() async {
    final rawData = await _remoteDataSource.getCourierActiveDelivery();
    return CourierActiveDelivery.fromJson(rawData);
  }
}
