// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PartnerDashboard _$PartnerDashboardFromJson(Map<String, dynamic> json) =>
    _PartnerDashboard(
      partnerId: (json['partnerId'] as num).toInt(),
      businessName: json['businessName'] as String,
      totalStores: (json['totalStores'] as num).toInt(),
      activeStores: (json['activeStores'] as num).toInt(),
      totalStaff: (json['totalStaff'] as num).toInt(),
      totalOrders: (json['totalOrders'] as num).toInt(),
      pendingOrders: (json['pendingOrders'] as num).toInt(),
      completedOrders: (json['completedOrders'] as num).toInt(),
      canceledOrders: (json['canceledOrders'] as num).toInt(),
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
      partnerRevenue: (json['partnerRevenue'] as num).toDouble(),
      platformFee: (json['platformFee'] as num).toDouble(),
      todayRevenue: (json['todayRevenue'] as num).toDouble(),
      monthRevenue: (json['monthRevenue'] as num).toDouble(),
    );

Map<String, dynamic> _$PartnerDashboardToJson(_PartnerDashboard instance) =>
    <String, dynamic>{
      'partnerId': instance.partnerId,
      'businessName': instance.businessName,
      'totalStores': instance.totalStores,
      'activeStores': instance.activeStores,
      'totalStaff': instance.totalStaff,
      'totalOrders': instance.totalOrders,
      'pendingOrders': instance.pendingOrders,
      'completedOrders': instance.completedOrders,
      'canceledOrders': instance.canceledOrders,
      'totalRevenue': instance.totalRevenue,
      'partnerRevenue': instance.partnerRevenue,
      'platformFee': instance.platformFee,
      'todayRevenue': instance.todayRevenue,
      'monthRevenue': instance.monthRevenue,
    };

_PartnerProfile _$PartnerProfileFromJson(Map<String, dynamic> json) =>
    _PartnerProfile(
      id: (json['id'] as num).toInt(),
      businessName: json['businessName'] as String,
      businessRegistrationNumber: json['businessRegistrationNumber'] as String?,
      taxId: json['taxId'] as String?,
      businessAddress: json['businessAddress'] as String,
      contactPhone: json['contactPhone'] as String,
      contactEmail: json['contactEmail'] as String?,
      user: json['user'] as Map<String, dynamic>?,
      status: json['status'] as String,
      approvedAt: json['approvedAt'] as String?,
      approvedBy: (json['approvedBy'] as num?)?.toInt(),
      rejectionReason: json['rejectionReason'] as String?,
      revenueSharePercent: (json['revenueSharePercent'] as num).toDouble(),
      storeCount: (json['storeCount'] as num).toInt(),
      staffCount: (json['staffCount'] as num).toInt(),
      notes: json['notes'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$PartnerProfileToJson(_PartnerProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'businessName': instance.businessName,
      'businessRegistrationNumber': instance.businessRegistrationNumber,
      'taxId': instance.taxId,
      'businessAddress': instance.businessAddress,
      'contactPhone': instance.contactPhone,
      'contactEmail': instance.contactEmail,
      'user': instance.user,
      'status': instance.status,
      'approvedAt': instance.approvedAt,
      'approvedBy': instance.approvedBy,
      'rejectionReason': instance.rejectionReason,
      'revenueSharePercent': instance.revenueSharePercent,
      'storeCount': instance.storeCount,
      'staffCount': instance.staffCount,
      'notes': instance.notes,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_PartnerOrderStatistics _$PartnerOrderStatisticsFromJson(
  Map<String, dynamic> json,
) => _PartnerOrderStatistics(
  partnerId: (json['partnerId'] as num).toInt(),
  totalOrders: (json['totalOrders'] as num).toInt(),
  todayOrders: (json['todayOrders'] as num).toInt(),
  weekOrders: (json['weekOrders'] as num).toInt(),
  monthOrders: (json['monthOrders'] as num).toInt(),
  initializedOrders: (json['initializedOrders'] as num).toInt(),
  waitingOrders: (json['waitingOrders'] as num).toInt(),
  collectedOrders: (json['collectedOrders'] as num).toInt(),
  processingOrders: (json['processingOrders'] as num).toInt(),
  readyOrders: (json['readyOrders'] as num).toInt(),
  returnedOrders: (json['returnedOrders'] as num).toInt(),
  completedOrders: (json['completedOrders'] as num).toInt(),
  canceledOrders: (json['canceledOrders'] as num).toInt(),
  totalRevenue: (json['totalRevenue'] as num).toDouble(),
  todayRevenue: (json['todayRevenue'] as num).toDouble(),
  weekRevenue: (json['weekRevenue'] as num).toDouble(),
  monthRevenue: (json['monthRevenue'] as num).toDouble(),
  averageOrderValue: (json['averageOrderValue'] as num).toDouble(),
  ordersByStore: Map<String, int>.from(json['ordersByStore'] as Map),
);

Map<String, dynamic> _$PartnerOrderStatisticsToJson(
  _PartnerOrderStatistics instance,
) => <String, dynamic>{
  'partnerId': instance.partnerId,
  'totalOrders': instance.totalOrders,
  'todayOrders': instance.todayOrders,
  'weekOrders': instance.weekOrders,
  'monthOrders': instance.monthOrders,
  'initializedOrders': instance.initializedOrders,
  'waitingOrders': instance.waitingOrders,
  'collectedOrders': instance.collectedOrders,
  'processingOrders': instance.processingOrders,
  'readyOrders': instance.readyOrders,
  'returnedOrders': instance.returnedOrders,
  'completedOrders': instance.completedOrders,
  'canceledOrders': instance.canceledOrders,
  'totalRevenue': instance.totalRevenue,
  'todayRevenue': instance.todayRevenue,
  'weekRevenue': instance.weekRevenue,
  'monthRevenue': instance.monthRevenue,
  'averageOrderValue': instance.averageOrderValue,
  'ordersByStore': instance.ordersByStore,
};

_StaffOrderSummary _$StaffOrderSummaryFromJson(Map<String, dynamic> json) =>
    _StaffOrderSummary(
      waitingCount: (json['waitingCount'] as num).toInt(),
      processingCount: (json['processingCount'] as num).toInt(),
      readyCount: (json['readyCount'] as num).toInt(),
      collectedCount: (json['collectedCount'] as num).toInt(),
      recentOrders: json['recentOrders'] as List<dynamic>,
    );

Map<String, dynamic> _$StaffOrderSummaryToJson(_StaffOrderSummary instance) =>
    <String, dynamic>{
      'waitingCount': instance.waitingCount,
      'processingCount': instance.processingCount,
      'readyCount': instance.readyCount,
      'collectedCount': instance.collectedCount,
      'recentOrders': instance.recentOrders,
    };
