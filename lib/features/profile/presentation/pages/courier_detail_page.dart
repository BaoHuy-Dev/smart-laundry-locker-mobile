import 'package:smart_laundry_locker/core/constants/app_colors.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/profile/presentation/providers/profile_injection.dart';
import 'package:smart_laundry_locker/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CourierDetailPage extends StatefulWidget {
  const CourierDetailPage({super.key, this.userId});

  final String? userId;

  @override
  State<CourierDetailPage> createState() => _CourierDetailPageState();
}

class _CourierDetailPageState extends State<CourierDetailPage> {
  late ProfileProvider _profileProvider;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    _profileProvider = ProfileInjection.provideProfileProvider(apiClient);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = widget.userId;
      if (userId != null && userId.isNotEmpty) {
        _profileProvider.loadCourierProfile(userId);
      }
    });
  }

  @override
  void dispose() {
    _profileProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _profileProvider,
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onBackground),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Thông tin phương tiện',
            style: TextStyle(
              color: AppColors.onBackground,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Consumer<ProfileProvider>(
            builder: (context, provider, child) {
              if (provider.isCourierLoading &&
                  provider.courierProfile == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (provider.courierError != null &&
                  provider.courierProfile == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        provider.courierError!,
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          final userId = widget.userId;
                          if (userId != null && userId.isNotEmpty) {
                            provider.loadCourierProfile(userId);
                          }
                        },
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              final courier = provider.courierProfile;
              if (courier == null) {
                return const Center(child: Text('Không có dữ liệu tài xế'));
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Card thông tin cơ bản
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: AppColors.grey200,
                          width: 1.5,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Icon xe
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.motorcycle_rounded,
                              color: AppColors.primary,
                              size: 34,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Loại xe',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getVehicleTypeLabel(courier.vehicleType),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onBackground,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Biển số',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            courier.licensePlate,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              letterSpacing: 1.2,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildImageWithLabel(
                      context,
                      'Ảnh mặt trước xe',
                      courier.frontVehicleImageUrl,
                    ),

                    const SizedBox(height: 28),

                    _buildImageWithLabel(
                      context,
                      'Ảnh mặt sau xe',
                      courier.backVehicleImageUrl,
                    ),

                    const SizedBox(height: 28),

                    _buildImageWithLabel(
                      context,
                      'Ảnh chân dung tài xế',
                      courier.portraitUrl,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getVehicleTypeLabel(String vehicleType) {
    switch (vehicleType.toUpperCase()) {
      case 'MOTORBIKE':
        return 'Xe máy';
      case 'CAR':
        return 'Ô tô';
      case 'BICYCLE':
        return 'Xe đạp';
      default:
        return vehicleType;
    }
  }

  Widget _buildImageWithLabel(BuildContext context, String label, String? url) {
    final hasImage = url != null && url.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: AppColors.onBackground,
          ),
        ),
        const SizedBox(height: 12),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: hasImage ? () {} : null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: hasImage
                    ? Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.grey200,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.image_not_supported_rounded,
                              color: AppColors.grey500,
                              size: 48,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: AppColors.grey200,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_rounded,
                          color: AppColors.grey500,
                          size: 48,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
