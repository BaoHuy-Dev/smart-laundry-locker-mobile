import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:smart_laundry_locker/core/constants/app_colors.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/courier_registration/presentation/providers/courier_registration_injection.dart';
import 'package:smart_laundry_locker/features/courier_registration/presentation/providers/courier_registration_provider.dart';
import 'package:smart_laundry_locker/features/courier_registration/presentation/pages/courier_registration_page.dart';
import 'package:smart_laundry_locker/features/courier_registration/domain/entities/courier_application_entity.dart';

// màn hình hiển thị trạng thái đơn đăng ký
class CourierRegistrationStatusPage extends StatefulWidget {
  final String userId;

  const CourierRegistrationStatusPage({super.key, required this.userId});

  @override
  State<CourierRegistrationStatusPage> createState() =>
      _CourierRegistrationStatusPageState();
}

class _CourierRegistrationStatusPageState
    extends State<CourierRegistrationStatusPage> {
  late CourierRegistrationProvider _provider;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    _provider = CourierRegistrationInjection.provideProvider(apiClient);
    // check status khi init
    _provider.checkStatus(userId: widget.userId);
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  void _handleRetry() {
    _provider.reset();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const CourierRegistrationPage()),
    );
  }

  void _handleRefresh() {
    _provider.refreshStatus(userId: widget.userId);
  }

  void _handleStartWork() {
    // đến dashboard tài xế
    SmartDialog.showToast('Tính năng Courier Dashboard đang được phát triển');
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Đăng ký Tài xế'),
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.onBackground,
          elevation: 0,
        ),
        body: Consumer<CourierRegistrationProvider>(
          builder: (context, provider, child) {
            if (provider.isCheckingStatus) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.success),
                ),
              );
            }

            // Error state
            if (provider.error != null && provider.currentApplication == null) {
              return _buildErrorState(provider.error!);
            }

            final application = provider.currentApplication;

            if (application == null) {
              return _buildNotRegisteredState();
            }

            // switch case theo status
            switch (application.status) {
              case 'PENDING':
                return _buildPendingState(application);
              case 'REJECTED':
                return _buildRejectedState(application);
              case 'APPROVED':
                return _buildApprovedState(application);
              default:
                return _buildUnknownState(application.status);
            }
          },
        ),
      ),
    );
  }

  // not registered state: hiển thị form đăng ký
  Widget _buildNotRegisteredState() {
    return const CourierRegistrationPage();
  }

  // PENDING: chờ duyệt
  Widget _buildPendingState(CourierApplicationEntity application) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_empty,
                size: 64,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 32),
            // Title
            const Text(
              'Hồ sơ đang chờ duyệt',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Message
            const Text(
              'Vui lòng chờ Admin kiểm tra hồ sơ của bạn.\nChúng tôi sẽ thông báo khi có kết quả.',
              style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Application Info
            _buildApplicationInfo(application),
            const SizedBox(height: 32),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _handleRefresh,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Làm mới trạng thái'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.onBackground,
                    side: const BorderSide(color: AppColors.outlineVariant),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.home),
                  label: const Text('Về trang chủ'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // rejected state: bị từ chối
  Widget _buildRejectedState(CourierApplicationEntity application) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 64,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 32),
            // Title
            const Text(
              'Hồ sơ bị từ chối',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Review Note
            if (application.reviewNote != null &&
                application.reviewNote!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lý do từ chối:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      application.reviewNote!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            // Message
            Text(
              application.rejectionCount > 0
                  ? 'Số lần bị từ chối: ${application.rejectionCount}'
                  : 'Vui lòng kiểm tra lại thông tin và gửi lại hồ sơ.',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Application Info
            _buildApplicationInfo(application),
            const SizedBox(height: 32),
            // Action
            ElevatedButton.icon(
              onPressed: _handleRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Gửi lại hồ sơ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // approved state: đã được duyệt
  Widget _buildApprovedState(CourierApplicationEntity application) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 64,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 32),
            // Title
            const Text(
              'Đăng ký thành công!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Message
            const Text(
              'Hồ sơ của bạn đã được duyệt.\nBạn có thể bắt đầu làm việc ngay bây giờ!',
              style: TextStyle(fontSize: 16, color: AppColors.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Application Info
            _buildApplicationInfo(application),
            const SizedBox(height: 32),
            // Action
            ElevatedButton.icon(
              onPressed: _handleStartWork,
              icon: const Icon(Icons.work),
              label: const Text('Bắt đầu làm việc'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnknownState(String status) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.help_outline,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Trạng thái không xác định: $status',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Error state
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              error,
              style: const TextStyle(fontSize: 16, color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleRefresh,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  // Application Info Card
  Widget _buildApplicationInfo(CourierApplicationEntity application) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin đơn đăng ký',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Họ và tên', application.legalName),
          const SizedBox(height: 8),
          _buildInfoRow('Biển số xe', application.licensePlate),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Loại xe',
            _getVehicleTypeLabel(application.vehicleType),
          ),
          if (application.reviewedAt != null) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Ngày xử lý', _formatDate(application.reviewedAt!)),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.onBackground,
            ),
          ),
        ),
      ],
    );
  }

  String _getVehicleTypeLabel(String vehicleType) {
    switch (vehicleType) {
      case 'BIKE':
        return 'Xe đạp';
      case 'MOTORBIKE':
        return 'Xe máy';
      case 'CAR':
        return 'Ô tô';
      default:
        return vehicleType;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
