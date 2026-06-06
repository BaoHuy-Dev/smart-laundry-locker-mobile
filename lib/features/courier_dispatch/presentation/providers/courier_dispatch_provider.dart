import 'dart:async';

import 'package:smart_laundry_locker/features/courier_dispatch/application/use_cases/remove_courier_availability_use_case.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/application/use_cases/update_courier_location_use_case.dart';
import 'package:smart_laundry_locker/features/orders/application/use_cases/get_courier_order_history_use_case.dart';
import 'package:smart_laundry_locker/features/orders/application/use_cases/get_courier_today_stats_use_case.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/application/use_cases/get_courier_active_delivery_use_case.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/application/use_cases/get_pending_dispatches_use_case.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/domain/entities/courier_active_delivery.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/courier_order.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:smart_laundry_locker/core/services/token_service.dart';
import 'package:smart_laundry_locker/core/constants/api_constants.dart';

class CourierDispatchProvider extends ChangeNotifier {
  final UpdateCourierLocationUseCase _updateLocationUseCase;
  final RemoveCourierAvailabilityUseCase _removeAvailabilityUseCase;
  final GetCourierTodayStatsUseCase _getCourierTodayStatsUseCase;
  final GetCourierOrderHistoryUseCase _getCourierOrderHistoryUseCase;
  final GetPendingDispatchesUseCase _getPendingDispatchesUseCase;
  final GetCourierActiveDeliveryUseCase _getCourierActiveDeliveryUseCase;

  IO.Socket? _socket;

  CourierDispatchProvider({
    required UpdateCourierLocationUseCase updateLocationUseCase,
    required RemoveCourierAvailabilityUseCase removeAvailabilityUseCase,
    required GetCourierTodayStatsUseCase getCourierTodayStatsUseCase,
    required GetCourierOrderHistoryUseCase getCourierOrderHistoryUseCase,
    required GetPendingDispatchesUseCase getPendingDispatchesUseCase,
    required GetCourierActiveDeliveryUseCase getCourierActiveDeliveryUseCase,
  }) : _updateLocationUseCase = updateLocationUseCase,
       _removeAvailabilityUseCase = removeAvailabilityUseCase,
       _getCourierTodayStatsUseCase = getCourierTodayStatsUseCase,
       _getCourierOrderHistoryUseCase = getCourierOrderHistoryUseCase,
       _getPendingDispatchesUseCase = getPendingDispatchesUseCase,
       _getCourierActiveDeliveryUseCase = getCourierActiveDeliveryUseCase;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int _completedToday = 0;
  int get completedToday => _completedToday;

  int _deliveringToday = 0;
  int get deliveringToday => _deliveringToday;

  List<CourierOrder> _activeOrders = const [];
  List<CourierOrder> get activeOrders => _activeOrders;

  CourierActiveDelivery? _activeDelivery;
  CourierActiveDelivery? get activeDelivery => _activeDelivery;

  Timer? _heartbeatTimer;
  double? _lastLatitude;
  double? _lastLongitude;

  // --- Pending dispatch tracking for notification badge ---
  final List<Map<String, dynamic>> _pendingDispatches = [];
  List<Map<String, dynamic>> get pendingDispatches =>
      List.unmodifiable(_pendingDispatches);
  int get pendingDispatchCount => _pendingDispatches.length;

  /// Remove and return the first pending dispatch (for showing the sheet).
  Map<String, dynamic>? popFirstPending() {
    if (_pendingDispatches.isEmpty) return null;
    final first = _pendingDispatches.removeAt(0);
    notifyListeners();
    return first;
  }

  /// Remove a pending dispatch by its dispatchId.
  void removePendingById(String dispatchId) {
    _pendingDispatches.removeWhere(
      (d) => d['dispatchId']?.toString() == dispatchId,
    );
    notifyListeners();
  }

  // Stream for new dispatch alerts
  final _newOrderController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _dispatchTakenController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _courierAcceptedController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _dispatchCancelledController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get newOrderStream => _newOrderController.stream;
  Stream<Map<String, dynamic>> get dispatchTakenStream =>
      _dispatchTakenController.stream;
  Stream<Map<String, dynamic>> get courierAcceptedStream =>
      _courierAcceptedController.stream;
  Stream<Map<String, dynamic>> get dispatchCancelledStream =>
      _dispatchCancelledController.stream;

  /// Ensures the WebSocket is connected and joined to the tracking room.
  /// Useful for customers listening for courier acceptance.
  Future<void> ensureSocketConnected() async {
    if (_socket != null && _socket!.connected) return;
    final token = await TokenService.getAccessToken();
    if (token != null) {
      _initSocket(token);
    }
  }

