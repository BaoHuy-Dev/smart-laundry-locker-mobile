import 'dart:async';
import 'package:smart_laundry_locker/features/courier_dispatch/presentation/providers/courier_dispatch_provider.dart';
import 'package:smart_laundry_locker/features/courier_delivery/presentation/providers/courier_delivery_provider.dart';
import 'package:smart_laundry_locker/features/logistics_send/presentation/providers/logistics_send_providers.dart';
import 'package:smart_laundry_locker/core/services/token_service.dart';
import 'package:smart_laundry_locker/core/errors/failures.dart';
import 'package:dartz/dartz.dart' as dartz;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:smart_laundry_locker/core/routing/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_laundry_locker/core/theme/shadcn_theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class FindingCourierSheet extends ConsumerStatefulWidget {
  final String dispatchId;
  final void Function(String orderId) onCourierFound;

  const FindingCourierSheet({
    super.key,
    required this.dispatchId,
    required this.onCourierFound,
  });

  @override
  ConsumerState<FindingCourierSheet> createState() =>
      _FindingCourierSheetState();
}

class _FindingCourierSheetState extends ConsumerState<FindingCourierSheet> {
  StreamSubscription<Map<String, dynamic>>? _subscription;
  Timer? _pollTimer;
  Timer? _countdownTimer;
  Map<String, dynamic>? _courierData;
  bool _found = false;
  int _timerSeconds = 30;
  String _failureMessage = '';
  bool _isCancelled = false;
  bool _isTimeout = false;
  String? _effectiveDispatchId;

  @override
  void initState() {
    super.initState();
    _effectiveDispatchId = widget.dispatchId;
    _initializeId();
  }

  Future<void> _initializeId() async {
    if (_effectiveDispatchId == null || _effectiveDispatchId!.isEmpty) {
      final savedId = await TokenService.getActiveDispatchId();
      if (savedId != null && savedId.isNotEmpty) {
        if (mounted) {
          setState(() {
            _effectiveDispatchId = savedId;
          });
          debugPrint('FindingCourierSheet: Loaded saved dispatchId: $savedId');
          _startOperations();
        }
      } else {
        debugPrint(
          'FindingCourierSheet WARNING: No dispatchId provided and none found in storage',
        );
        _startOperations();
      }
    } else {
      _startOperations();
    }
  }

