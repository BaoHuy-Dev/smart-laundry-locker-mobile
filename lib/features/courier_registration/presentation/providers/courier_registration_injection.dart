import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/courier_registration/application/use_cases/submit_courier_application_use_case.dart';
import 'package:smart_laundry_locker/features/courier_registration/application/use_cases/check_courier_status_use_case.dart';
import 'package:smart_laundry_locker/features/courier_registration/infrastructure/data_sources/courier_registration_remote_data_source_impl.dart';
import 'package:smart_laundry_locker/features/courier_registration/infrastructure/repositories/courier_registration_repository_impl.dart';
import 'package:smart_laundry_locker/features/courier_registration/presentation/providers/courier_registration_provider.dart';

class CourierRegistrationInjection {
  static CourierRegistrationProvider provideProvider(ApiClient apiClient) {
    final remoteDataSource = CourierRegistrationRemoteDataSourceImpl(apiClient);
    final repository = CourierRegistrationRepositoryImpl(apiClient: apiClient);
    final submitUseCase = SubmitCourierApplicationUseCase(repository);
    final checkStatusUseCase = CheckCourierStatusUseCase(repository);

    return CourierRegistrationProvider(
      submitUseCase: submitUseCase,
      checkStatusUseCase: checkStatusUseCase,
    );
  }
}
