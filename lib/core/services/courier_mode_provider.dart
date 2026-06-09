import 'package:flutter/foundation.dart';

import 'courier_mode_service.dart';
import 'package:smart_laundry_locker/core/services/token_service.dart';

class CourierModeProvider extends ChangeNotifier {
  bool _isCourierModeActive = false;
  bool _initialized = false;

  bool get isCourierModeActive => _isCourierModeActive;

  Future<bool> _checkIsCourier() async {
    try {
      final cached = await CourierModeService.getIsCourierUser();
      if (cached != null) {
        return cached;
      }
      final roles = await TokenService.getCurrentRoles();
      final isCourier = roles.contains('COURIER');
      await CourierModeService.setIsCourierUser(isCourier);
      return isCourier;
    } catch (_) {
      return false;
    }
  }

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    bool storedValue = false;
    try {
      storedValue = await CourierModeService.getCourierMode();
    } catch (_) {
      storedValue = false;
    }

    if (!storedValue) {
      _isCourierModeActive = false;
      notifyListeners();
      return;
    }

    final approved = await _checkIsCourier().catchError((_) {
      return false;
    });

    _isCourierModeActive = approved;
    if (!approved) {
      try {
        await CourierModeService.setCourierMode(false);
      } catch (_) {}
    }

    notifyListeners();
  }

  Future<void> setCourierModeActive(bool value) async {
    if (value == _isCourierModeActive && _initialized) return;

    final prev = _isCourierModeActive;
    try {
      if (!kDebugMode && value) {
        final approved = await _checkIsCourier();
        if (!approved) {
          _isCourierModeActive = false;
          await CourierModeService.setCourierMode(false);
          notifyListeners();
          return;
        }
      }

      _isCourierModeActive = value;
      await CourierModeService.setCourierMode(value);
    } catch (_) {
      _isCourierModeActive = prev;
    } finally {
      notifyListeners();
    }
  }
}