  void _initSocket(String token) async {
    if (_socket != null && _socket!.connected) return;

    final baseUrl = ApiConstants.apiBaseUrl;
    final wsUrl = baseUrl.startsWith('https')
        ? baseUrl.replaceFirst('https', 'wss')
        : baseUrl.replaceFirst('http', 'ws');

    debugPrint(
      'Initializing WebSocket to $wsUrl/dispatch with token length: ${token.length}',
    );

    _socket = IO.io(
      '$wsUrl/dispatch',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': 'Bearer $token'})
          .enableAutoConnect()
          .build(),
    );

    _socket?.onConnect((_) async {
      _isOnline =
          true; // Use private variable directly or update through setter
      debugPrint(
        '✓ Dispatch WebSocket Connected! (Namespace: ${_socket?.nsp})',
      );
      final userId = await TokenService.getUserId();
      if (userId != null) {
        debugPrint('Emitting join_tracking for courierId: $userId');
        _socket?.emit('join_tracking', {'courierId': userId});

        // RE-SYNC pending dispatches on every connection
        // to handle events missed during downtime
        if (_isOnline) {
          debugPrint('Re-syncing pending dispatches after connection...');
          syncPendingDispatches();
        }

        if (_isOnline && _lastLatitude != null && _lastLongitude != null) {
          _sendLocationUpdate(_lastLatitude!, _lastLongitude!);
        }
      }
    });

    _socket?.onDisconnect(
      (_) => debugPrint('Disconnected from Dispatch WebSocket'),
    );
    _socket?.onConnectError(
      (err) => debugPrint('Dispatch WebSocket Connect Error: $err'),
    );

    _socket?.on('dispatch_order', (data) {
      debugPrint('!!! Real-time order RECEIVED via WebSocket: $data');
      if (data is Map) {
        final mapped = Map<String, dynamic>.from(data);
        // Add to pending list for badge tracking
        final dispatchId = mapped['dispatchId']?.toString();
        debugPrint('Processing dispatch_order ID: $dispatchId');
        if (dispatchId != null) {
          final alreadyExists = _pendingDispatches.any(
            (d) => d['dispatchId']?.toString() == dispatchId,
          );
          if (!alreadyExists) {
            debugPrint('Dispatch $dispatchId added to pending list');
            _pendingDispatches.add(mapped);
            notifyListeners();
          } else {
            debugPrint(
              'Dispatch $dispatchId already exists in pending, skipping list add',
            );
          }
        }
        _newOrderController.add(mapped);
      } else {
        debugPrint('Dispatch order data is NOT a map: ${data.runtimeType}');
      }
    });

    _socket?.on('dispatch_taken', (data) {
      debugPrint('Order taken/cancelled via WebSocket: $data');
      if (data is Map) {
        final mapped = Map<String, dynamic>.from(data);
        // Remove from pending list
        final dispatchId = mapped['dispatchId']?.toString();
        if (dispatchId != null) {
          removePendingById(dispatchId);
        }
        _dispatchTakenController.add(mapped);
      }
    });

    _socket?.on('courier_accepted', (data) {
      debugPrint('Courier accepted order via WebSocket: $data');
      if (data is Map) {
        final mapped = Map<String, dynamic>.from(data);
        _courierAcceptedController.add(mapped);
      }
    });

    _socket?.on('dispatch_cancelled', (data) {
      debugPrint('Dispatch cancelled via WebSocket: $data');
      if (data is Map) {
        final mapped = Map<String, dynamic>.from(data);
        // Remove from pending list
        final dispatchId = mapped['dispatchId']?.toString();
        if (dispatchId != null) {
          removePendingById(dispatchId);
        }
        _dispatchCancelledController.add(mapped);
      }
    });
  }

  void _sendLocationUpdate(double lat, double lng) {
    if (_socket != null && _socket!.connected) {
      debugPrint('Broadcasting location via WebSocket: ($lat, $lng)');
      _socket?.emit('update_location', {'latitude': lat, 'longitude': lng});
    }
  }

  void _sendGoOffline() {
    if (_socket != null && _socket!.connected) {
      debugPrint('Sending go_offline via WebSocket');
      _socket?.emit('go_offline');
    }
  }

