/// Cờ bật/tắt tính năng ở mức UI.
///
/// Một số tính năng đang được **tạm ẩn** vì backend hiện chưa có endpoint
/// tương ứng (gọi vào sẽ trả về 404 và làm bẩn log/Network bằng lỗi đỏ, đồng
/// thời hiển thị màn hình rỗng/sai cho người dùng). Khi backend bổ sung
/// service tương ứng, chỉ cần đổi cờ về `true` để bật lại — không cần sửa UI.
///
/// Tham chiếu: `laundry-locker-microservices/docs/BUSINESS_FLOWS_CURRENT.md`.
class FeatureFlags {
  const FeatureFlags._();

  /// Ví / số dư người dùng.
  /// Backend đã có wallet service (`GET /api/wallet`, cộng tiền sau topup VNPay).
  static const bool walletEnabled = true;

  /// Nạp tiền + lịch sử giao dịch (phụ thuộc ví).
  /// Backend: nạp qua `POST /api/payments/topup/create` → cộng ví; lịch sử ví
  /// qua `GET /api/wallet/transactions`.
  static const bool transactionsEnabled = true;

  /// Gói dịch vụ / subscription.
  /// Backend chưa có → `/plans/customer`, `/pricings`, `/subscriptions/*` 404.
  static const bool subscriptionEnabled = false;

  /// Kho voucher cá nhân.
  /// Backend chưa có → `/promotions/vouchers/my` 404.
  /// LƯU Ý: trang "Ưu đãi" (PromotionsPage, `GET /api/promotions/active`) vẫn
  /// hoạt động bình thường và KHÔNG bị ẩn.
  static const bool vouchersEnabled = false;

  /// Quảng cáo + blog ở trang chủ.
  /// Backend chưa có → `/advertisements`, `/blogs` 404.
  static const bool homeContentFeedEnabled = false;

  /// Nhận diện khuôn mặt (đăng ký/đăng nhập bằng khuôn mặt).
  /// Backend chưa có AI service → `/api/auth/ai/registered/{userId}`,
  /// `/api/auth/ai/register`, `/api/auth/ai/verify` trả 500.
  static const bool faceRecognitionEnabled = false;

  /// Theo dõi đơn giao bằng drone cho NGƯỜI NHẬN (Phase 1: chỉ push
  /// notification + timeline, chưa có live map).
  /// Backend chưa có → `GET /api/orders/{orderId}/drone-delivery` 404. Khi tắt,
  /// datasource trả mock để timeline chạy được mà không gọi endpoint chết.
  static const bool droneDeliveryEnabled = false;
}
