import 'package:smart_laundry_locker/features/courier_delivery/infrastructure/models/responses.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/entities/courier_accept_hints.dart';

extension CourierAcceptResponseToHints on CourierAcceptResponse {
  CourierAcceptHints toCourierAcceptHints() {
    return CourierAcceptHints(
      accessCode: accessCode,
      lockerLabel: lockerLabel,
      cabinetName: cabinetName,
      address: address,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
    );
  }
}