  Future<void> toggleOnlineStatus(
    bool value, {
    double? latitude,
    double? longitude,
  }) async {
    // If already in requested status and just updating location, handle efficiently
    if (_isOnline == value && value == true) {
      if (latitude != null && longitude != null) {
        await updateCurrentLocation(latitude, longitude);
      }
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (value) {
        final lat = latitude ?? _lastLatitude;
        final lng = longitude ?? _lastLongitude;
        if (lat == null || lng == null) {
          _error = 'Thiếu tọa độ hiện tại để bật chế độ hoạt động.';
          _isOnline = false;
          return;
        }

        final token = await TokenService.getAccessToken();
        if (token == null) {
          _error = 'Phiên đăng nhập hết hạn.';
          _isOnline = false;
          return;
        }

        // Initialize WebSocket
        _initSocket(token);

        final result = await _updateLocationUseCase(lat, lng);

        result.fold(
          (failure) {
            _error = failure.message;
            _isOnline = false;
          },
          (_) {
            _isOnline = true;
            _lastLatitude = lat;
            _lastLongitude = lng;
            _sendLocationUpdate(lat, lng);
            _startHeartbeat();

            // Sync any existing pending manually when going online
            // because onConnect triggers before _isOnline becomes true
            syncPendingDispatches();
          },
        );
      } else {
        // Go Offline
        _sendGoOffline();
        _stopHeartbeat();
        final result = await _removeAvailabilityUseCase();

        result.fold(
          (failure) {
            _error = failure.message;
          },
          (_) {
            _isOnline = false;
          },
        );
      }
    } catch (e) {
      _error = 'Đã xảy ra lỗi không mong muốn: $e';
      debugPrint('toggleOnlineStatus unexpected error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> goOnlineWithLocation(double latitude, double longitude) async {
    await toggleOnlineStatus(true, latitude: latitude, longitude: longitude);
    return _isOnline;
  }

  Future<void> updateCurrentLocation(double latitude, double longitude) async {
    _lastLatitude = latitude;
    _lastLongitude = longitude;

    // Send via WebSocket if online
    if (_isOnline) {
      _sendLocationUpdate(latitude, longitude);
    }

    final result = await _updateLocationUseCase(latitude, longitude);
    result.fold((failure) => _error = failure.message, (_) => _error = null);
    notifyListeners();
  }

  Future<void> goOffline() async {
    await toggleOnlineStatus(false);
  }

  Future<void> fetchCourierStats() async {
    final result = await _getCourierTodayStatsUseCase();
    result.fold((failure) => _error = failure.message, (stats) {
      _error = null;
      _completedToday = stats.completedToday;
      _deliveringToday = stats.deliveringToday;
    });
    notifyListeners();
  }

  Future<void> fetchActiveOrders() async {
    final result = await _getCourierOrderHistoryUseCase(page: 1, limit: 50);
    result.fold((failure) => _error = failure.message, (orders) {
      _error = null;
      _activeOrders = orders.where((o) => !o.isCompleted).toList();
    });
    notifyListeners();
  }

  Future<void> fetchActiveDeliveryDetail() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _getCourierActiveDeliveryUseCase();
    result.fold((failure) => _error = failure.message, (delivery) {
      _error = null;
      _activeDelivery = delivery;
    });

    _isLoading = false;
    notifyListeners();
  }

  Future<void> syncPendingDispatches() async {
    final result = await _getPendingDispatchesUseCase();
    result.fold((failure) => _error = failure.message, (dispatches) {
      _error = null;
      for (var d in dispatches) {
        final mapped = {
          'dispatchId': d.id,
          'senderAddress': d.senderAddress,
          'receiverAddress': d.receiverAddress,
          'lockerLabel': d.lockerLabel,
        };
        final alreadyExists = _pendingDispatches.any(
          (existing) => existing['dispatchId'] == d.id,
        );
        if (!alreadyExists) {
          _pendingDispatches.add(mapped);
        }
        _newOrderController.add(mapped);
      }
    });
    notifyListeners();
  }

  Future<void> verifySocketSession() async {
    if (_socket == null || !_socket!.connected) {
      debugPrint('verifySocketSession: Socket NOT connected');
      return;
    }

    debugPrint('Requesting check_identity from server...');
    _socket?.emitWithAck(
      'check_identity',
      {},
      ack: (dynamic data) {
        debugPrint('!!! Identity Check Result: $data');
      },
    );
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    debugPrint('Courier heartbeat started (3m interval)');
    _heartbeatTimer = Timer.periodic(const Duration(minutes: 3), (_) async {
      if (!_isOnline) {
        debugPrint('Heartbeat skipped: courier not online');
        return;
      }
      final lat = _lastLatitude;
      final lng = _lastLongitude;
      if (lat == null || lng == null) {
        debugPrint('Heartbeat skipped: missing location data');
        return;
      }
      debugPrint('Sending courier heartbeat location: ($lat, $lng)');
      final result = await _updateLocationUseCase(lat, lng);
      result.fold(
        (failure) {
          _error = failure.message;
          debugPrint('Heartbeat failed: ${failure.message}');
        },
        (_) {
          _error = null;
          debugPrint('Heartbeat update success');
        },
      );
      notifyListeners();
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  @override
  void dispose() {
    _stopHeartbeat();
    _newOrderController.close();
    _dispatchTakenController.close();
    _courierAcceptedController.close();
    _dispatchCancelledController.close();
    super.dispose();
  }
}
