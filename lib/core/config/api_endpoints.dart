/// Centralized API endpoint paths — replaces config/api.config.ts
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String phoneLogin = '/auth/phone-login';
  static const String completeRegistration = '/auth/complete-registration';
  static const String emailSendOtp = '/auth/email/send-otp';
  static const String emailVerifyOtp = '/auth/email/verify-otp';
  static const String emailCompleteRegistration =
      '/auth/email/complete-registration';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Orders
  static const String orders = '/orders';
  static const String myOrders = '/orders/my-orders';
  static String orderById(int id) => '/orders/$id';
  static String orderByPin(String pin) => '/orders/pin/$pin';
  static String orderByCode(String code) => '/orders/code/$code';
  static String confirmOrder(int id) => '/orders/$id/confirm';
  static String checkoutOrder(int id) => '/orders/$id/checkout';
  static String cancelOrder(int id) => '/orders/$id/cancel';
  static String collectOrder(int id) => '/orders/$id/collect';
  static String processOrder(int id) => '/orders/$id/process';
  static String readyOrder(int id) => '/orders/$id/ready';
  static String returnOrder(int id, int boxId) =>
      '/orders/$id/return?boxId=$boxId';
  static String orderStatus(int id) => '/orders/$id/status';
  static String orderTimeline(int id) => '/orders/$id/timeline';
  static String applyPromotion(int id, String code) =>
      '/orders/$id/promotion?code=$code';
  static String removePromotion(int id) => '/orders/$id/promotion';
  static String completeOrder(int id) => '/orders/$id/complete';
  static String pickupStorage(int id) => '/orders/$id/pickup-storage';
  static String resetPin(int id) => '/orders/$id/reset-pin';
  static String rateOrder(int id) => '/orders/$id/rate';
  static String orderRating(int id) => '/orders/$id/rating';
  static const String myRatings = '/orders/my-ratings';
  static String orderComplaint(int id) => '/orders/$id/complaint';
  static String orderComplaints(int id) => '/orders/$id/complaints';
  static const String myComplaints = '/orders/my-complaints';
  static String reorder(int id) => '/orders/$id/reorder';

  // Stores
  static const String stores = '/stores';
  static String storeById(int id) => '/stores/$id';
  static String nearbyStores({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
    int limit = 20,
  }) =>
      '/stores/nearby?latitude=$latitude&longitude=$longitude&radiusMeters=$radiusMeters&limit=$limit';
  static String storeRatings(int id) => '/stores/$id/ratings';

  // Lockers
  static const String lockers = '/lockers';
  static String lockerById(int id) => '/lockers/$id';
  static String lockerBoxes(int id) => '/lockers/$id/boxes';
  static String availableLockerBoxes(int id) => '/lockers/$id/boxes/available';
  static String reportLocker(int id) => '/lockers/$id/report';
  static const String myLockerReports = '/lockers/my-reports';

  // Services
  static const String services = '/services';
  static String serviceById(int id) => '/services/$id';

  // Payments
  static const String payments = '/payments';
  static const String createPayment = '/payments/create';
  static String paymentById(int id) => '/payments/$id';
  static String paymentsByOrder(int orderId) => '/payments/order/$orderId';
  static String paymentRefund(int paymentId) => '/payments/$paymentId/refund';
  static String refundStatus(int refundId) => '/payments/refunds/$refundId';
  static String orderRefunds(int orderId) =>
      '/payments/orders/$orderId/refunds';

  // Notifications
  static const String notifications = '/notifications';
  static const String allNotifications = '/notifications/all';
  static const String unreadNotifications = '/notifications/unread';
  static const String unreadNotificationCount = '/notifications/unread/count';
  static String notificationRead(int id) => '/notifications/$id/read';
  static const String notificationsReadAll = '/notifications/read-all';
  static const String notificationsReadBatch = '/notifications/read/batch';
  static String notificationById(int id) => '/notifications/$id';
  static const String notificationsAll = '/notifications/all';

  // Users
  static const String userProfile = '/user/profile';
  static const String userAvatar = '/user/avatar';
  static const String userPassword = '/user/password';
  static const String userFcmToken = '/user/fcm-token';
  static const String userStatistics = '/user/me/statistics';

  // Promotions
  static const String promotions = '/promotions';
  static String promotionValidate(String code) =>
      '/promotions/validate/${code.toUpperCase()}';
  static const String activePromotions = '/promotions/active';

  // Loyalty
  static const String loyalty = '/loyalty';
  static const String loyaltySummary = '/loyalty/summary';
  static const String loyaltyPoints = '/loyalty/points';
  static const String loyaltyPointsHistory = '/loyalty/points/history';
  static const String loyaltyStamps = '/loyalty/stamps';
  static const String loyaltyRewards = '/loyalty/rewards';
  static String redeemReward(int rewardId) =>
      '/loyalty/rewards/$rewardId/redeem';
  static const String loyaltyExpiringPoints = '/loyalty/points/expiring';
  static const String redeemPoints = '/loyalty/redeem-points';
  static const String redeemStamp = '/loyalty/redeem-stamp';

  // Partner
  static const String partnerDashboard = '/partner/dashboard';
  static const String partnerProfile = '/partner';
  static const String partnerOrders = '/partner/orders';
  static const String partnerOrderStatistics = '/partner/orders/statistics';
  static const String partnerStores = '/partner/stores';
  static const String staffOrders = '/staff/orders';
}
