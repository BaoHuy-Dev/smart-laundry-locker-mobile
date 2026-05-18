import 'package:intl/intl.dart';

import '../models/locker.dart';
import '../models/order.dart';
import '../models/payment.dart';
import '../models/service.dart';

String formatCurrency(num? value) {
  return NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  ).format(value ?? 0);
}

String formatDateTimeText(String? value) {
  if (value == null || value.isEmpty) return '';
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  return DateFormat('dd/MM/yyyy HH:mm', 'vi_VN').format(date.toLocal());
}

String formatDateText(String? value) {
  if (value == null || value.isEmpty) return '';
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  return DateFormat('dd/MM/yyyy', 'vi_VN').format(date.toLocal());
}

String serviceCategoryValue(ServiceCategory category) {
  return category == ServiceCategory.laundry ? 'LAUNDRY' : 'STORAGE';
}

String orderTypeValue(OrderType type) {
  switch (type) {
    case OrderType.standardDropoff:
      return 'STANDARD_DROPOFF';
    case OrderType.laundry:
      return 'LAUNDRY';
    case OrderType.storage:
      return 'STORAGE';
  }
}

String paymentMethodValue(PaymentMethod method) {
  switch (method) {
    case PaymentMethod.vnpay:
      return 'VNPAY';
    case PaymentMethod.momo:
      return 'MOMO';
    case PaymentMethod.cash:
      return 'CASH';
  }
}

String orderStatusValue(OrderStatus status) {
  switch (status) {
    case OrderStatus.initialized:
      return 'INITIALIZED';
    case OrderStatus.waiting:
      return 'WAITING';
    case OrderStatus.collected:
      return 'COLLECTED';
    case OrderStatus.processing:
      return 'PROCESSING';
    case OrderStatus.ready:
      return 'READY';
    case OrderStatus.returned:
      return 'RETURNED';
    case OrderStatus.completed:
      return 'COMPLETED';
    case OrderStatus.canceled:
      return 'CANCELED';
  }
}

String orderStatusLabel(OrderStatus status, {OrderType? type}) {
  switch (status) {
    case OrderStatus.initialized:
      return 'Đã đặt';
    case OrderStatus.waiting:
      return type == OrderType.storage ? 'Chờ gửi đồ' : 'Chờ lấy đồ';
    case OrderStatus.collected:
      return 'Đã thu gom';
    case OrderStatus.processing:
      return 'Đang xử lý';
    case OrderStatus.ready:
      return 'Sẵn sàng nhận';
    case OrderStatus.returned:
      return 'Đã trả về tủ';
    case OrderStatus.completed:
      return 'Hoàn thành';
    case OrderStatus.canceled:
      return 'Đã hủy';
  }
}

String lockerStatusLabel(LockerStatus status) {
  switch (status) {
    case LockerStatus.active:
      return 'Hoạt động';
    case LockerStatus.maintenance:
      return 'Bảo trì';
    case LockerStatus.inactive:
      return 'Tạm ngưng';
  }
}

String boxStatusLabel(BoxStatus status) {
  switch (status) {
    case BoxStatus.available:
      return 'Trống';
    case BoxStatus.occupied:
      return 'Đang dùng';
    case BoxStatus.reserved:
      return 'Đã giữ';
    case BoxStatus.maintenance:
      return 'Bảo trì';
  }
}

String serviceUnitLabel(String unit) {
  switch (unit.toUpperCase()) {
    case 'KG':
      return 'kg';
    case 'HOUR':
      return 'giờ';
    case 'NIGHT':
      return 'đêm';
    case 'MONTH':
      return 'tháng';
    default:
      return unit.toLowerCase();
  }
}
