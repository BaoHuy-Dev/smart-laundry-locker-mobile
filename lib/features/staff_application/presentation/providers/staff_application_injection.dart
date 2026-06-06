import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/staff_application/application/use_cases/get_staff_application_status_use_case.dart';
import 'package:smart_laundry_locker/features/staff_application/application/use_cases/submit_staff_application_use_case.dart';
import 'package:smart_laundry_locker/features/staff_application/infrastructure/data_sources/staff_application_remote_data_source_impl.dart';
import 'package:smart_laundry_locker/features/staff_application/infrastructure/repositories/staff_application_repository_impl.dart';
import 'package:smart_laundry_locker/features/staff_application/presentation/providers/staff_application_provider.dart';

class StaffApplicationInjection {
  static StaffApplicationProvider provideProvider(ApiClient apiClient) {
    final remote = StaffApplicationRemoteDataSourceImpl(apiClient);
    final repository = StaffApplicationRepositoryImpl(remote: remote);
    final submitUseCase = SubmitStaffApplicationUseCase(repository);
    final getStatusUseCase = GetStaffApplicationStatusUseCase(repository);

    return StaffApplicationProvider(
      submitUseCase: submitUseCase,
      getStatusUseCase: getStatusUseCase,
      repository: repository,
    );
  }
}
