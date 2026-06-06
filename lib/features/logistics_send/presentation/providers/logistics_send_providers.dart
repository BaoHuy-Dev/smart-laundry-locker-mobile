import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/logistics_send/application/use_cases/get_logistics_success_use_case.dart';
import 'package:smart_laundry_locker/features/logistics_send/application/use_cases/send_package_use_case.dart';
import 'package:smart_laundry_locker/features/logistics_send/application/use_cases/get_dispatch_status_use_case.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/entities/logistics_success_entity.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/params/logistics_success_load_params.dart';
import 'package:smart_laundry_locker/features/logistics_send/infrastructure/data_sources/logistics_send_remote_datasource.dart';
import 'package:smart_laundry_locker/features/logistics_send/infrastructure/repositories/logistics_send_repository_impl.dart';
import 'package:smart_laundry_locker/features/locker/presentation/providers/locker_injection.dart';
import 'package:smart_laundry_locker/features/orders/application/use_cases/get_order_detail_use_case.dart';
import 'package:smart_laundry_locker/features/orders/infrastructure/data_sources/order_remote_data_source_impl.dart';
import 'package:smart_laundry_locker/features/orders/infrastructure/repositories/order_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final logisticsSendUseCaseProvider = Provider<SendPackageUseCase>((ref) {
  final remoteDataSource = LogisticsSendRemoteDataSourceImpl();
  final repository = LogisticsSendRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
  return SendPackageUseCase(repository);
});

final getDispatchStatusUseCaseProvider = Provider<GetDispatchStatusUseCase>((
  ref,
) {
  final remoteDataSource = LogisticsSendRemoteDataSourceImpl();
  final repository = LogisticsSendRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
  return GetDispatchStatusUseCase(repository);
});

final _getOrderDetailUseCaseProvider = Provider<GetOrderDetailUseCase>((ref) {
  final api = ApiClient();
  final orderDs = OrderRemoteDataSourceImpl(api);
  final lockerRepo = LockerInjection.provideRepository(api);
  final orderRepo = OrderRepositoryImpl(orderDs, lockerRepo);
  return GetOrderDetailUseCase(orderRepo);
});

final getLogisticsSuccessUseCaseProvider = Provider<GetLogisticsSuccessUseCase>(
  (ref) {
    final getDetail = ref.watch(_getOrderDetailUseCaseProvider);
    return GetLogisticsSuccessUseCase(getDetail);
  },
);

final logisticsSuccessEntityProvider = FutureProvider.autoDispose
    .family<LogisticsSuccessEntity, LogisticsSuccessLoadParams>((
      ref,
      params,
    ) async {
      final useCase = ref.watch(getLogisticsSuccessUseCaseProvider);
      final result = await useCase(params);
      return result.fold((f) => throw Exception(f.message), (e) => e);
    });
