int? _asInt(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _asDouble(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String? _asString(Object? value) => value?.toString();

bool _asBool(Object? value, {bool fallback = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.toLowerCase().trim();
    if (normalized == 'true' || normalized == 'active') return true;
    if (normalized == 'false' || normalized == 'inactive') return false;
  }
  return fallback;
}

class UserLaundryStore {
  final int id;
  final String name;
  final String? contactPhone;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? image;
  final String? description;
  final bool active;
  final double? distanceKm;
  final String? status;

  const UserLaundryStore({
    required this.id,
    required this.name,
    this.contactPhone,
    this.address,
    this.latitude,
    this.longitude,
    this.image,
    this.description,
    required this.active,
    this.distanceKm,
    this.status,
  });

  factory UserLaundryStore.fromJson(Map<String, dynamic> json) {
    return UserLaundryStore(
      id: _asInt(json['id']) ?? 0,
      name: _asString(json['name']) ?? 'Cua hang',
      contactPhone: _asString(json['contactPhone'] ?? json['phone']),
      address: _asString(json['address']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
      image: _asString(json['image'] ?? json['imageUrl']),
      description: _asString(json['description']),
      active: _asBool(json['active'], fallback: true),
      distanceKm: _asDouble(json['distanceKm']),
      status: _asString(json['status']),
    );
  }
}

class UserLaundryLocker {
  final int id;
  final int? storeId;
  final String code;
  final String name;
  final String status;
  final String? address;
  final double? latitude;
  final double? longitude;

  const UserLaundryLocker({
    required this.id,
    this.storeId,
    required this.code,
    required this.name,
    required this.status,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory UserLaundryLocker.fromJson(Map<String, dynamic> json) {
    final code = _asString(json['code']) ?? 'LOCKER-${json['id'] ?? ''}';
    return UserLaundryLocker(
      id: _asInt(json['id']) ?? 0,
      storeId: _asInt(json['storeId']),
      code: code,
      name: _asString(json['name']) ?? code,
      status: _asString(json['status']) ?? 'UNKNOWN',
      address: _asString(json['address']),
      latitude: _asDouble(json['latitude']),
      longitude: _asDouble(json['longitude']),
    );
  }
}

class UserLaundryBox {
  final int id;
  final int lockerId;
  final int? boxNumber;
  final String size;
  final String status;

  const UserLaundryBox({
    required this.id,
    required this.lockerId,
    this.boxNumber,
    required this.size,
    required this.status,
  });

  factory UserLaundryBox.fromJson(Map<String, dynamic> json) {
    return UserLaundryBox(
      id: _asInt(json['boxId'] ?? json['id']) ?? 0,
      lockerId: _asInt(json['lockerId']) ?? 0,
      boxNumber: _asInt(json['boxNumber']),
      size: _asString(json['size']) ?? 'MEDIUM',
      status: _asString(json['status']) ?? 'UNKNOWN',
    );
  }

  String get displayName => boxNumber == null ? 'Box $id' : 'Box $boxNumber';
}

class UserLaundryServiceItem {
  final int id;
  final String name;
  final String category;
  final double price;
  final String? description;
  final bool active;

  const UserLaundryServiceItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.description,
    required this.active,
  });

  factory UserLaundryServiceItem.fromJson(Map<String, dynamic> json) {
    return UserLaundryServiceItem(
      id: _asInt(json['id']) ?? 0,
      name: _asString(json['name'] ?? json['serviceName']) ?? 'Dich vu',
      category:
          _asString(json['category'] ?? json['serviceCategory']) ?? 'LAUNDRY',
      price: _asDouble(json['price'] ?? json['unitPrice']) ?? 0,
      description: _asString(json['description']),
      active: _asBool(json['active'], fallback: true),
    );
  }
}

class UserLaundryOrder {
  final int id;
  final String? orderCode;
  final int? lockerId;
  final int? sendBoxId;
  final int? storeId;
  final String? type;
  final String? serviceCategory;
  final String status;
  final String? pinCode;
  final double? totalPrice;
  final double? originalPrice;
  final bool paymentRequired;
  final String? nextAction;
  final String? nextActionMessage;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserLaundryOrder({
    required this.id,
    this.orderCode,
    this.lockerId,
    this.sendBoxId,
    this.storeId,
    this.type,
    this.serviceCategory,
    required this.status,
    this.pinCode,
    this.totalPrice,
    this.originalPrice,
    required this.paymentRequired,
    this.nextAction,
    this.nextActionMessage,
    this.createdAt,
    this.updatedAt,
  });

  factory UserLaundryOrder.fromJson(Map<String, dynamic> json) {
    return UserLaundryOrder(
      id: _asInt(json['id']) ?? 0,
      orderCode: _asString(json['orderCode'] ?? json['code']),
      lockerId: _asInt(json['lockerId']),
      sendBoxId: _asInt(json['sendBoxId'] ?? json['boxId']),
      storeId: _asInt(json['storeId']),
      type: _asString(json['type']),
      serviceCategory: _asString(json['serviceCategory']),
      status: _asString(json['status']) ?? 'UNKNOWN',
      pinCode: _asString(json['pinCode']),
      totalPrice: _asDouble(json['totalPrice']),
      originalPrice: _asDouble(json['originalPrice']),
      paymentRequired: _asBool(json['paymentRequired']),
      nextAction: _asString(json['nextAction']),
      nextActionMessage: _asString(json['nextActionMessage']),
      createdAt: DateTime.tryParse(_asString(json['createdAt']) ?? ''),
      updatedAt: DateTime.tryParse(_asString(json['updatedAt']) ?? ''),
    );
  }
}

class UserLaundryPayment {
  final int id;
  final int orderId;
  final double amount;
  final String method;
  final String status;
  final String? paymentUrl;
  final String? qrCodeUrl;
  final String? deeplink;
  final String? description;

  const UserLaundryPayment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.method,
    required this.status,
    this.paymentUrl,
    this.qrCodeUrl,
    this.deeplink,
    this.description,
  });

  factory UserLaundryPayment.fromJson(Map<String, dynamic> json) {
    return UserLaundryPayment(
      id: _asInt(json['id']) ?? 0,
      orderId: _asInt(json['orderId']) ?? 0,
      amount: _asDouble(json['amount']) ?? 0,
      method: _asString(json['method']) ?? 'UNKNOWN',
      status: _asString(json['status']) ?? 'UNKNOWN',
      paymentUrl: _asString(json['paymentUrl']),
      qrCodeUrl: _asString(json['qrCodeUrl']),
      deeplink: _asString(json['deeplink']),
      description: _asString(json['description']),
    );
  }
}

class UserLaundryNotification {
  final int id;
  final String title;
  final String body;
  final bool read;
  final DateTime? createdAt;

  const UserLaundryNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.read,
    this.createdAt,
  });

  factory UserLaundryNotification.fromJson(Map<String, dynamic> json) {
    return UserLaundryNotification(
      id: _asInt(json['id']) ?? 0,
      title: _asString(json['title']) ?? 'Thong bao',
      body: _asString(json['body'] ?? json['message'] ?? json['content']) ?? '',
      read: _asBool(json['read'] ?? json['isRead']),
      createdAt: DateTime.tryParse(_asString(json['createdAt']) ?? ''),
    );
  }
}
