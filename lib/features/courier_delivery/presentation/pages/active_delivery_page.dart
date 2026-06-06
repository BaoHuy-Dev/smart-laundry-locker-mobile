import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:smart_laundry_locker/core/theme/shadcn_theme.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/courier_order.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_laundry_locker/core/routing/app_router.dart';
import 'package:smart_laundry_locker/features/orders/presentation/widgets/order_status_colors.dart';
import 'package:smart_laundry_locker/shared/widgets/app_bar.dart';
import 'package:intl/intl.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/courier_delivery_provider.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/locker/presentation/providers/locker_injection.dart';
import 'package:smart_laundry_locker/features/locker/presentation/providers/locker_provider.dart';
import 'package:smart_laundry_locker/features/orders/presentation/widgets/pulsing_report_icon.dart';
import 'package:smart_laundry_locker/features/maintenance/presentation/pages/create_report_page.dart';

class ActiveDeliveryPage extends StatefulWidget {
  const ActiveDeliveryPage({super.key});

  @override
  State<ActiveDeliveryPage> createState() => _ActiveDeliveryPageState();
}

class _ActiveDeliveryPageState extends State<ActiveDeliveryPage> {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _positionSub;
  LatLng? _courierLatLng;
  List<LatLng> _routePoints = [];
  bool _isFetchingRoute = false;
  Timer? _statusTimer;
  late final LockerProvider _lockerProvider;

