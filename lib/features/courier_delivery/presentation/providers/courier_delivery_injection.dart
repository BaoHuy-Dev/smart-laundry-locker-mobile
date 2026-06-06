import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/verify_courier_code_use_case.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/accept_order_use_case.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/cancel_dispatch_use_case.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/reject_order_use_case.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/deposit_confirm_locker_use_case.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/deposit_open_locker_use_case.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/pickup_package_use_case.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/confirm_pickup_use_case.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/get_active_delivery_use_case.dart';
import 'package:smart_laundry_locker/features/courier_delivery/application/use_cases/courier_cancel_order_use_case.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/data_sources/courier_delivery_remote_datasource.dart';
import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/repositories/courier_delivery_repository_impl.dart';
import 'package:smart_laundry_locker/features/orders/presentation/providers/order_injection.dart';
import 'package:smart_laundry_locker/features/courier_delivery/presentation/providers/courier_delivery_provider.dart';

class CourierDeliveryInjection {
  static CourierDeliveryProvider provideCourierDeliveryProvider() {
    final apiClient = ApiClient();
    final dataSource = CourierDeliveryRemoteDataSourceImpl();
    final repository = CourierDeliveryRepositoryImpl(
      remoteDataSource: dataSource,
    );

    final acceptOrderUseCase = AcceptOrderUseCase(repository);
    final verifyCourierCodeUseCase = VerifyCourierCodeUseCase(repository);
    final cancelDispatchUseCase = CancelDispatchUseCase(repository);
    final rejectOrderUseCase = RejectOrderUseCase(repository);
    final depositOpenLockerUseCase = DepositOpenLockerUseCase(repository);
    final depositConfirmLockerUseCase = DepositConfirmLockerUseCase(repository);
    final pickupPackageUseCase = PickupPackageUseCase(repository);
    final confirmPickupUseCase = ConfirmPickupUseCase(repository);
    final getActiveDeliveryUseCase = GetActiveDeliveryUseCase(repository);

    final orderRepository = OrderInjection.provideOrderRepository(apiClient);
    final courierCancelOrderUseCase = CourierCancelOrderUseCase(
      orderRepository,
    );

    return CourierDeliveryProvider(
      acceptOrderUseCase: acceptOrderUseCase,
      verifyCourierCodeUseCase: verifyCourierCodeUseCase,
      cancelDispatchUseCase: cancelDispatchUseCase,
      rejectOrderUseCase: rejectOrderUseCase,
      depositOpenLockerUseCase: depositOpenLockerUseCase,
      depositConfirmLockerUseCase: depositConfirmLockerUseCase,
      pickupPackageUseCase: pickupPackageUseCase,
      confirmPickupUseCase: confirmPickupUseCase,
      getActiveDeliveryUseCase: getActiveDeliveryUseCase,
      courierCancelOrderUseCase: courierCancelOrderUseCase,
    );
  }
}
