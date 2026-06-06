import 'package:flutter/material.dart';
import '../../data/models/voucher_model.dart';
import '../../data/repositories/voucher_repository.dart';

class VoucherProvider extends ChangeNotifier {
  final VoucherRepository _repository = VoucherRepository();

  List<VoucherModel> _vouchers = [];
  bool _isLoading = false;
  String? _error;

  List<VoucherModel> get vouchers => _vouchers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMyVouchers({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _vouchers = await _repository.getMyVouchers(status: status);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> useVoucher(String voucherId) async {
    final success = await _repository.useVoucher(voucherId);
    if (success) {
      await loadMyVouchers(); // refresh
    }
    return success;
  }
}
