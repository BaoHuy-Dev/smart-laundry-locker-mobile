import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_laundry_locker/core/services/firebase_messaging_service.dart';
import 'package:smart_laundry_locker/features/drone_delivery/application/use_cases/get_drone_delivery_status_use_case.dart';
import 'package:smart_laundry_locker/features/drone_delivery/domain/entities/drone_delivery_status.dart';
import 'package:smart_laundry_locker/features/drone_delivery/infrastructure/repositories/drone_delivery_repository_impl.dart';

/// DI Riverpod cho luồng theo dõi giao drone (mirror `logistics_send_providers`).
final getDroneDeliveryStatusUseCaseProvider =
    Provider<GetDroneDeliveryStatusUseCase>((ref) {
      final repository = DroneDeliveryRepositoryImpl();
      return GetDroneDeliveryStatusUseCase(repository);
    });

/// Lắng nghe FCM stream, CHỈ giữ lại các event `drone_*` khớp [orderId] và phát
/// một tick tăng dần. Tách riêng để `droneDeliveryStatusProvider` `watch` và tự
/// refetch mỗi khi có mốc mới — mirror cách `NotificationProvider` nghe stream
/// rồi refetch.
final droneDeliveryFcmTickProvider = StreamProvider.autoDispose
    .family<int, String>((ref, orderId) {
      var tick = 0;
      return FirebaseMessagingService.instance.onMessageReceived
          .where(
            (message) =>
                message.data['orderId']?.toString() == orderId &&
                FirebaseMessagingService.droneDeliveryTypes.contains(
                  message.data['type'],
                ),
          )
          .map((_) => ++tick);
    });

/// Trạng thái giao drone hiện tại theo [orderId].
///
/// Tự fetch lần đầu khi mở trang; và tự refetch mỗi khi [droneDeliveryFcmTickProvider]
/// phát mốc mới cho đúng đơn này. Pull-to-refresh: `ref.invalidate(...)`.
final droneDeliveryStatusProvider = FutureProvider.autoDispose
    .family<DroneDeliveryStatus, String>((ref, orderId) async {
      // Đăng ký phụ thuộc vào FCM tick → có event drone mới thì provider chạy lại.
      ref.watch(droneDeliveryFcmTickProvider(orderId));

      final useCase = ref.watch(getDroneDeliveryStatusUseCaseProvider);
      final result = await useCase.execute(orderId);
      return result.fold((failure) => throw Exception(failure.message), (e) => e);
    });
