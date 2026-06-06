import 'package:smart_laundry_locker/features/courier_dispatch/domain/entities/courier_active_delivery.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/domain/entities/courier_nearest_search.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/domain/entities/pending_dispatch.dart';

abstract class CourierDispatchRepository {
  Future<void> updateLocation(double latitude, double longitude);

  Future<void> removeAvailability();

  Future<List<CourierNearestSearch>> findNearestCouriers(
    double latitude,
    double longitude, {
    double maxDistanceKm = 10,
    int limit = 10,
  });

  Future<List<PendingDispatch>> getPendingDispatches();

  Future<CourierActiveDelivery> getCourierActiveDelivery();
}