  void _startOperations() {
    final provider = legacy_provider.Provider.of<CourierDispatchProvider>(
      context,
      listen: false,
    );
    provider.ensureSocketConnected();

    _listenToCourierFound();
    _startPolling();
    _startCountdown();

    // Verify session after a short delay to allow connection
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) provider.verifySocketSession();
    });
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _found || _isCancelled || _isTimeout) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _isTimeout = true;
          _failureMessage =
              'Không tìm thấy tài xế trong phạm vi. Vui lòng thử lại sau.';
          timer.cancel();
          _pollTimer?.cancel();
        }
      });
    });
  }

  void _listenToCourierFound() {
    final provider = legacy_provider.Provider.of<CourierDispatchProvider>(
      context,
      listen: false,
    );
    _subscription = provider.courierAcceptedStream.listen((event) {
      debugPrint('RECEIVED: courierAcceptedStream event: $event');
      final eventId = event['dispatchId']?.toString();
      if (eventId == _effectiveDispatchId &&
          _effectiveDispatchId != null &&
          _effectiveDispatchId!.isNotEmpty) {
        debugPrint(
          'MATCH: Courier accepted via WebSocket for $_effectiveDispatchId',
        );
        _onCourierAccepted(event);
        TokenService.clearActiveDispatchId();
      } else {
        debugPrint(
          'MISMATCH: event dispatchId $eventId != local $_effectiveDispatchId',
        );
      }
    });
  }

  void _onCourierAccepted(Map<String, dynamic> event) {
    if (_found || !mounted) return;
    _found = true;
    _pollTimer?.cancel();

    final orderId = event['orderId']?.toString() ?? '';
    setState(() {
      _courierData = event;
    });

    // Tự động chuyển hướng sau 1.5 giây để người dùng thấy thông tin tài xế
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onCourierFound(orderId);
      }
    });
  }

  void _startPolling() {
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      if (_found || !mounted) return;
      try {
        final useCase = ref.read(getDispatchStatusUseCaseProvider);
        if (_effectiveDispatchId == null || _effectiveDispatchId!.isEmpty)
          return;
        final result = await useCase.execute(_effectiveDispatchId!);

        if (_found || !mounted) return;

        result.fold(
          (failure) =>
              debugPrint('FindingCourierSheet poll error: ${failure.message}'),
          (entity) {
            final status = entity.status.toUpperCase();
            debugPrint(
              'FindingCourierSheet poll status for $_effectiveDispatchId: $status',
            );

            // Updated: Both ACCEPTED and COMPLETED mean a driver was/is processed
            if (status == 'ACCEPTED' || status == 'COMPLETED') {
              _onCourierAccepted({
                'dispatchId': widget.dispatchId,
                'courierId': entity.courierId,
                'courierName': entity.courierName,
                'courierPhone': entity.courierPhone,
                'orderCode': entity.orderCode,
                'orderId': entity.orderId,
              });
            } else if (status == 'CANCELLED') {
              _onCourierCancelled();
            }
          },
        );
      } catch (e) {
        debugPrint('FindingCourierSheet poll error: $e');
      }
    });
  }

  void _onCourierCancelled() {
    if (_isCancelled || _found || !mounted) return;
    setState(() {
      _isCancelled = true;
      _failureMessage = 'Tài xế đã hủy hoặc đơn hàng không còn hiệu lực.';
    });
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _pollTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _onCancel() async {
    bool? confirmed;
    await SmartDialog.show<void>(
      builder: (context) => Container(
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
              'Hủy tìm tài xế?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Đơn hàng của bạn sẽ không được gửi đi nếu bạn hủy vào lúc này.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ShadButton.ghost(
                    child: const Text('Quay lại'),
                    onPressed: () {
                      confirmed = false;
                      SmartDialog.dismiss<void>();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ShadButton.destructive(
                    child: const Text('Xác nhận hủy'),
                    onPressed: () {
                      confirmed = true;
                      SmartDialog.dismiss<void>();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      if (!mounted) return;
      SmartDialog.showLoading<void>(msg: 'Đang hủy...');
      final deliveryProvider = legacy_provider
          .Provider.of<CourierDeliveryProvider>(context, listen: false);

      if (_effectiveDispatchId == null || _effectiveDispatchId!.isEmpty) return;
      final dartz.Either<Failure, bool> result = await deliveryProvider
          .cancelDispatch(_effectiveDispatchId!);

      TokenService.clearActiveDispatchId();
      SmartDialog.dismiss<void>();

      result.fold(
        (failure) => SmartDialog.showToast('Lỗi: ${failure.message}'),
        (success) {
          if (success) {
            SmartDialog.showToast('Đã hủy tìm kiếm');
            if (mounted) {
              Navigator.of(context).pop();
            }
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_courierData != null) {
      return _buildCourierFound();
    }

    if (_isCancelled || _isTimeout) {
      return _buildFailureState();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: _timerSeconds / 120, // Match new timeout
                  strokeWidth: 6,
                  color: AISLShadcnTheme.navyPrimary,
                  backgroundColor: const Color(0xFF0A2342).withOpacity(0.1),
                ),
              ),
              Text(
                '${_timerSeconds}s',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AISLShadcnTheme.navyPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Đang tìm tài xế...',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AISLShadcnTheme.navyPrimary.withOpacity(0.9),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Hệ thống đang kết nối với các tài xế gần trạm của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ShadButton.destructive(
              onPressed: _onCancel,
              child: const Text('Hủy yêu cầu'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFailureState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Icon(
            Icons.error_outline_rounded,
            color: Colors.redAccent,
            size: 64,
          ),
          const SizedBox(height: 24),
          Text(
            _isCancelled ? 'Đã hủy tìm kiếm' : 'Tìm kiếm thất bại',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _failureMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ShadButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCourierFound() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 24),
          const Text(
            'Đã tìm thấy tài xế!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _courierData!['courierName']?.toString() ?? 'Tài xế',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        _courierData!['courierPhone']?.toString() ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ShadButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onCourierFound(
                  _courierData?['orderId']?.toString() ?? '',
                );
              },
              child: const Text('Xem đơn hàng của bạn'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ShadButton.outline(
              onPressed: () {
                final orderId = _courierData?['orderId']?.toString() ?? '';
                Navigator.of(context).pop();
                final navContext = AppRouter.navigatorKey.currentContext;
                if (navContext == null) return;
                navContext.go(AppRouter.orders);
                if (orderId.isNotEmpty) {
                  navContext.pushNamed('order_detail', extra: orderId);
                }
              },
              child: const Text('Đi tới chi tiết đơn hàng'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
