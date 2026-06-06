import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/locker/presentation/providers/locker_injection.dart';
import 'package:smart_laundry_locker/features/orders/application/use_cases/get_courier_me_use_case.dart';
import 'package:smart_laundry_locker/features/orders/application/use_cases/get_courier_today_stats_use_case.dart';
import 'package:smart_laundry_locker/features/orders/infrastructure/data_sources/order_remote_data_source_impl.dart';
import 'package:smart_laundry_locker/features/orders/infrastructure/repositories/order_repository_impl.dart';
import 'package:smart_laundry_locker/features/orders/presentation/providers/courier_orders_provider.dart';

class CourierOrdersInjection {
  static CourierOrdersProvider provideProvider(ApiClient apiClient) {
    final orderDs = OrderRemoteDataSourceImpl(apiClient);
    final lockerRepo = LockerInjection.provideRepository(apiClient);
    final orderRepo = OrderRepositoryImpl(orderDs, lockerRepo);

    return CourierOrdersProvider(
      getCourierMeUseCase: GetCourierMeUseCase(orderRepo),
      getStatsUseCase: GetCourierTodayStatsUseCase(orderRepo),
    );
  }
}
