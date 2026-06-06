// Removed unused import
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/application/use_cases/get_pending_dispatches_use_case.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/application/use_cases/get_courier_active_delivery_use_case.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/application/use_cases/remove_courier_availability_use_case.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/application/use_cases/update_courier_location_use_case.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/infrastructure/data_sources/courier_dispatch_remote_datasource.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/infrastructure/repositories/courier_dispatch_repository_impl.dart';
import 'package:smart_laundry_locker/features/locker/presentation/providers/locker_injection.dart';
import 'package:smart_laundry_locker/features/orders/application/use_cases/get_courier_order_history_use_case.dart';
import 'package:smart_laundry_locker/features/orders/application/use_cases/get_courier_today_stats_use_case.dart';
import 'package:smart_laundry_locker/features/orders/infrastructure/data_sources/order_remote_data_source_impl.dart';
import 'package:smart_laundry_locker/features/orders/infrastructure/repositories/order_repository_impl.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/presentation/providers/courier_dispatch_provider.dart';

class CourierDispatchInjection {
  static CourierDispatchProvider provideCourierDispatchProvider() {
    final dataSource = CourierDispatchRemoteDataSourceImpl();
    final repository = CourierDispatchRepositoryImpl(
      remoteDataSource: dataSource,
    );

    final updateLocationUseCase = UpdateCourierLocationUseCase(repository);
    final removeAvailabilityUseCase = RemoveCourierAvailabilityUseCase(
      repository,
    );
    final apiClient = ApiClient();
    final orderDataSource = OrderRemoteDataSourceImpl(apiClient);
    final lockerRepository = LockerInjection.provideRepository(apiClient);
    final orderRepository = OrderRepositoryImpl(
      orderDataSource,
      lockerRepository,
    );
    final getCourierTodayStatsUseCase = GetCourierTodayStatsUseCase(
      orderRepository,
    );
    final getCourierOrderHistoryUseCase = GetCourierOrderHistoryUseCase(
      orderRepository,
    );

    final getPendingDispatchesUseCase = GetPendingDispatchesUseCase(repository);
    final getCourierActiveDeliveryUseCase = GetCourierActiveDeliveryUseCase(
      repository,
    );

    return CourierDispatchProvider(
      updateLocationUseCase: updateLocationUseCase,
      removeAvailabilityUseCase: removeAvailabilityUseCase,
      getCourierTodayStatsUseCase: getCourierTodayStatsUseCase,
      getCourierOrderHistoryUseCase: getCourierOrderHistoryUseCase,
      getPendingDispatchesUseCase: getPendingDispatchesUseCase,
      getCourierActiveDeliveryUseCase: getCourierActiveDeliveryUseCase,
    );
  }
}
