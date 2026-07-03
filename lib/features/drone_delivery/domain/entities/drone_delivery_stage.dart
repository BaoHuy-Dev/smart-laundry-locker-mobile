import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// 6 mốc trạng thái giao hàng bằng drone mà backend bắn xuống qua FCM
/// (`type` = drone_dispatched … drone_failed, `data.status` = tên mốc).
///
/// `unknown` để phòng khi nhận status lạ (không làm vỡ UI). Feature này tự sở
/// hữu enum riêng để giữ 4 layer độc lập — không phụ thuộc domain của feature
/// `notifications` (nơi có `DeliveryStatus` tương tự cho luồng noti chung).
enum DroneDeliveryStage {
  dispatched,
  approaching,
  arrived,
  delivered,
  delayed,
  failed,
  unknown;

  /// Chuyển chuỗi `status` trong payload FCM thành enum (không phân biệt hoa
  /// thường). Status lạ → [unknown].
  static DroneDeliveryStage fromRaw(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'dispatched':
        return DroneDeliveryStage.dispatched;
      case 'approaching':
        return DroneDeliveryStage.approaching;
      case 'arrived':
        return DroneDeliveryStage.arrived;
      case 'delivered':
        return DroneDeliveryStage.delivered;
      case 'delayed':
        return DroneDeliveryStage.delayed;
      case 'failed':
        return DroneDeliveryStage.failed;
      default:
        return DroneDeliveryStage.unknown;
    }
  }

  /// 4 mốc chính vẽ trên timeline theo đúng thứ tự tiến trình. `delayed`,
  /// `failed`, `unknown` là trạng thái phủ lên timeline chứ không phải một bước.
  static const List<DroneDeliveryStage> timeline = [
    DroneDeliveryStage.dispatched,
    DroneDeliveryStage.approaching,
    DroneDeliveryStage.arrived,
    DroneDeliveryStage.delivered,
  ];

  /// Vị trí trên timeline (0..3). Trả `-1` với mốc không nằm trên timeline.
  int get order => timeline.indexOf(this);

  /// Đơn đã kết thúc (thành công hoặc thất bại) — không còn tiến triển tiếp.
  bool get isTerminal =>
      this == DroneDeliveryStage.delivered || this == DroneDeliveryStage.failed;

  /// Nhánh lỗi/chậm để UI đổi màu cảnh báo.
  bool get isFailure => this == DroneDeliveryStage.failed;
  bool get isDelayed => this == DroneDeliveryStage.delayed;

  /// Tiêu đề mặc định (tiếng Việt) khi payload không gửi kèm title.
  String get title {
    switch (this) {
      case DroneDeliveryStage.dispatched:
        return 'Drone đang giao hàng';
      case DroneDeliveryStage.approaching:
        return 'Drone sắp đến';
      case DroneDeliveryStage.arrived:
        return 'Drone đã đến nơi';
      case DroneDeliveryStage.delivered:
        return 'Giao hàng thành công';
      case DroneDeliveryStage.delayed:
        return 'Đơn hàng bị chậm';
      case DroneDeliveryStage.failed:
        return 'Giao hàng không thành công';
      case DroneDeliveryStage.unknown:
        return 'Cập nhật đơn hàng';
    }
  }

  /// Nội dung gợi ý (tiếng Việt) theo contract, dùng khi payload không gửi kèm
  /// `content`. [eta] chỉ chèn vào mốc `delayed`.
  String body(String? eta) {
    switch (this) {
      case DroneDeliveryStage.dispatched:
        return 'Drone đang trên đường giao hàng của bạn';
      case DroneDeliveryStage.approaching:
        return 'Drone sắp đến nơi, vui lòng chuẩn bị ra nhận';
      case DroneDeliveryStage.arrived:
        return 'Drone đã đến điểm giao, vui lòng ra nhận hàng';
      case DroneDeliveryStage.delivered:
        return 'Giao hàng thành công. Cảm ơn bạn!';
      case DroneDeliveryStage.delayed:
        return (eta != null && eta.isNotEmpty)
            ? 'Đơn đang bị chậm, dự kiến tới $eta'
            : 'Đơn đang bị chậm so với dự kiến';
      case DroneDeliveryStage.failed:
        return 'Giao không thành công, drone đang quay về';
      case DroneDeliveryStage.unknown:
        return 'Đơn hàng của bạn có cập nhật mới';
    }
  }

  /// Icon hiển thị trên timeline/banner (lucide theo icon convention).
  IconData get icon {
    switch (this) {
      case DroneDeliveryStage.dispatched:
        return LucideIcons.planeTakeoff;
      case DroneDeliveryStage.approaching:
        return LucideIcons.navigation;
      case DroneDeliveryStage.arrived:
        return LucideIcons.mapPin;
      case DroneDeliveryStage.delivered:
        return LucideIcons.circleCheck;
      case DroneDeliveryStage.delayed:
        return LucideIcons.clock;
      case DroneDeliveryStage.failed:
        return LucideIcons.circleAlert;
      case DroneDeliveryStage.unknown:
        return LucideIcons.package;
    }
  }

  /// Màu theo trạng thái — GIỮ semantic: success=green, delayed=amber, failed=red.
  /// Các mốc đang tiến hành dùng navy palette.
  Color get color {
    switch (this) {
      case DroneDeliveryStage.dispatched:
        return const Color(0xFF1E5A8A); // navyAccent
      case DroneDeliveryStage.approaching:
        return const Color(0xFF1E5A8A); // navyAccent
      case DroneDeliveryStage.arrived:
        return const Color(0xFF12355B); // navySecondary
      case DroneDeliveryStage.delivered:
        return const Color(0xFF16A34A); // success green
      case DroneDeliveryStage.delayed:
        return const Color(0xFFF59E0B); // warning amber
      case DroneDeliveryStage.failed:
        return const Color(0xFFDC2626); // destructive red
      case DroneDeliveryStage.unknown:
        return const Color(0xFF64748B); // neutral gray
    }
  }
}
