import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner.freezed.dart';
part 'partner.g.dart';

@freezed
abstract class PartnerDashboard with _$PartnerDashboard {
  const factory PartnerDashboard({
    required int partnerId,
    required String businessName,
    required int totalStores,
    required int activeStores,
    required int totalStaff,
    required int totalOrders,
    required int pendingOrders,
    required int completedOrders,
    required int canceledOrders,
    required double totalRevenue,
    required double partnerRevenue,
    required double platformFee,
    required double todayRevenue,
    required double monthRevenue,
  }) = _PartnerDashboard;

  factory PartnerDashboard.fromJson(Map<String, dynamic> json) =>
      _$PartnerDashboardFromJson(json);
}

@freezed
abstract class PartnerProfile with _$PartnerProfile {
  const factory PartnerProfile({
    required int id,
    required String businessName,
    String? businessRegistrationNumber,
    String? taxId,
    required String businessAddress,
    required String contactPhone,
    String? contactEmail,
    Map<String, dynamic>? user,
    required String status,
    String? approvedAt,
    int? approvedBy,
    String? rejectionReason,
    required double revenueSharePercent,
    required int storeCount,
    required int staffCount,
    required String notes,
    required String createdAt,
    required String updatedAt,
  }) = _PartnerProfile;

  factory PartnerProfile.fromJson(Map<String, dynamic> json) =>
      _$PartnerProfileFromJson(json);
}

@freezed
abstract class PartnerOrderStatistics with _$PartnerOrderStatistics {
  const factory PartnerOrderStatistics({
    required int partnerId,
    required int totalOrders,
    required int todayOrders,
    required int weekOrders,
    required int monthOrders,
    required int initializedOrders,
    required int waitingOrders,
    required int collectedOrders,
    required int processingOrders,
    required int readyOrders,
    required int returnedOrders,
    required int completedOrders,
    required int canceledOrders,
    required double totalRevenue,
    required double todayRevenue,
    required double weekRevenue,
    required double monthRevenue,
    required double averageOrderValue,
    required Map<String, int> ordersByStore,
  }) = _PartnerOrderStatistics;

  factory PartnerOrderStatistics.fromJson(Map<String, dynamic> json) =>
      _$PartnerOrderStatisticsFromJson(json);
}

@freezed
abstract class StaffOrderSummary with _$StaffOrderSummary {
  const factory StaffOrderSummary({
    required int waitingCount,
    required int processingCount,
    required int readyCount,
    required int collectedCount,
    required List<dynamic> recentOrders,
  }) = _StaffOrderSummary;

  factory StaffOrderSummary.fromJson(Map<String, dynamic> json) =>
      _$StaffOrderSummaryFromJson(json);
}
