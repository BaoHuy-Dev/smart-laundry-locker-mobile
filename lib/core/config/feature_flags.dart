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
  /// Backend chưa có wallet service → `GET /wallet/balance` trả 404.
  static const bool walletEnabled = false;

  /// Nạp tiền + lịch sử giao dịch (phụ thuộc ví).
  /// `GET /payments/transactions` chưa tồn tại (PaymentController chỉ có
  /// `/api/payments`), và số dư không được cộng sau topup.
  static const bool transactionsEnabled = false;

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
}