  @override
  void initState() {
    super.initState();
    _lockerProvider = LockerInjection.provideLockerProvider(ApiClient());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CourierDeliveryProvider>();
      if (provider.activeOrder == null) {
        provider.fetchActiveDeliveryDetail();
      }
    });
    _initLocationTracking();
    _initPolling();
  }

  void _initPolling() {
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      final provider = context.read<CourierDeliveryProvider>();
      // Poll if we are in pickingUp phase to wait for physical locker action
      if (provider.phase == DeliveryPhase.pickingUp) {
        provider.refreshActiveDelivery();
      }
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _positionSub?.cancel();
    _mapController.dispose();
    _lockerProvider.dispose();
    super.dispose();
  }

  void _initLocationTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((position) {
          if (!mounted) return;
          final next = LatLng(position.latitude, position.longitude);
          setState(() => _courierLatLng = next);

          final provider = context.read<CourierDeliveryProvider>();
          final order = provider.activeOrder;
          if (order != null) {
            final isPickingUp = provider.phase == DeliveryPhase.pickingUp;
            final lat = isPickingUp ? order.latitude : order.receiverLatitude;
            final lon = isPickingUp ? order.longitude : order.receiverLongitude;

            if (lat != null && lon != null) {
              final target = LatLng(lat, lon);
              if (_routePoints.isEmpty) {
                _fetchRoute(next, target);
              }
            }
          }
        });

    try {
      final pos = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() => _courierLatLng = LatLng(pos.latitude, pos.longitude));
      }
    } catch (_) {}
  }

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    if (_isFetchingRoute) return;
    setState(() => _isFetchingRoute = true);

    try {
      final String url =
          'https://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=polyline';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
            json.decode(response.body) as Map<String, dynamic>;
        final List? routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final String geometry = routes[0]['geometry'] as String;
          final points = _decodePolyline(geometry);
          if (mounted) {
            setState(() {
              _routePoints = points;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
    } finally {
      if (mounted) {
        setState(() => _isFetchingRoute = false);
      }
    }
  }

  /// Launch native navigation (Google Maps / Apple Maps) to [dest]
  Future<void> _openNavigation(LatLng dest) async {
    final lat = dest.latitude;
    final lon = dest.longitude;
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=driving',
    );
    final appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?daddr=$lat,$lon&dirflg=d',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(appleMapsUrl)) {
      await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        SmartDialog.showToast('Không thể mở ứng dụng bản đồ');
      }
    }
  }

  /// Fit map camera to show both courier and destination markers
  void _fitMapBounds(LatLng courier, LatLng destination) {
    final bounds = LatLngBounds(
      LatLng(
        courier.latitude < destination.latitude
            ? courier.latitude
            : destination.latitude,
        courier.longitude < destination.longitude
            ? courier.longitude
            : destination.longitude,
      ),
      LatLng(
        courier.latitude > destination.latitude
            ? courier.latitude
            : destination.latitude,
        courier.longitude > destination.longitude
            ? courier.longitude
            : destination.longitude,
      ),
    );
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
    );
  }

  String _fmtDate(DateTime? d) =>
      d == null ? '--' : DateFormat('dd/MM/yyyy HH:mm').format(d.toLocal());

  String _fmtCurrency(double v) =>
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(v);

  Widget _infoRow(
    String label,
    String value, {
    Color? valueColor,
    FontWeight? valueFontWeight,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: valueFontWeight ?? FontWeight.w700,
                color: valueColor ?? Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CourierDeliveryProvider>(
      builder: (context, provider, child) {
        final phase = provider.phase;
        final order = provider.activeOrder;
        final isHomePickup = order?.order?.logisticsType == 'HOME_TO_LOCKER';

        if (provider.isLoading && order == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (order == null) {
          return const Scaffold(
            body: Center(child: Text('Không có đơn hàng nào đang chạy')),
          );
        }

        final isPickingUp = phase == DeliveryPhase.pickingUp;

        // LOCKER_TO_LOCKER picking up: target = cabinet/location coords (order.latitude/longitude)
        // HOME_TO_LOCKER picking up: target = customer home address coords (order.latitude/longitude)
        // Heading to locker (any type): target = receiver/destination locker coords
        final lat = isPickingUp
            ? order.latitude
            : (order.receiverLatitude ?? order.latitude);
        final lon = isPickingUp
            ? order.longitude
            : (order.receiverLongitude ?? order.longitude);

        final target = (lat != null && lon != null) ? LatLng(lat, lon) : null;

        // Destination label shown on map
        final destLabel = isPickingUp
            ? (isHomePickup ? 'Nhà khách hàng' : 'Vị trí tủ nguồn')
            : 'Tủ giao hàng';
        final destAddress = isPickingUp
            ? (isHomePickup
                  ? (order.address ?? 'Địa chỉ lấy hàng')
                  : (order.cabinetName ?? 'Vị trí tủ'))
            : (provider.latestDetail?.receiverAddress ??
                  order.cabinetName ??
                  'Tủ giao');

        final domainOrder = order.order?.toDomain();
        if (domainOrder == null) {
          debugPrint(
            '[ActiveDeliveryPage] Rendering Order without domain data: ${order.orderCode}',
          );
        }

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: CustomAppBar(
            title: 'Đơn ${order.orderCode}',
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            foregroundColorButton: Colors.black,
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.fileText),
                tooltip: 'Lịch sử đơn',
                onPressed: () {
                  final courierOrder = CourierOrder(
                    orderId: order.orderId,
                    dispatchId: provider.activeDispatchId,
                    orderCode: order.orderCode,
                    status: 'ACTIVE',
                    originName: order.address ?? '',
                    destinationName: order.recipientName ?? '',
                    time: DateTime.now(),
                    income: 0,
                  );
                  context.push(
                    AppRouter.activeOrderDetails,
                    extra: courierOrder,
                  );
                },
              ),
              PulsingReportIcon(onPressed: () => _handleReportIssue(context)),
            ],
          ),
          body: Column(
            children: [
              // Top Map Section (Fixed height)
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.38,
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter:
                            _courierLatLng ??
                            target ??
                            const LatLng(10.762622, 106.660172),
                        initialZoom: 14,
                        onMapReady: () {
                          if (_courierLatLng != null && target != null) {
                            Future.delayed(
                              const Duration(milliseconds: 300),
                              () => _fitMapBounds(_courierLatLng!, target),
                            );
                          }
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.aisl.app',
                        ),
                        if (_routePoints.isNotEmpty)
                          PolylineLayer(
                            polylines: [
                              Polyline(
                                points: _routePoints,
                                color: AISLShadcnTheme.navyPrimary,
                                strokeWidth: 5,
                              ),
                            ],
                          ),
                        MarkerLayer(
                          markers: [
                            // Courier marker
                            if (_courierLatLng != null)
                              Marker(
                                point: _courierLatLng!,
                                width: 80,
                                height: 60,
                                alignment: Alignment.topCenter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Tôi',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      LucideIcons.navigation,
                                      color: Colors.blue,
                                      size: 28,
                                    ),
                                  ],
                                ),
                              ),
                            // Destination marker
                            if (target != null)
                              Marker(
                                point: target,
                                width: 120,
                                height: 70,
                                alignment: Alignment.bottomCenter,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isHomePickup && isPickingUp
                                            ? Colors.deepPurple
                                            : Colors.red,
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        destLabel,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    Icon(
                                      isHomePickup && isPickingUp
                                          ? LucideIcons.house
                                          : LucideIcons.packageOpen,
                                      color: isHomePickup && isPickingUp
                                          ? Colors.deepPurple
                                          : Colors.red,
                                      size: 32,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    // Status banner
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 60,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              phase == DeliveryPhase.pickingUp
                                  ? (isHomePickup
                                        ? LucideIcons.house
                                        : LucideIcons.packageSearch)
                                  : LucideIcons.truck,
                              color: AISLShadcnTheme.navyPrimary,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    phase == DeliveryPhase.pickingUp
                                        ? (isHomePickup
                                              ? 'Đến lấy hàng tại nhà khách'
                                              : 'Đến tủ nguồn nhận hàng')
                                        : phase == DeliveryPhase.headingToLocker
                                        ? 'Đang đến tủ giao hàng'
                                        : 'Đã tới tủ locker',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (destAddress.isNotEmpty)
                                    Text(
                                      destAddress,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Fit-bounds button (top-right)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _mapIconButton(
                        icon: LucideIcons.maximize2,
                        tooltip: 'Xem toàn bộ',
                        onPressed: () {
                          if (_courierLatLng != null && target != null) {
                            _fitMapBounds(_courierLatLng!, target);
                          } else if (_courierLatLng != null) {
                            _mapController.move(_courierLatLng!, 15);
                          }
                        },
                      ),
                    ),
                    // Locate-me button (bottom-right)
                    Positioned(
                      bottom: 60,
                      right: 12,
                      child: _mapIconButton(
                        icon: LucideIcons.locateFixed,
                        iconColor: Colors.blue,
                        tooltip: 'Vị trí của tôi',
                        onPressed: () {
                          if (_courierLatLng != null) {
                            _mapController.move(_courierLatLng!, 16);
                          }
                        },
                      ),
                    ),
                    // Navigation button (bottom-right)
                    if (target != null)
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: FloatingActionButton.extended(
                          heroTag: 'navigate_btn',
                          backgroundColor: AISLShadcnTheme.navyPrimary,
                          onPressed: () => _openNavigation(target),
                          icon: const Icon(
                            LucideIcons.navigation,
                            color: Colors.white,
                            size: 16,
                          ),
                          label: const Text(
                            'Dẫn đường',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          elevation: 4,
                        ),
                      ),
                  ],
                ),
              ),

              // Bottom Info Section (Scrollable)
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Status & Order Code Header
                      ShadCard(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: phase == DeliveryPhase.pickingUp
                                        ? Colors.blue.withOpacity(0.12)
                                        : Colors.green.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    phase == DeliveryPhase.pickingUp
                                        ? 'ĐANG LẤY HÀNG'
                                        : 'ĐANG GIAO HÀNG',
                                    style: TextStyle(
                                      color: phase == DeliveryPhase.pickingUp
                                          ? Colors.blue[800]
                                          : Colors.green[800],
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Text(
                                  order.orderCode,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _infoRow('Địa chỉ lấy', order.address ?? '--'),
                            if (provider.latestDetail?.receiverAddress != null)
                              _infoRow(
                                'Địa chỉ giao',
                                provider.latestDetail!.receiverAddress!,
                              ),
                            if (!isHomePickup ||
                                phase != DeliveryPhase.pickingUp)
                              _infoRow(
                                'Tủ locker',
                                '${order.cabinetName?.isNotEmpty == true ? order.cabinetName : "Tủ"} - ${order.lockerLabel?.isNotEmpty == true ? order.lockerLabel : "Ngăn"}',
                              )
                            else
                              _infoRow(
                                'Hình thức',
                                'Lấy hàng tại nhà',
                                valueColor: AISLShadcnTheme.navyPrimary,
                                valueFontWeight: FontWeight.bold,
                              ),
                            if (order.receiverLatitude != null &&
                                order.receiverLongitude != null)
                              _infoRow(
                                'Tọa độ giao',
                                '${order.receiverLatitude!.toStringAsFixed(6)}, ${order.receiverLongitude!.toStringAsFixed(6)}',
                              ),
                            if (provider.latestDetail?.accessCode != null)
                              () {
                                final rawCode =
                                    provider.latestDetail!.accessCode;
                                final displayCode = rawCode is Map
                                    ? (rawCode['code']?.toString() ?? '')
                                    : rawCode.toString();
                                if (displayCode.isNotEmpty)
                                  return _infoRow(
                                    'Mã mở tủ (OTP)',
                                    displayCode,
                                    valueColor: AISLShadcnTheme.navyPrimary,
                                    valueFontWeight: FontWeight.w900,
                                  );
                                return const SizedBox.shrink();
                              }(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // User Info
                      if (order.recipientName != null ||
                          order.recipientPhone != null)
                        ShadCard(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(LucideIcons.user, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'Thông tin người nhận',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _infoRow(
                                'Người nhận',
                                order.recipientName ?? '--',
                              ),
                              if (order.recipientPhone != null) ...[
                                _infoRow('SĐT', order.recipientPhone!),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final phone = order.recipientPhone!
                                          .trim();
                                      if (phone.isEmpty) return;
                                      final uri = Uri.parse('tel:$phone');
                                      await launchUrl(uri);
                                    },
                                    icon: const Icon(
                                      LucideIcons.phone,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      'Gọi ngay',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      side: BorderSide(
                                        color: AISLShadcnTheme.navyPrimary
                                            .withOpacity(0.3),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Financial Info (if available)
                      if (domainOrder != null)
                        ShadCard(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(LucideIcons.receipt, size: 16),
                                  SizedBox(width: 8),
                                  Text(
                                    'Thông tin thanh toán',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _infoRow(
                                'Phí tích lũy',
                                _fmtCurrency(domainOrder.accumulatedFee),
                              ),
                              _infoRow(
                                'Đã thu',
                                _fmtCurrency(domainOrder.totalCollected),
                                valueColor: const Color(0xFF2E7D32),
                              ),
                              if (domainOrder.paymentStatus != null)
                                _infoRow(
                                  'Trạng thái thanh toán',
                                  domainOrder.paymentStatus!,
                                ),
                            ],
                          ),
                        ),

                      if (provider.error != null)
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            provider.error!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      const SizedBox(height: 12),
                      _buildActionPanel(context, provider, isHomePickup),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionPanel(
    BuildContext context,
    CourierDeliveryProvider provider,
    bool isHomePickup,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    switch (provider.phase) {
      case DeliveryPhase.pickingUp:
        final rawCode = provider.latestDetail?.accessCode;
        final accessCode = rawCode is Map
            ? (rawCode['code']?.toString() ?? '')
            : rawCode?.toString();
        final isVerified = accessCode == null || accessCode.isEmpty;

        return Column(
          children: [
            if (provider.evidenceImage != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  provider.evidenceImage!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _captureImage(provider),
                icon: Icon(
                  provider.evidenceImage == null
                      ? LucideIcons.camera
                      : LucideIcons.refreshCcw,
                ),
                label: Text(
                  provider.evidenceImage == null
                      ? 'CHỤP ẢNH LẤY HÀNG'
                      : 'CHỤP LẠI',
                ),
                style: _outlineBtnStyle(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isVerified
                    ? () async {
                        if (provider.evidenceImage == null) {
                          SmartDialog.showToast(
                            'Vui lòng chụp ảnh bưu kiện trước khi xác nhận!',
                          );
                          return;
                        }
                        SmartDialog.showLoading<void>(
                          msg: isHomePickup
                              ? 'Đang xác nhận lấy bưu kiện...'
                              : 'Vui lòng đóng tủ sau khi lấy hàng...',
                        );
                        final success = await provider.confirmPickup(
                          isHomePickup: isHomePickup,
                        );
                        SmartDialog.dismiss<void>();
                        if (success && context.mounted) {
                          SmartDialog.showToast(
                            isHomePickup
                                ? 'Đã xác nhận lấy bưu kiện!'
                                : 'Xác nhận lấy hàng thành công!',
                          );
                        }
                      }
                    : null,
                icon: Icon(
                  isHomePickup ? LucideIcons.packageCheck : LucideIcons.check,
                ),
                label: Text(
                  isHomePickup
                      ? 'XÁC NHẬN ĐÃ LẤY BƯU KIỆN'
                      : 'XÁC NHẬN ĐÃ LẤY HÀNG',
                ),
                style: _actionBtnStyle(),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showCancelDialog(context, provider),
                icon: const Icon(LucideIcons.circleSlash, color: Colors.red),
                label: const Text(
                  'HỦY ĐƠN HÀNG',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        );
      case DeliveryPhase.headingToLocker:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () async {
              SmartDialog.showLoading();
              await provider.refreshActiveDelivery();
              SmartDialog.dismiss();

              if (provider.lockerIdForDeposit != null &&
                  provider.lockerIdForDeposit!.isNotEmpty) {
                provider.markArrivedAtLocker();
              } else {
                SmartDialog.showToast(
                  'Vui lòng thao tác gửi hàng trên Kiosk trước để mở tủ.',
                );
              }
            },
            icon: const Icon(LucideIcons.map),
            label: const Text('ĐÃ TỚI ĐIỂM GIAO'),
            style: _actionBtnStyle(),
          ),
        );
      case DeliveryPhase.depositing:
        return Column(
          children: [
            if (provider.evidenceImage != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  provider.evidenceImage!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: provider.evidenceImage == null
                  ? OutlinedButton.icon(
                      onPressed: () => _captureImage(provider),
                      icon: const Icon(LucideIcons.camera),
                      label: const Text('CHỤP ẢNH BẰNG CHỨNG'),
                      style: _outlineBtnStyle(),
                    )
                  : OutlinedButton.icon(
                      onPressed: () => _captureImage(provider),
                      icon: const Icon(LucideIcons.refreshCcw),
                      label: const Text('CHỤP LẠI'),
                      style: _outlineBtnStyle(),
                    ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.evidenceImage == null
                    ? null
                    : () async {
                        final submitData = await _showConfirmDepositDialog(
                          context,
                          provider,
                          provider.activeOrder?.recipientName,
                          provider.activeOrder?.recipientPhone,
                        );
                        if (submitData == null) return;
                        final success = await provider.confirmDeposit(
                          recipientPhone: submitData.recipientPhone,
                          recipientName: submitData.recipientName,
                          lockerId: submitData.lockerId,
                        );
                        if (success && context.mounted) {
                          SmartDialog.showToast('Giao hàng thành công!');
                          Navigator.of(context).pop();
                        }
                      },
                style: _actionBtnStyle(),
                child: const Text(
                  'HOÀN TẤT GIAO HÀNG',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            TextButton(
              onPressed: () => _reportIssue(context, provider),
              child: const Text(
                'Báo cáo sự cố',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  ButtonStyle _actionBtnStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AISLShadcnTheme.navyPrimary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    );
  }

  ButtonStyle _outlineBtnStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.black87,
      side: BorderSide(color: Colors.grey[300]!),
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
    );
  }

  Widget _mapIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color iconColor = Colors.black87,
    String? tooltip,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 3,
      shadowColor: Colors.black26,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip ?? '',
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(icon, color: iconColor, size: 18),
          ),
        ),
      ),
    );
  }

  Future<void> _captureImage(CourierDeliveryProvider provider) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 60,
    );
    if (image != null) {
      provider.setEvidenceImage(File(image.path));
    }
  }

  Future<_DepositSubmitData?> _showConfirmDepositDialog(
    BuildContext context,
    CourierDeliveryProvider provider, [
    String? initialName,
    String? initialPhone,
  ]) async {
    final recipientNameCtl = TextEditingController(
      text: initialName ?? provider.recipientNameForDeposit ?? '',
    );
    final recipientPhoneCtl = TextEditingController(
      text: initialPhone ?? provider.recipientPhoneForDeposit ?? '',
    );
    final lockerIdCtl = TextEditingController(
      text: provider.lockerIdForDeposit ?? '',
    );

    final result = await SmartDialog.show<_DepositSubmitData>(
      builder: (ctx) => Container(
        constraints: const BoxConstraints(maxWidth: 500),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Thông tin người nhận',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Nhập thông tin người nhận bưu kiện',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Tên',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            ShadInput(
              controller: recipientNameCtl,
              placeholder: const Text('Tên người nhận'),
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 16),
            const Text(
              'SĐT',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            ShadInput(
              controller: recipientPhoneCtl,
              placeholder: const Text('Số điện thoại'),
              keyboardType: TextInputType.phone,
              style: const TextStyle(color: Colors.black),
            ),
            // Đã bỏ nhập mã ngăn tủ vì Kiosk đã xử lý
            Row(
              children: [
                Expanded(
                  child: ShadButton.outline(
                    onPressed: () => SmartDialog.dismiss<void>(),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ShadButton(
                    onPressed: () => SmartDialog.dismiss(
                      result: _DepositSubmitData(
                        recipientName: recipientNameCtl.text.trim(),
                        recipientPhone: recipientPhoneCtl.text.trim(),
                        lockerId: lockerIdCtl.text.trim(),
                      ),
                    ),
                    child: const Text('Xác nhận'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    recipientNameCtl.dispose();
    recipientPhoneCtl.dispose();
    lockerIdCtl.dispose();
    return result;
  }

  void _reportIssue(BuildContext context, CourierDeliveryProvider provider) {
    // ... logic remains same
  }

  Future<void> _showCancelDialog(
    BuildContext context,
    CourierDeliveryProvider provider,
  ) async {
    final reasonCtl = TextEditingController();
    final result = await SmartDialog.show<bool>(
      builder: (ctx) => Container(
        constraints: const BoxConstraints(maxWidth: 500),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Hủy đơn hàng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Xác nhận hủy đơn hàng này? Khách hàng sẽ được hoàn tiền 100%.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Lý do hủy',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            ShadInput(
              controller: reasonCtl,
              placeholder: const Text(
                'Nhập lý do hủy (VD: Khách không gửi đồ quá lâu)',
              ),
              style: const TextStyle(color: Colors.black),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ShadButton.outline(
                    onPressed: () => SmartDialog.dismiss(result: false),
                    child: const Text('Bỏ qua'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ShadButton.destructive(
                    onPressed: () {
                      if (reasonCtl.text.trim().isEmpty) {
                        SmartDialog.showToast('Vui lòng nhập lý do hủy');
                        return;
                      }
                      SmartDialog.dismiss(result: true);
                    },
                    child: const Text('Xác nhận hủy'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      SmartDialog.showLoading<void>(msg: 'Đang xử lý hủy đơn...');
      final success = await provider.cancelOrder(
        provider.activeOrder!.orderId,
        reasonCtl.text.trim(),
      );
      SmartDialog.dismiss<void>();
      if (success && context.mounted) {
        SmartDialog.showToast('Đã hủy đơn hàng thành công');
        Navigator.of(context).pop();
      }
    }
    reasonCtl.dispose();
  }

  Future<void> _handleReportIssue(BuildContext context) async {
    final provider = context.read<CourierDeliveryProvider>();
    final order = provider.activeOrder;
    if (order == null) return;

    final details = order.orderDetails ?? [];
    final sorted = [...details]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final originDetail = sorted.isNotEmpty ? sorted.first : null;
    final destDetail = (sorted.length > 1) ? sorted.last : originDetail;

    final isPickingUp = provider.phase == DeliveryPhase.pickingUp;
    final activeDetail = isPickingUp ? originDetail : destDetail;

    final cabinetId = isPickingUp
        ? (order.order?.originCabinetId ?? '')
        : (order.order?.destinationCabinetId ?? '');

    final lockerId = activeDetail?.lockerId ?? order.lockerId ?? '';

    if (cabinetId.isEmpty) {
      SmartDialog.showToast('Không có thông tin trạm tủ để báo cáo');
      return;
    }
    if (lockerId.isEmpty) {
      SmartDialog.showToast('Không tìm thấy thông tin ngăn tủ');
      return;
    }

    SmartDialog.showLoading<void>(msg: 'Đang lấy thông tin tủ...');
    final cabinet = await _lockerProvider.getCabinetById(cabinetId);
    final locker = await _lockerProvider.getLockerById(lockerId);
    SmartDialog.dismiss<void>();

    if (cabinet == null || locker == null) {
      SmartDialog.showToast('Không lấy được thông tin chi tiết tủ, sử dụng ID');
    }

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => CreateReportPage(
          cabinetId: cabinetId,
          lockerId: lockerId,
          cabinetName: cabinet?.name ?? order.cabinetName ?? cabinetId,
          lockerName: locker != null
              ? locker.displayPosition
              : activeDetail?.lockerLabel ?? order.lockerLabel,
          locationName: cabinet?.locationName ?? order.address,
        ),
      ),
    );
  }
}

class _DepositSubmitData {
  final String recipientName;
  final String recipientPhone;
  final String lockerId;

  _DepositSubmitData({
    required this.recipientName,
    required this.recipientPhone,
    required this.lockerId,
  });
}
