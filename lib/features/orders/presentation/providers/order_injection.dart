import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/orders/application/use_cases/get_active_orders_use_case.dart';
import 'package:smart_laundry_locker/features/orders/domain/repositories/order_repository.dart';
import 'package:smart_laundry_locker/features/orders/application/use_cases/get_my_orders_use_case.dart';
import 'package:smart_laundry_locker/features/orders/application/use_cases/get_order_detail_use_case.dart';
import 'package:smart_laundry_locker/features/orders/application/use_cases/get_courier_order_detail_use_case.dart';
import 'package:smart_laundry_locker/features/orders/application/use_cases/pay_overdue_fee_use_case.dart';
import 'package:smart_laundry_locker/features/orders/application/use_cases/recreate_access_code_use_case.dart';
import 'package:smart_laundry_locker/features/locker/presentation/providers/locker_injection.dart';
import 'package:smart_laundry_locker/features/orders/infrastructure/data_sources/order_remote_data_source_impl.dart';
import 'package:smart_laundry_locker/features/orders/infrastructure/repositories/order_repository_impl.dart';
import 'package:smart_laundry_locker/features/orders/presentation/providers/order_provider.dart';
import 'package:smart_laundry_locker/features/logistics_send/application/use_cases/customer_cancel_order_use_case.dart';
import 'package:smart_laundry_locker/features/logistics_send/infrastructure/repositories/logistics_send_repository_impl.dart';

/// Factory class wire các dependency layers cho orders feature
class OrderInjection {
  static OrderProvider provideOrderProvider(ApiClient apiClient) {
    final dataSource = OrderRemoteDataSourceImpl(apiClient);
    final lockerRepository = LockerInjection.provideRepository(apiClient);
    final repository = OrderRepositoryImpl(dataSource, lockerRepository);

    final getMyOrdersUseCase = GetMyOrdersUseCase(repository);
    final getOrderDetailUseCase = GetOrderDetailUseCase(repository);
    final getCourierOrderDetailUseCase = GetCourierOrderDetailUseCase(
      repository,
    );
    final getActiveOrdersUseCase = GetActiveOrdersUseCase(repository);
    final payOverdueFeeUseCase = PayOverdueFeeUseCase(repository);
    final recreateAccessCodeUseCase = RecreateAccessCodeUseCase(repository);

    final logisticsSendRepository = LogisticsSendRepositoryImpl(
      remoteDataSource: null, // Uses default if null
    );
    final customerCancelOrderUseCase = CustomerCancelOrderUseCase(
      logisticsSendRepository,
    );

    return OrderProvider(
      getMyOrdersUseCase: getMyOrdersUseCase,
      getOrderDetailUseCase: getOrderDetailUseCase,
      getCourierOrderDetailUseCase: getCourierOrderDetailUseCase,
      getActiveOrdersUseCase: getActiveOrdersUseCase,
      payOverdueFeeUseCase: payOverdueFeeUseCase,
      recreateAccessCodeUseCase: recreateAccessCodeUseCase,
      customerCancelOrderUseCase: customerCancelOrderUseCase,
    );
  }

  static OrderRepository provideOrderRepository(ApiClient apiClient) {
    final dataSource = OrderRemoteDataSourceImpl(apiClient);
    final lockerRepository = LockerInjection.provideRepository(apiClient);
    return OrderRepositoryImpl(dataSource, lockerRepository);
  }
}
