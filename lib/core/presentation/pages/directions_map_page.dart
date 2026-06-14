import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:smart_laundry_locker/core/theme/shadcn_theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// Reusable in-app directions screen: draws a driving route from the user's
/// current location to [destination] on an OpenStreetMap map (via the public
/// OSRM router), with a fallback to the native maps app for turn-by-turn.
///
/// Used by the stores and locker flows when the user taps "Chỉ đường".
class DirectionsMapPage extends StatefulWidget {
  const DirectionsMapPage({
    required this.destination,
    required this.title,
    this.subtitle,
    super.key,
  });

  final LatLng destination;
  final String title;
  final String? subtitle;

  @override
  State<DirectionsMapPage> createState() => _DirectionsMapPageState();
}

class _DirectionsMapPageState extends State<DirectionsMapPage> {
  final MapController _mapController = MapController();

  LatLng? _me;
  List<LatLng> _routePoints = const [];
  double? _distanceMeters;
  double? _durationSeconds;
  bool _loading = true;
  String? _hint;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    final me = await _currentLocation();
    if (!mounted) return;
    setState(() => _me = me);
    if (me != null) {
      await _fetchRoute(me, widget.destination);
      _fitBounds(me, widget.destination);
    } else {
      setState(
        () => _hint = 'Không lấy được vị trí của bạn — chỉ hiển thị tủ.',
      );
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<LatLng?> _currentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }
      final pos = await Geolocator.getCurrentPosition();
      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      return null;
    }
  }

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/'
          '${start.longitude},${start.latitude};'
          '${end.longitude},${end.latitude}'
          '?overview=full&geometries=polyline';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final routes = data['routes'] as List?;
        if (routes != null && routes.isNotEmpty) {
          final route = routes.first as Map<String, dynamic>;
          final points = _decodePolyline(route['geometry'] as String);
          if (!mounted) return;
          setState(() {
            _routePoints = points;
            _distanceMeters = (route['distance'] as num?)?.toDouble();
            _durationSeconds = (route['duration'] as num?)?.toDouble();
          });
        }
      }
    } catch (_) {
      // Route is best-effort; the destination marker still shows.
    }
  }

  Future<void> _openExternal() async {
    final lat = widget.destination.latitude;
    final lng = widget.destination.longitude;
    final googleMaps = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$lat,$lng&travelmode=driving',
    );
    final appleMaps = Uri.parse(
      'https://maps.apple.com/?daddr=$lat,$lng&dirflg=d',
    );
    if (await canLaunchUrl(googleMaps)) {
      await launchUrl(googleMaps, mode: LaunchMode.externalApplication);
    } else if (await canLaunchUrl(appleMaps)) {
      await launchUrl(appleMaps, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không mở được ứng dụng bản đồ.')),
      );
    }
  }

  void _fitBounds(LatLng a, LatLng b) {
    final bounds = LatLngBounds(
      LatLng(
        a.latitude < b.latitude ? a.latitude : b.latitude,
        a.longitude < b.longitude ? a.longitude : b.longitude,
      ),
      LatLng(
        a.latitude > b.latitude ? a.latitude : b.latitude,
        a.longitude > b.longitude ? a.longitude : b.longitude,
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉ đường'),
        backgroundColor: AISLShadcnTheme.navyPrimary,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.destination,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                  if (_me != null)
                    Marker(
                      point: _me!,
                      width: 40,
                      height: 40,
                      child: const Icon(
                        LucideIcons.navigation,
                        color: Colors.blue,
                        size: 28,
                      ),
                    ),
                  Marker(
                    point: widget.destination,
                    width: 44,
                    height: 44,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (_loading)
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 10),
                        Text('Đang tìm đường...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Align(alignment: Alignment.bottomCenter, child: _buildInfoCard()),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          if ((widget.subtitle ?? '').isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              widget.subtitle!,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
          if (_distanceMeters != null && _durationSeconds != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  LucideIcons.route,
                  size: 16,
                  color: AISLShadcnTheme.navyAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  '${(_distanceMeters! / 1000).toStringAsFixed(1)} km'
                  '  ·  ~${(_durationSeconds! / 60).round()} phút',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ] else if (_hint != null) ...[
            const SizedBox(height: 6),
            Text(
              _hint!,
              style: const TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openExternal,
              style: FilledButton.styleFrom(
                backgroundColor: AISLShadcnTheme.navyPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(LucideIcons.navigation, size: 18),
              label: const Text('Mở dẫn đường trên Google Maps'),
            ),
          ),
        ],
      ),
    );
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0;
    final len = encoded.length;
    var lat = 0;
    var lng = 0;

    while (index < len) {
      int b;
      var shift = 0;
      var result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }
}
