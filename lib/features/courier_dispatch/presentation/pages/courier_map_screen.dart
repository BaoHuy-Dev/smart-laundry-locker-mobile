import 'dart:async';

import 'package:smart_laundry_locker/core/theme/shadcn_theme.dart';
import 'package:smart_laundry_locker/features/courier_delivery/presentation/providers/courier_delivery_injection.dart';
import 'package:smart_laundry_locker/features/courier_delivery/presentation/providers/courier_delivery_provider.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/presentation/providers/courier_dispatch_injection.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/presentation/providers/courier_dispatch_provider.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/presentation/widgets/incoming_order_sheet.dart';
import 'package:smart_laundry_locker/shared/widgets/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_laundry_locker/core/routing/app_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CourierMapScreen extends StatefulWidget {
  final Position? initialPosition;

  const CourierMapScreen({super.key, this.initialPosition});

  @override
  State<CourierMapScreen> createState() => _CourierMapScreenState();
}

class _CourierMapScreenState extends State<CourierMapScreen> {
  late final CourierDispatchProvider _dispatchProvider;
  late final CourierDeliveryProvider _deliveryProvider;
  late final MapController _mapController;
  StreamSubscription<Position>? _positionSub;
  StreamSubscription<Map<String, dynamic>>? _orderSub;

  LatLng? _courierLatLng;
  bool _isSyncing = true;

  @override
  void initState() {
    super.initState();
    _dispatchProvider =
        CourierDispatchInjection.provideCourierDispatchProvider();
    _deliveryProvider =
        CourierDeliveryInjection.provideCourierDeliveryProvider();
    _mapController = MapController();
    if (widget.initialPosition != null) {
      _courierLatLng = LatLng(
        widget.initialPosition!.latitude,
        widget.initialPosition!.longitude,
      );
    }
    _startWorkingFlow();
  }

  Future<void> _startWorkingFlow() async {
    _listenRealtimePosition(); // Start listening immediately

    final pos = _courierLatLng;
    if (pos == null) {
      // If we don't have initial pos, we'll wait for the first update from _listenRealtimePosition
      setState(() => _isSyncing = false);
      return;
    }
    try {
      final ok = await _dispatchProvider.goOnlineWithLocation(
        pos.latitude,
        pos.longitude,
      );
      if (!mounted) return;
      if (ok) {
        // Sync any active dispatches immediately after going online
        await _dispatchProvider.syncPendingDispatches();
        // Fetch active orders to show in header
        await _dispatchProvider.fetchActiveOrders();
        // Fetch active delivery to enable routing
        await _deliveryProvider.fetchActiveDeliveryDetail();
      } else if (_dispatchProvider.error != null) {
        SmartDialog.showToast(_dispatchProvider.error!);
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  void _listenRealtimePosition() {
    _positionSub?.cancel();
    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((position) async {
          final next = LatLng(position.latitude, position.longitude);
          if (!mounted) return;
          setState(() => _courierLatLng = next);
          await _dispatchProvider.updateCurrentLocation(
            next.latitude,
            next.longitude,
          );
          _mapController.move(next, _mapController.camera.zoom);
        });
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _orderSub?.cancel();
    super.dispose();
  }

  Future<void> _onBellTapped() async {
    SmartDialog.showLoading<void>(msg: 'Đang làm mới...');
    await Future.wait([
      _dispatchProvider.syncPendingDispatches(),
      // _deliveryProvider.fetchActiveDeliveryDetail(),
    ]);
    SmartDialog.dismiss<void>();

    final dispatchData = _dispatchProvider.popFirstPending();
    if (dispatchData == null) {
      SmartDialog.showToast(
        'Không có đơn hàng chờ xử lý',
        alignment: Alignment.center,
      );
      return;
    }
    _showPendingOrderSheet(dispatchData);
  }

  void _showPendingOrderSheet(Map<String, dynamic> dispatchData) {
    final dispatchId = dispatchData['dispatchId']?.toString() ?? '';

    showCupertinoModalPopup<void>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => IncomingOrderSheet(
        dispatchData: dispatchData,
        onAccept: () async {
          final success = await _deliveryProvider.acceptOrder(dispatchId);
          if (!mounted) return;
          if (success) {
            _dispatchProvider.removePendingById(dispatchId);
            Navigator.of(context).pop(); // Close sheet on success
            SmartDialog.showToast('Đã nhận đơn hàng! Nhấn 📋 để xem chi tiết.');

            // Refresh active delivery data (courier taps scroll icon to navigate)
            await Future.wait([
              _dispatchProvider.fetchActiveOrders(),
              _deliveryProvider.fetchActiveDeliveryDetail(),
            ]);
          } else {
            SmartDialog.showToast(
              _deliveryProvider.error ?? 'Không thể nhận đơn hàng',
              alignment: Alignment.center,
            );
          }
        },
        onDecline: () async {
          // Non-blocking reject call (best effort)
          unawaited(
            _deliveryProvider.rejectOrder(
              dispatchId,
              reason: 'Declined by courier',
            ),
          );
          _dispatchProvider.removePendingById(dispatchId);
          SmartDialog.showToast('Đã từ chối đơn hàng');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = _courierLatLng;
    if (current == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(
          title: 'Đang tải bản đồ...',
          centerTitle: true,
          backgroundColor: Colors.white,
          showBackButton: true,
          foregroundColorButton: Colors.black,
        ),
        body: Center(
          child: CircularProgressIndicator(color: AISLShadcnTheme.navyPrimary),
        ),
      );
    }

    return ListenableBuilder(
      listenable: Listenable.merge([_dispatchProvider, _deliveryProvider]),
      builder: (context, _) {
        final activeDelivery = _deliveryProvider.activeOrder;
        final hasActiveOrder = activeDelivery != null;

        return Scaffold(
          appBar: CustomAppBar(
            titleWidget: GestureDetector(
              onTap: () {
                if (hasActiveOrder) {
                  context.push(AppRouter.activeDelivery);
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    hasActiveOrder ? 'Đơn đang thực hiện' : 'Đang làm việc',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  if (hasActiveOrder)
                    Text(
                      activeDelivery.orderCode,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AISLShadcnTheme.navyPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  else
                    const Text(
                      'Đang chờ đơn mới...',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            showBackButton: true,
            foregroundColorButton: Colors.black,
            actions: [
              // Notification bell with yellow badge for pending dispatches
              ListenableBuilder(
                listenable: _dispatchProvider,
                builder: (context, _) {
                  final count = _dispatchProvider.pendingDispatchCount;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: Icon(
                          count > 0 ? LucideIcons.bellRing : LucideIcons.bell,
                          color: count > 0
                              ? AISLShadcnTheme.navyPrimary
                              : Colors.black,
                        ),
                        onPressed: () => _onBellTapped(),
                      ),
                      if (count > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B), // yellow-500
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFF59E0B,
                                  ).withOpacity(0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              count > 9 ? '9+' : count.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
              IconButton(
                icon: const Icon(LucideIcons.scrollText, color: Colors.black),
                onPressed: () async {
                  SmartDialog.showLoading<void>(msg: 'Đang kiểm tra...');
                  await _deliveryProvider.fetchActiveDeliveryDetail();
                  SmartDialog.dismiss<void>();

                  if (!mounted) return;

                  if (_deliveryProvider.activeOrder != null) {
                    context.push(
                      AppRouter.activeDelivery,
                      extra: _deliveryProvider.activeOrder,
                    );
                  } else {
                    SmartDialog.showToast(
                      'Bạn chưa thực hiện đơn nào',
                      alignment: Alignment.center,
                    );
                  }
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: current,
                  initialZoom: 16,
                  minZoom: 3,
                  maxZoom: 18,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.aisl_app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: current,
                        width: 80,
                        height: 80,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.location_on,
                              color: AISLShadcnTheme.navyPrimary,
                              size: 36,
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Vị trí của bạn',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (_isSyncing)
                Container(
                  color: Colors.black.withOpacity(0.16),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AISLShadcnTheme.navyPrimary,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
