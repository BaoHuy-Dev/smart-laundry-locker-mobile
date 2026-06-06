import 'package:smart_laundry_locker/shared/widgets/location_picker.dart';
import 'package:smart_laundry_locker/features/locker/domain/entities/locker_location.dart';
import 'package:smart_laundry_locker/core/routing/app_router.dart';
import 'package:smart_laundry_locker/core/theme/shadcn_theme.dart';
import 'package:smart_laundry_locker/core/enums/app_enums.dart';
import 'dart:math' as math;
import 'package:smart_laundry_locker/features/locker/domain/value_objects/locker_status.dart';
import 'package:smart_laundry_locker/features/locker/presentation/pages/confirm_rent_page.dart';
import 'package:smart_laundry_locker/features/locker/presentation/providers/locker_provider.dart';
import 'package:smart_laundry_locker/features/locker/presentation/providers/locker_providers.dart';
import 'package:smart_laundry_locker/features/subscription/domain/entities/plan_entity.dart';
import 'package:smart_laundry_locker/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/entities/send_package_request.dart';
import 'package:smart_laundry_locker/features/logistics_send/presentation/providers/logistics_send_providers.dart';
import 'package:smart_laundry_locker/features/vouchers/presentation/providers/voucher_provider.dart';
import 'package:smart_laundry_locker/features/vouchers/data/models/voucher_model.dart';
import 'package:smart_laundry_locker/shared/widgets/custom_input.dart';
import 'package:smart_laundry_locker/features/logistics_send/domain/params/logistics_success_load_params.dart';
import 'package:smart_laundry_locker/features/logistics_send/presentation/widgets/finding_courier_sheet.dart';
import 'package:smart_laundry_locker/features/subscription/domain/entities/subscription_entity.dart';
import 'package:smart_laundry_locker/injection_container.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/core/services/token_service.dart';
import 'package:smart_laundry_locker/features/orders/domain/entities/order.dart'
    as order_entity;
import 'package:smart_laundry_locker/features/orders/presentation/providers/order_injection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:smart_laundry_locker/features/delegations/presentation/providers/delegation_providers.dart';
import 'package:smart_laundry_locker/features/profile/domain/entities/user_profile.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:intl/intl.dart';

enum LockerAction { rent, send }

class LockerActionPage extends ConsumerStatefulWidget {
  final LockerAction action;
  final int initialStep;
  final String? initialLocationId;
  final String? initialCabinetId;
  final String? initialSizeId;

  const LockerActionPage({
    super.key,
    required this.action,
    this.initialStep = 0,
    this.initialLocationId,
    this.initialCabinetId,
    this.initialSizeId,
  });

  @override
  ConsumerState<LockerActionPage> createState() => _LockerActionPageState();
}

class _LockerActionPageState extends ConsumerState<LockerActionPage> {
  String? _selectedLocationId;
  String? _selectedCabinetId;
  String? _selectedSizeId;
  String? _selectedLockerId;

  final _receiverNameController = TextEditingController();
  final _receiverPhoneController = TextEditingController();
  final _receiverAddressController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedItemType = 'OTHER';

  int _currentStep = 0;
  int _previousStep = 0;
  bool _locationVisible = false;

  // Home Pickup State
  bool _isHomePickup = false;
  final _pickupAddressController = TextEditingController();
  double? _pickupLatitude;
  double? _pickupLongitude;

  UserProfile? _foundUser;
  bool _isSearchingPhone = false;

  // Subscription Plan Info
  SubscriptionEntity? _activeSubscription;
  String? _activePlanName;
  List<order_entity.Order> _activeOrders = [];

  LockerLocation? _selectedReceiverLocation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _currentStep = widget.initialStep.clamp(0, 4);
      _previousStep = _currentStep;

      _selectedLocationId = widget.initialLocationId ?? _selectedLocationId;
      _selectedCabinetId = widget.initialCabinetId ?? _selectedCabinetId;
      _selectedSizeId = widget.initialSizeId ?? _selectedSizeId;

      ref.read(lockerNotifierProvider).getLocations();
      ref
          .read(lockerNotifierProvider)
          .getPricings(orderType: 'PERSONAL_RENTAL');
      legacy_provider.Provider.of<WalletProvider>(
        context,
        listen: false,
      ).getWalletBalance();

      // Nếu vào thẳng bước 2, chủ động trigger data chain để có danh sách ngăn
      if (_selectedLocationId != null) {
        ref
            .read(lockerNotifierProvider)
            .getCustomerCabinets(_selectedLocationId!);
      }
      if (_selectedCabinetId != null) {
        ref
            .read(lockerNotifierProvider)
            .getLockerCountBySize(cabinetId: _selectedCabinetId!);
      }
      if (_selectedCabinetId != null && _selectedSizeId != null) {
        ref
            .read(lockerNotifierProvider)
            .getLeastUsedLockers(_selectedCabinetId!, sizeId: _selectedSizeId);
      }
      _fetchActivePlan();
      _fetchActiveOrders();

      setState(() {
        _locationVisible = true;
      });
    });
  }

  Future<void> _fetchActiveOrders() async {
    try {
      final repository = OrderInjection.provideOrderRepository(ApiClient());
      final result = await repository.getMyActiveOrders();
      result.fold(
        (failure) => null,
        (orders) => setState(() {
          _activeOrders = orders;
        }),
      );
    } catch (e) {
      debugPrint('Error fetching active orders: $e');
    }
  }

  Future<void> _fetchActivePlan() async {
    try {
      final getActiveSubUseCase =
          InjectionContainer.provideGetActiveSubscriptionUseCase(ApiClient());
      final result = await getActiveSubUseCase.call();
      result.fold(
        (failure) => _activePlanName = 'Cơ bản',
        (SubscriptionEntity sub) => setState(() {
          _activeSubscription = sub;
          _activePlanName = sub.plan?.name ?? 'Cơ bản';
        }),
      );
    } catch (e) {
      _activePlanName = 'Cơ bản';
    }
  }

  @override
  void dispose() {
    _receiverNameController.dispose();
    _receiverPhoneController.dispose();
    _receiverAddressController.dispose();
    _noteController.dispose();
    _pickupAddressController.dispose();
    super.dispose();
  }

  Future<void> _onSearchPhone() async {
    final phone = _receiverPhoneController.text.trim();
    if (phone.length < 10) {
      SmartDialog.showToast('Vui lòng nhập ít nhất 10 số');
      return;
    }

    setState(() {
      _isSearchingPhone = true;
      _foundUser = null;
    });

    try {
      final delegationProv = ref.read(delegationProvider);
      final user = await delegationProv.searchUserByPhone(phone);
      setState(() {
        _foundUser = user;
      });
      if (user == null) {
        SmartDialog.showToast('Không tìm thấy thông tin người dùng');
      }
    } catch (e) {
      SmartDialog.showToast('Lỗi khi tìm kiếm: $e');
    } finally {
      setState(() {
        _isSearchingPhone = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(lockerNotifierProvider);
    final state = provider.state;
    final title = 'CHỌN TỦ ĐỒ';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () {
            ref.read(lockerNotifierProvider).clearError();
            if (_currentStep > 0) {
              setState(() {
                _previousStep = _currentStep;
                _currentStep--;
              });
            } else {
              context.pop();
            }
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildStepHeader(),
          const SizedBox(height: 16),
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -8),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                layoutBuilder:
                    (Widget? currentChild, List<Widget> previousChildren) {
                      return Stack(
                        alignment: Alignment.topCenter,
                        children: <Widget>[
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                transitionBuilder: (child, animation) {
                  final isForward = _currentStep >= _previousStep;
                  final offsetAnimation =
                      Tween<Offset>(
                        begin: isForward
                            ? const Offset(1, 0)
                            : const Offset(-1, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );

                  return SlideTransition(
                    position: offsetAnimation,
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: SingleChildScrollView(
                  key: ValueKey(_currentStep),
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_currentStep == 0) ...[
                        if (widget.action == LockerAction.send)
                          _buildLogisticsTypeSelection(),
                        if (!_isHomePickup ||
                            widget.action == LockerAction.rent)
                          _buildLocationSelection(state),
                      ],
                      if (_currentStep == 1) ...[
                        if (_isHomePickup && widget.action == LockerAction.send)
                          _buildPickupAddressStep()
                        else
                          _buildCabinetSelection(state),
                      ],
                      if (_currentStep == 2) ...[
                        if (_isHomePickup && widget.action == LockerAction.send)
                          _buildItemTypeSelection()
                        else
                          _buildLockerSelection(state),
                      ],
                      if (_currentStep == 3) ...[
                        if (_isHomePickup && widget.action == LockerAction.send)
                          _buildInfoForm(provider)
                        else
                          _buildItemTypeSelection(),
                      ],
                      if (_currentStep == 4) ...[
                        if (!_isHomePickup &&
                            widget.action == LockerAction.send)
                          _buildInfoForm(provider),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildFooterControls(state),
        ],
      ),
    );
  }

  Widget _buildStepHeader() {
    final List<String> steps;
    if (widget.action == LockerAction.rent) {
      steps = ['Vị trí', 'Cụm tủ', 'Tủ', 'Loại hàng'];
    } else {
      if (_isHomePickup) {
        steps = ['Dịch vụ', 'Lấy hàng', 'Loại hàng', 'Thông tin'];
      } else {
        steps = ['Vị trí', 'Cụm tủ', 'Tủ', 'Loại hàng', 'Thông tin'];
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                // Line
                final stepIndex = index ~/ 2;
                final isActive = stepIndex < _currentStep;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      height: 2,
                      color: isActive
                          ? const Color(0xFF0A2342).withOpacity(0.7)
                          : const Color(0xFF0A2342).withOpacity(0.3),
                    ),
                  ),
                );
              }

              // Step item
              final stepIndex = index ~/ 2;
              final isActive = stepIndex <= _currentStep;
              final isCurrent = stepIndex == _currentStep;

              final Color circleColor;
              if (isCurrent) {
                circleColor = AISLShadcnTheme.navyPrimary;
              } else if (isActive) {
                circleColor = AISLShadcnTheme.navyPrimary.withOpacity(0.7);
              } else {
                circleColor = Colors.grey[200]!;
              }

              return Flexible(
                child: SizedBox(
                  width: 64,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: circleColor,
                          border: isCurrent
                              ? Border.all(
                                  color: AISLShadcnTheme.navyPrimary
                                      .withOpacity(0.35),
                                  width: 4,
                                )
                              : null,
                          boxShadow: isCurrent
                              ? [
                                  BoxShadow(
                                    color: AISLShadcnTheme.navyPrimary
                                        .withOpacity(0.45),
                                    blurRadius: 16,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: isActive && stepIndex < _currentStep
                              ? const Icon(
                                  Icons.check,
                                  size: 18,
                                  color: Colors.white,
                                )
                              : Text(
                                  '${stepIndex + 1}',
                                  style: TextStyle(
                                    color: isActive
                                        ? Colors.white
                                        : Colors.black54,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        steps[stepIndex],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isActive ? Colors.black : Colors.black38,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 64),
          child: LinearProgressIndicator(
            value: ((_currentStep + 1) / steps.length).clamp(0.0, 1.0),
            minHeight: 2,
            color: const Color(0xFF0A2342).withOpacity(0.7),
            backgroundColor: const Color(0xFF0A2342).withOpacity(0.15),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterControls(LockerState state) {
    final isLastStep = widget.action == LockerAction.rent
        ? _currentStep == 3
        : (_isHomePickup ? _currentStep == 3 : _currentStep == 4);
    final canContinue =
        (_currentStep == 0 &&
            ((widget.action == LockerAction.rent || !_isHomePickup)
                ? _selectedLocationId != null
                : true)) ||
        (_isHomePickup &&
            _currentStep == 1 &&
            _pickupAddressController.text.trim().isNotEmpty) ||
        (_isHomePickup && _currentStep == 2) ||
        (_isHomePickup && _currentStep == 3) ||
        (!_isHomePickup &&
            widget.action == LockerAction.send &&
            _currentStep == 1 &&
            _selectedCabinetId != null &&
            _selectedSizeId != null) ||
        (!_isHomePickup &&
            widget.action == LockerAction.send &&
            _currentStep == 2 &&
            _selectedLockerId != null) ||
        (!_isHomePickup &&
            widget.action == LockerAction.send &&
            _currentStep == 3) ||
        (!_isHomePickup &&
            widget.action == LockerAction.send &&
            _currentStep == 4) ||
        (widget.action == LockerAction.rent &&
            _currentStep == 1 &&
            _selectedCabinetId != null &&
            _selectedSizeId != null) ||
        (widget.action == LockerAction.rent &&
            _currentStep == 2 &&
            _selectedLockerId != null) ||
        (widget.action == LockerAction.rent && _currentStep == 3);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: canContinue ? _onStepContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E5A8A),
              minimumSize: const Size.fromHeight(56),
              shape: const StadiumBorder(),
              elevation: 4,
              shadowColor: const Color(0xFF1E5A8A).withOpacity(0.4),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLastStep && widget.action == LockerAction.rent) ...[
                  const Icon(Icons.lock_outline, size: 20),
                  const SizedBox(width: 10),
                ],
                Text(
                  isLastStep && widget.action == LockerAction.rent
                      ? 'Thuê tủ'
                      : 'Tiếp tục',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onStepContinue() {
    if (_isHomePickup && widget.action == LockerAction.send) {
      _handleHomePickupContinue();
    } else {
      _handleStandardContinue();
    }
  }

  void _handleHomePickupContinue() {
    if (_currentStep == 0) {
      // Step 0: Service type selection (always true if we got here)
    } else if (_currentStep == 1) {
      // Step 1: Pickup Address (handled by canContinue)
    } else if (_currentStep == 2) {
      // Step 2: Item Type
    } else if (_currentStep == 3) {
      // Step 3: Recipient Info
      _handleConfirmation();
      return;
    }

    setState(() {
      _previousStep = _currentStep;
      _currentStep++;
    });
  }

  void _handleStandardContinue() {
    if (_currentStep == 0 && _selectedLocationId != null) {
      ref
          .read(lockerNotifierProvider)
          .getCustomerCabinets(_selectedLocationId!);
    } else if (_currentStep == 1 &&
        _selectedCabinetId != null &&
        _selectedSizeId != null) {
      ref
          .read(lockerNotifierProvider)
          .getLeastUsedLockers(_selectedCabinetId!, sizeId: _selectedSizeId);
    } else if (_currentStep == 2 && _selectedLockerId != null) {
      // Choose locker
    } else if (_currentStep == 3) {
      if (widget.action == LockerAction.rent) {
        _handleConfirmation();
        return;
      }
      // Logistics: Item type
    } else if (_currentStep == 4) {
      _handleConfirmation();
      return;
    }

    setState(() {
      _previousStep = _currentStep;
      _currentStep++;
    });
  }

  void _handleConfirmation() async {
    if (widget.action == LockerAction.rent) {
      _showRentTypeSelection();
    } else {
      final provider = ref.read(lockerNotifierProvider);
      final st = provider.state;
      var cabinet = st.selectedCabinet;
      if (cabinet == null && _selectedCabinetId != null) {
        for (final c in st.cabinets) {
          if (c.id == _selectedCabinetId) {
            cabinet = c;
            break;
          }
        }
      }
      var location = st.selectedLocation;
      if (location == null && _selectedLocationId != null) {
        for (final l in st.locations) {
          if (l.id == _selectedLocationId) {
            location = l;
            break;
          }
        }
      }

      final recipientName = _receiverNameController.text.trim();
      final recipientPhone = _receiverPhoneController.text.trim();
      final receiverAddress = _receiverAddressController.text.trim();
      final noteRaw = _noteController.text.trim();
      final note = noteRaw.isEmpty ? null : noteRaw;

      final lockerId = _selectedLockerId;
      var senderAddress = cabinet?.address?.trim().isNotEmpty == true
          ? cabinet!.address!.trim()
          : location?.address.trim();

      if (recipientName.isEmpty) {
        SmartDialog.showToast('Vui lòng nhập họ tên người nhận.');
        return;
      }
      if (recipientPhone.isEmpty) {
        SmartDialog.showToast('Vui lòng nhập số điện thoại người nhận.');
        return;
      }
      if (receiverAddress.isEmpty) {
        SmartDialog.showToast('Vui lòng nhập địa chỉ người nhận.');
        return;
      }
      if (!_isHomePickup && (lockerId == null || lockerId.trim().isEmpty)) {
        SmartDialog.showToast('Vui lòng chọn tủ đích.');
        return;
      }
      if (!_isHomePickup &&
          (senderAddress == null || senderAddress.trim().isEmpty)) {
        SmartDialog.showToast('Thiếu địa chỉ tủ để tạo yêu cầu gửi.');
        return;
      }

      final itemType = _selectedItemType;

      final request = SendPackageRequest(
        recipientPhone: recipientPhone,
        recipientName: recipientName,
        itemType: itemType,
        lockerId: lockerId,
        senderAddress: _isHomePickup
            ? _pickupAddressController.text.trim()
            : senderAddress!.trim(),
        receiverAddress: receiverAddress,
        note: note,
        logisticsType: _isHomePickup
            ? LogisticsType.HOME_TO_LOCKER
            : LogisticsType.LOCKER_TO_LOCKER,
        pickupAddress: _isHomePickup
            ? _pickupAddressController.text.trim()
            : null,
        pickupLatitude: _isHomePickup ? (_pickupLatitude ?? 10.762622) : null,
        pickupLongitude: _isHomePickup
            ? (_pickupLongitude ?? 106.660172)
            : null,
        receiverLatitude: _selectedReceiverLocation?.coordinate.latitude,
        receiverLongitude: _selectedReceiverLocation?.coordinate.longitude,
      );

      // Load vouchers before showing dialog
      if (context.mounted) {
        legacy_provider.Provider.of<VoucherProvider>(
          context,
          listen: false,
        ).loadMyVouchers(status: 'UNUSED');
      }

      // Thêm modal xác nhận thông tin trước khi call API
      final dialogResult = await _showSendReviewDialog(
        context: context,
        request: request,
      );

      if (dialogResult == null || dialogResult['confirmed'] != true) return;

      final finalRequest = request.copyWith(
        voucherId: dialogResult['voucherId'] as String?,
      );

      SmartDialog.showLoading<void>(msg: 'Đang tạo yêu cầu gửi...');
      final useCase = ref.read(logisticsSendUseCaseProvider);
      final result = await useCase(finalRequest);
      SmartDialog.dismiss<void>();

      result.fold(
        (failure) {
          SmartDialog.showToast(failure.message);
        },
        (resp) {
          // Không hiện toast nữa, hiện ngay sheet tìm tài xế
          if (!mounted) return;
          if (widget.action == LockerAction.send) {
            TokenService.saveActiveDispatchId(resp.dispatchId);
            _showFindingCourierSheet(
              context: context,
              dispatchId: resp.dispatchId,
              orderId: resp.orderId,
              recipientName: recipientName,
              recipientPhone: recipientPhone,
              note: note,
            );
          } else {
            context.pop();
          }
        },
      );
    }
  }

  Future<void> _showFindingCourierSheet({
    required BuildContext context,
    required String dispatchId,
    String? orderId,
    required String recipientName,
    required String recipientPhone,
    String? note,
  }) async {
    showCupertinoModalPopup<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => FindingCourierSheet(
        dispatchId: dispatchId,
        onCourierFound: (newOrderId) {
          if (!mounted) return;
          final loadParams = LogisticsSuccessLoadParams(
            orderId: newOrderId.isNotEmpty ? newOrderId : orderId,
            dispatchId: dispatchId,
            totalCollectedVnd: 0,
            recipientName: recipientName,
            recipientPhone: recipientPhone,
            note: note,
            courierHints: null,
          );
          context.go(AppRouter.shippingSuccess, extra: loadParams);
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> _showSendReviewDialog({
    required BuildContext context,
    required SendPackageRequest request,
  }) async {
    Map<String, dynamic>? result;
    VoucherModel? selectedVoucher;

    await SmartDialog.show<void>(
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          // 1. Get origin coordinates
          double? originLat;
          double? originLon;
          if (request.logisticsType == LogisticsType.HOME_TO_LOCKER) {
            originLat = request.pickupLatitude;
            originLon = request.pickupLongitude;
          } else {
            final lockerState = ref.read(lockerNotifierProvider).state;
            originLat = lockerState.selectedLocation?.coordinate.latitude;
            originLon = lockerState.selectedLocation?.coordinate.longitude;
          }

          // 2. Get destination coordinates
          final double? destLat = request.receiverLatitude;
          final double? destLon = request.receiverLongitude;

          // 3. Calculate distance
          double distance = 0;
          if (originLat != null &&
              originLon != null &&
              destLat != null &&
              destLon != null) {
            const p = 0.017453292519943295;
            final a =
                0.5 -
                math.cos((destLat - originLat) * p) / 2 +
                math.cos(originLat * p) *
                    math.cos(destLat * p) *
                    (1 - math.cos((destLon - originLon) * p)) /
                    2;
            distance = 12742 * math.asin(math.sqrt(a));
          }

          // 4. Find pricing
          final pricing = _activeSubscription?.plan?.pricings.firstWhere(
            (p) => p.orderType == 'LOGISTICS',
            orElse: () => const PricingEntity(
              id: '',
              name: 'Mặc định',
              blockDuration: 1,
              blockUnit: 'KM',
              feePerBlock: 10000,
              lateFeePerBlock: 0,
              orderType: 'LOGISTICS',
              gracePeriod: 0,
            ),
          );

          final double multiplier = distance > 1 ? distance : 1.0;
          final double baseFee = (pricing?.feePerBlock ?? 10000) * multiplier;

          // 5. Calculate voucher discount
          double voucherDiscount = 0;
          if (selectedVoucher != null) {
            if (selectedVoucher!.rewardType == 'DISCOUNT_PERCENT') {
              voucherDiscount = baseFee * (selectedVoucher!.rewardValue / 100);
            } else if (selectedVoucher!.rewardType == 'DISCOUNT_AMOUNT') {
              voucherDiscount = selectedVoucher!.rewardValue;
            }
          }
          final double totalFee = math.max(0, baseFee - voucherDiscount);

          final formatMoney = (double amount) => NumberFormat.currency(
            locale: 'vi_VN',
            symbol: 'đ',
            decimalDigits: 0,
          ).format(amount).replaceAll('\u00a0', ' ');

          return Container(
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
                  'Xác nhận thông tin gửi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Vui lòng kiểm tra kỹ thông tin người nhận.',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildReviewRow('Người nhận', request.recipientName),
                _buildReviewRow('Số điện thoại', request.recipientPhone),
                _buildReviewRow('Địa chỉ', request.receiverAddress),
                _buildReviewRow('Loại hàng', _getItemLabel(request.itemType)),
                if (request.note != null && request.note!.isNotEmpty)
                  _buildReviewRow('Ghi chú', request.note!),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),

                // VOUCHER SELECTOR
                legacy_provider.Consumer<VoucherProvider>(
                  builder: (ctx, voucherProv, _) {
                    return GestureDetector(
                      onTap: () async {
                        final usable = voucherProv.vouchers
                            .where((v) => v.status == 'UNUSED')
                            .toList();
                        if (usable.isEmpty) {
                          SmartDialog.showToast(
                            'Bạn không có voucher khả dụng',
                          );
                          return;
                        }
                        await showModalBottomSheet<void>(
                          context: context,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(24),
                            ),
                          ),
                          builder: (_) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 12),
                              Container(
                                width: 40,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Chọn voucher ưu đãi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (selectedVoucher != null)
                                TextButton(
                                  onPressed: () {
                                    setDialogState(() {
                                      selectedVoucher = null;
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Bỏ chọn',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                ),
                              Flexible(
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  itemCount: usable.length,
                                  itemBuilder: (context, idx) {
                                    final v = usable[idx];
                                    final isSel = selectedVoucher?.id == v.id;
                                    final discText =
                                        v.rewardType == 'DISCOUNT_PERCENT'
                                        ? 'Giảm ${v.rewardValue.toInt()}%'
                                        : 'Giảm ${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0).format(v.rewardValue).replaceAll('\u00a0', ' ')}';
                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      elevation: isSel ? 3 : 0,
                                      color: isSel
                                          ? const Color(0xFFE7F0F8)
                                          : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: isSel
                                              ? const Color(0xFF0A2342)
                                              : Colors.grey.shade300,
                                          width: isSel ? 1.5 : 1,
                                        ),
                                      ),
                                      child: ListTile(
                                        leading: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: const Color(
                                              0xFF0A2342,
                                            ).withValues(alpha: 0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            LucideIcons.ticket,
                                            color: const Color(0xFF0A2342),
                                            size: 20,
                                          ),
                                        ),
                                        title: Text(
                                          v.campaignTitle.isNotEmpty
                                              ? v.campaignTitle
                                              : v.code,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        subtitle: Text(
                                          discText,
                                          style: const TextStyle(
                                            color: const Color(0xFF0A2342),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        trailing: isSel
                                            ? const Icon(
                                                Icons.check_circle,
                                                color: const Color(0xFF0A2342),
                                              )
                                            : null,
                                        onTap: () {
                                          setDialogState(
                                            () => selectedVoucher = v,
                                          );
                                          Navigator.pop(context);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: selectedVoucher != null
                              ? const Color(0xFFE7F0F8)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selectedVoucher != null
                                ? const Color(0xFF8FB4D2)
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.ticketPercent,
                              color: selectedVoucher != null
                                  ? const Color(0xFF0A2342)
                                  : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                selectedVoucher != null
                                    ? (selectedVoucher!.campaignTitle.isNotEmpty
                                          ? selectedVoucher!.campaignTitle
                                          : selectedVoucher!.code)
                                    : 'Chọn voucher giảm giá',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: selectedVoucher != null
                                      ? const Color(0xFF0A2342)
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: Colors.grey.shade400,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // PRICING SUMMARY
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Phí dự kiến:',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      formatMoney(baseFee),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                if (voucherDiscount > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Voucher giảm:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        '- ${formatMoney(voucherDiscount)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.green,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng thanh toán:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      formatMoney(totalFee),
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0A2342),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ShadButton.outline(
                        child: const Text('Chỉnh sửa'),
                        onPressed: () {
                          result = {'confirmed': false};
                          SmartDialog.dismiss<void>();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ShadButton(
                        child: const Text('Gửi ngay'),
                        onPressed: () {
                          result = {
                            'confirmed': true,
                            'voucherId': selectedVoucher?.id,
                          };
                          SmartDialog.dismiss<void>();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
    return result;
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getItemLabel(String type) {
    switch (type) {
      case 'FOOD':
        return 'Đồ ăn';
      case 'CLOTHES':
        return 'Quần áo';
      case 'DOCUMENT':
        return 'Tài liệu';
      default:
        return 'Hàng hóa khác';
    }
  }

  void _showRentTypeSelection() {
    SmartDialog.show<void>(
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
              'CHỌN LOẠI HÌNH THUÊ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Vui lòng chọn loại hình thuê tủ phù hợp với nhu cầu của bạn.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ShadButton(
              onPressed: () {
                final plan = _activeSubscription?.plan;
                final maxLockers = plan?.maxLockers ?? 0;
                final currentRentals = _activeOrders
                    .where((o) => o.orderType == 'PERSONAL_RENTAL')
                    .length;

                if (currentRentals >= maxLockers) {
                  SmartDialog.showToast(
                    'Bạn đã đạt giới hạn thuê tủ tối đa của gói ${plan?.name ?? 'Cơ bản'} ($maxLockers tủ). Vui lòng trả tủ trước khi thuê mới.',
                  );
                  return;
                }

                SmartDialog.dismiss<void>();
                _openConfirmRentPage(selectedMonths: 1, isFixed: false);
              },
              backgroundColor: const Color(0xFF0A2342),
              height: 64,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Thuê linh hoạt',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Tính phí theo giờ',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            ShadButton(
              onPressed: () {
                final plan = _activeSubscription?.plan;
                final fixedLockerLimit = plan?.fixedLocker ?? 0;

                if (fixedLockerLimit == 0) {
                  SmartDialog.showToast(
                    'Gói dịch vụ của bạn không hỗ trợ thuê tủ cố định.',
                  );
                  return;
                }

                final currentFixedRentals = _activeOrders
                    .where(
                      (o) => o.orderType == 'PERSONAL_RENTAL' && o.isPrepaid,
                    )
                    .length;

                if (currentFixedRentals >= fixedLockerLimit) {
                  SmartDialog.showToast(
                    'Bạn đã đạt giới hạn thuê tủ cố định ($fixedLockerLimit/$fixedLockerLimit). Vui lòng trả tủ trước khi thuê mới.',
                  );
                  return;
                }

                final maxLockers = plan?.maxLockers ?? 0;
                final currentRentals = _activeOrders
                    .where((o) => o.orderType == 'PERSONAL_RENTAL')
                    .length;

                if (currentRentals >= maxLockers) {
                  SmartDialog.showToast(
                    'Bạn đã đạt giới hạn thuê tủ tối đa của gói ${plan?.name ?? 'Cơ bản'} ($maxLockers tủ). Vui lòng trả tủ trước khi thuê mới.',
                  );
                  return;
                }

                SmartDialog.dismiss<void>();
                _showFixedRentDurationSelection();
              },
              backgroundColor: const Color(0xFF0A2342),
              height: 64,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Thuê cố định',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Dành cho khách hàng dài hạn',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ShadButton.ghost(
              padding: EdgeInsets.zero,
              onPressed: () => SmartDialog.dismiss<void>(),
              child: const Text('Hủy'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFixedRentDurationSelection() {
    int selectedDuration = 1;
    bool isMonthMode = true;

    SmartDialog.show<void>(
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            constraints: const BoxConstraints(maxWidth: 500),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Thời gian thuê cố định',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                // Toggle between Day and Month
                Row(
                  children: [
                    Expanded(
                      child: ShadButton.ghost(
                        onPressed: () => setModalState(() {
                          isMonthMode = true;
                          selectedDuration = 1;
                        }),
                        backgroundColor: isMonthMode
                            ? const Color(0xFF0A2342).withOpacity(0.1)
                            : null,
                        child: Text(
                          'Theo Tháng',
                          style: TextStyle(
                            color: isMonthMode
                                ? const Color(0xFF0A2342)
                                : Colors.grey,
                            fontWeight: isMonthMode
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ShadButton.ghost(
                        onPressed: () => setModalState(() {
                          isMonthMode = false;
                          selectedDuration = 1;
                        }),
                        backgroundColor: !isMonthMode
                            ? const Color(0xFF0A2342).withOpacity(0.1)
                            : null,
                        child: Text(
                          'Theo Ngày',
                          style: TextStyle(
                            color: !isMonthMode
                                ? const Color(0xFF0A2342)
                                : Colors.grey,
                            fontWeight: !isMonthMode
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShadButton.outline(
                      onPressed: selectedDuration > 1
                          ? () => setModalState(() => selectedDuration--)
                          : null,
                      child: const Icon(Icons.remove_circle_outline, size: 24),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A2342).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFB7D0E6)),
                      ),
                      child: Text(
                        '$selectedDuration ${isMonthMode ? 'tháng' : 'ngày'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    ShadButton.outline(
                      onPressed: selectedDuration < (isMonthMode ? 12 : 365)
                          ? () => setModalState(() => selectedDuration++)
                          : null,
                      child: const Icon(Icons.add_circle_outline, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final provider = ref.read(lockerNotifierProvider);
                    final pricings = provider.state.pricings
                        .cast<PricingEntity>();
                    final personalPricing = pricings.firstWhere(
                      (p) => p.orderType == 'PERSONAL_RENTAL',
                      orElse: () => pricings.firstWhere(
                        (p) => p.blockUnit == 'MONTH',
                        orElse: () => pricings.isEmpty
                            ? const PricingEntity(
                                id: '',
                                name: '',
                                blockDuration: 1,
                                blockUnit: 'MONTH',
                                feePerBlock: 199000,
                                lateFeePerBlock: 0,
                                orderType: 'PERSONAL_RENTAL',
                                gracePeriod: 0,
                              )
                            : pricings.first,
                      ),
                    );

                    double basePrice = 0;
                    if (isMonthMode) {
                      // Estimate months (30 days avg for UI estimation)
                      if (personalPricing.blockUnit == 'MONTH') {
                        basePrice =
                            (personalPricing.feePerBlock as num).toDouble() *
                            (selectedDuration / personalPricing.blockDuration);
                      } else {
                        // Pricing is hourly/minute, convert to monthly
                        final unitMinutes = _getBlockUnitMinutes(
                          personalPricing.blockUnit,
                        );
                        final blockMin =
                            personalPricing.blockDuration * unitMinutes;
                        final monthsMin = selectedDuration * 30 * 24 * 60;
                        basePrice =
                            (monthsMin / blockMin) *
                            personalPricing.feePerBlock;
                      }
                    } else {
                      // Days mode
                      final unitMinutes = _getBlockUnitMinutes(
                        personalPricing.blockUnit,
                      );
                      final blockMin =
                          personalPricing.blockDuration * unitMinutes;
                      final daysMin = selectedDuration * 24 * 60;
                      basePrice =
                          (daysMin / blockMin) * personalPricing.feePerBlock;
                    }

                    final plan = _activeSubscription?.plan;
                    final discountPercent =
                        plan?.discountFixedLockerRental ?? 0;
                    final total = (basePrice * (1 - discountPercent / 100))
                        .round();

                    return Column(
                      children: [
                        Text(
                          'Tổng tiền tạm tính:',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        Text(
                          '${NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(total)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0A2342),
                          ),
                        ),
                        if (discountPercent > 0)
                          Text(
                            ' (Đã giảm $discountPercent% từ gói ${plan?.name})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ShadButton.ghost(
                      child: const Text('Hủy'),
                      onPressed: () => SmartDialog.dismiss<void>(),
                    ),
                    const SizedBox(width: 8),
                    ShadButton(
                      child: const Text('Xác nhận'),
                      onPressed: () {
                        SmartDialog.dismiss<void>();
                        _openConfirmRentPage(
                          selectedMonths: isMonthMode ? selectedDuration : 0,
                          selectedDays: !isMonthMode ? selectedDuration : 0,
                          isFixed: true,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _getBlockUnitMinutes(String unit) {
    switch (unit) {
      case 'MINUTE':
        return 1;
      case 'HOUR':
        return 60;
      case 'DAY':
        return 24 * 60;
      case 'WEEK':
        return 7 * 24 * 60;
      case 'MONTH':
        return 30 * 24 * 60;
      default:
        return 1;
    }
  }

  void _openConfirmRentPage({
    int selectedMonths = 0,
    int selectedDays = 0,
    required bool isFixed,
  }) {
    final provider = ref.read(lockerNotifierProvider);
    final state = provider.state;

    String cabinetName = state.selectedCabinet?.name ?? 'Tủ A — Tầng trệt';
    if (state.selectedCabinet == null && _selectedCabinetId != null) {
      for (final cabinet in state.cabinets) {
        if (cabinet.id == _selectedCabinetId) {
          cabinetName = cabinet.name;
          break;
        }
      }
    }

    String lockerFallback = 'R3-C2';
    if (_selectedLockerId != null) {
      for (final locker in state.leastUsedLockers) {
        if (locker.id == _selectedLockerId) {
          lockerFallback = locker.displayPosition;
          break;
        }
      }
    }

    final lockerLabel = _selectedLockerId != null
        ? _formatLockerCode(_selectedLockerId!, fallback: lockerFallback)
        : lockerFallback;

    // Resolve location name
    String locationName = 'Vị trí hiện tại';
    if (_selectedLocationId != null) {
      for (final loc in state.locations) {
        if (loc.id == _selectedLocationId) {
          locationName = loc.name;
          break;
        }
      }
    }

    // Real Pricing and Balance
    final walletBalance = legacy_provider.Provider.of<WalletProvider>(
      context,
      listen: false,
    ).balance.round();
    final pricings = provider.state.pricings.cast<PricingEntity>();

    int priceValue = 0;
    int discountValue = 0;
    String planNameValue = '';
    String blockUnit = 'HOUR';
    int blockDuration = 1;
    double initialBlocks = 0;
    int gracePeriodRaw = 0;
    int unitPriceValue = 0;

    if (isFixed) {
      final personalPricing = pricings.firstWhere(
        (p) => p.orderType == 'PERSONAL_RENTAL',
        orElse: () => pricings.firstWhere(
          (p) => p.blockUnit == 'MONTH',
          orElse: () => pricings.isEmpty
              ? const PricingEntity(
                  id: '',
                  name: '',
                  blockDuration: 1,
                  blockUnit: 'MONTH',
                  feePerBlock: 199000,
                  lateFeePerBlock: 0,
                  orderType: 'PERSONAL_RENTAL',
                  gracePeriod: 0,
                )
              : pricings.first,
        ),
      );
      final plan = _activeSubscription?.plan;
      final discountPercent = plan?.discountFixedLockerRental ?? 0;

      double basePrice = 0;
      if (selectedMonths > 0) {
        // Estimate months
        if (personalPricing.blockUnit == 'MONTH') {
          basePrice =
              (personalPricing.feePerBlock as num).toDouble() *
              (selectedMonths / personalPricing.blockDuration);
        } else {
          final unitMinutes = _getBlockUnitMinutes(personalPricing.blockUnit);
          final blockMin = personalPricing.blockDuration * unitMinutes;
          final monthsMin = selectedMonths * 30 * 24 * 60;
          basePrice = (monthsMin / blockMin) * personalPricing.feePerBlock;
        }
      } else {
        // Days
        final unitMinutes = _getBlockUnitMinutes(personalPricing.blockUnit);
        final blockMin = personalPricing.blockDuration * unitMinutes;
        final daysMin = selectedDays * 24 * 60;
        basePrice = (daysMin / blockMin) * personalPricing.feePerBlock;
      }

      priceValue = basePrice.round();
      discountValue = (priceValue * (discountPercent / 100)).round();
      planNameValue = 'Thuê cố định (Dài hạn)';
      blockUnit = personalPricing.blockUnit;
      blockDuration = personalPricing.blockDuration;
      unitPriceValue = personalPricing.feePerBlock.round();
      initialBlocks = 1; // Standard 1 block for fixed
      gracePeriodRaw = 1;
    } else {
      final flexPricing = pricings.firstWhere(
        (p) => p.blockUnit == 'HOUR',
        orElse: () => pricings.firstWhere(
          (p) => p.id.contains('hourly') || p.name.contains('Hourly'),
          orElse: () => pricings.isEmpty
              ? const PricingEntity(
                  id: '',
                  name: '',
                  blockDuration: 1,
                  blockUnit: 'HOUR',
                  feePerBlock: 49000,
                  lateFeePerBlock: 0,
                  orderType: '',
                  gracePeriod: 180,
                )
              : pricings.first,
        ),
      );
      final double calculatedBlocks = flexPricing.blockDuration > 0
          ? (flexPricing.gracePeriod / flexPricing.blockDuration)
          : 0;
      initialBlocks = (calculatedBlocks > 0 ? calculatedBlocks : 3).toDouble();
      priceValue = ((flexPricing.feePerBlock as num) * initialBlocks).round();
      unitPriceValue = flexPricing.feePerBlock.round();

      final plan = _activeSubscription?.plan;
      final discountPercent = plan?.discountLockerRental ?? 0;
      discountValue = (priceValue * (discountPercent / 100)).round();

      planNameValue = 'Thuê linh hoạt';
      blockUnit = flexPricing.blockUnit;
      blockDuration = flexPricing.blockDuration;
      gracePeriodRaw = flexPricing.gracePeriod > 0
          ? flexPricing.gracePeriod
          : 180;
    }

    final String termLabel = isFixed
        ? (selectedMonths > 0
              ? '${selectedMonths.toString().padLeft(2, '0')} Tháng'
              : '${selectedDays.toString().padLeft(2, '0')} Ngày')
        : '';

    final args = ConfirmRentArgs(
      cabinetId: _selectedCabinetId ?? '',
      lockerId: _selectedLockerId ?? '',
      cabinetName: cabinetName,
      lockerLabel: lockerLabel,
      locationName: locationName,
      blockUnit: blockUnit,
      blockDuration: blockDuration,
      activePlanName: _activePlanName ?? 'Cơ bản',
      price: priceValue,
      discount: discountValue,
      unitPrice: unitPriceValue,
      durationMonths: selectedMonths,
      durationDays: selectedDays,
      walletBalance: walletBalance,
      planName: planNameValue,
      termLabel: termLabel,
      isFixed: isFixed,
      itemType: _selectedItemType,
      initialBlocks: initialBlocks,
      gracePeriod: gracePeriodRaw,
    );

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => ConfirmRentPage(args: args)),
    );
  }

  Widget _buildItemTypeSelection() {
    final types = [
      {
        'id': 'FOOD',
        'label': 'Đồ ăn',
        'icon': LucideIcons.utensils,
        'desc': 'Thực phẩm, đồ uống, giao ngay',
      },
      {
        'id': 'OTHER',
        'label': 'Hàng hóa khác',
        'icon': LucideIcons.package,
        'desc': 'Bưu phẩm, quần áo, linh kiện...',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Text(
          'Chọn loại mặt hàng',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Lựa chọn này giúp chúng tôi điều phối phương thức vận chuyển phù hợp.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        ...types.map((type) {
          final isSelected = _selectedItemType == type['id'];
          final id = type['id'] as String;
          final icon = type['icon'] as IconData;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () => setState(() => _selectedItemType = id),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AISLShadcnTheme.navyPrimary.withOpacity(0.04)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AISLShadcnTheme.navyPrimary
                        : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AISLShadcnTheme.navyPrimary.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AISLShadcnTheme.navyPrimary
                            : const Color(0xFFE7F0F8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? Colors.white
                            : AISLShadcnTheme.navyPrimary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            type['label'] as String,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? AISLShadcnTheme.navyPrimary
                                  : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            type['desc'] as String,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: AISLShadcnTheme.navyPrimary,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildLogisticsTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bạn muốn gửi hàng như thế nào?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 24),
        _buildLogisticsCard(
          title: 'Tự mang ra tủ',
          subtitle: 'Gửi hàng tại tủ Locker gần nhất',
          icon: LucideIcons.package2,
          isSelected: !_isHomePickup,
          onTap: () => setState(() => _isHomePickup = false),
        ),
        const SizedBox(height: 12),
        _buildLogisticsCard(
          title: 'Lấy hàng tại nhà',
          subtitle: 'Tài xế sẽ đến tận nơi lấy hàng',
          icon: Icons.home_outlined,
          isSelected: _isHomePickup,
          onTap: () => setState(() => _isHomePickup = true),
        ),
      ],
    );
  }

  Widget _buildLogisticsCard({
    required String title,
    required String subtitle,
    required dynamic icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0A2342).withOpacity(0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF0A2342) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0A2342)
                    : const Color(0xFFE7F0F8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon is IconData ? icon : (icon as IconData),
                color: isSelected ? Colors.white : const Color(0xFF0A2342),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? const Color(0xFF0A2342)
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: const Color(0xFF0A2342)),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupAddressStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Địa chỉ lấy hàng',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Nhập địa chỉ chi tiết để tài xế dễ dàng tìm thấy bạn',
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 24),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Địa chỉ chi tiết',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push<LocationResult>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationPicker(
                      initialAddress: _pickupAddressController.text,
                      initialLat: _pickupLatitude,
                      initialLon: _pickupLongitude,
                    ),
                  ),
                );

                if (result != null) {
                  setState(() {
                    _pickupAddressController.text = result.address;
                    _pickupLatitude = result.latitude;
                    _pickupLongitude = result.longitude;
                  });
                }
              },
              child: AbsorbPointer(
                child: CustomInput(
                  controller: _pickupAddressController,
                  placeholder: 'Chạm để chọn địa chỉ từ bản đồ...',
                  prefixIcon: const Icon(
                    LucideIcons.mapPin,
                    size: 20,
                    color: Colors.black87,
                  ),
                  backgroundColor: Colors.white,
                  borderColor: Colors.grey.shade200,
                  style: const TextStyle(color: Colors.black),
                  cursorColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildLocationSelection(LockerState state) {
    final locations = state.locations;

    if (state.isLoading && locations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: AISLShadcnTheme.navyPrimary),
        ),
      );
    }

    if (state.error != null && locations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lỗi: ${state.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () =>
                    ref.read(lockerNotifierProvider).getLocations(),
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (locations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Text(
            'Không tìm thấy vị trí nào',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
      );
    }

    final isDest = _isHomePickup && widget.action == LockerAction.send;
    final titleText = isDest ? 'Chọn vị trí đích' : 'Chọn vị trí gần bạn';

    return AnimatedOpacity(
      opacity: _locationVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titleText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...locations.map((loc) {
            final id = loc.id;
            final isSelected = _selectedLocationId == id;
            return GestureDetector(
              onTap: () => setState(() => _selectedLocationId = id),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: ShapeDecoration(
                        color: isSelected
                            ? const Color(0xFF0A2342).withOpacity(0.08)
                            : Colors.white,
                        shape: StadiumBorder(
                          side: BorderSide(
                            color: isSelected
                                ? const Color(0xFF0A2342)
                                : Colors.grey.shade200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF0A2342,
                              ).withOpacity(isSelected ? 1 : 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.location_on,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF0A2342),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? const Color(0xFF0A2342)
                                        : Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  loc.address,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isSelected
                                        ? const Color(0xFF12355B)
                                        : Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Positioned(
                        right: 10,
                        top: -6,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: const Color(0xFF0A2342),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCabinetSelection(LockerState state) {
    final cabinets = state.cabinets;
    final sizes = state.lockerSizeItems
        .map(
          (item) => {
            'id': item.sizeId,
            'name': item.sizeName,
            'width': item.width,
            'height': item.height,
            'count': item.totalLockers,
          },
        )
        .toList();

    if (cabinets.isEmpty && state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: AISLShadcnTheme.navyPrimary),
        ),
      );
    }

    if (cabinets.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: Text('Không có tủ nào khả dụng tại vị trí này')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn tủ locker',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...cabinets.map((cab) {
          final id = cab.id;
          final isSelected = _selectedCabinetId == id;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCabinetId = id;
                _selectedSizeId = null; // Clear size when cabinet changes
              });
              ref
                  .read(lockerNotifierProvider)
                  .getLockerCountBySize(cabinetId: id);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0A2342)
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A2342).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            LucideIcons.archive,
                            color: const Color(0xFF12355B),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            cab.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? const Color(0xFF0A2342)
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      right: 10,
                      top: -6,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: const Color(0xFF0A2342),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
        if (_selectedCabinetId != null) ...[
          const SizedBox(height: 12),
          const Text(
            'Chọn kích thước',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: sizes.map((item) {
                final sizeId = item['id']! as String;
                final count = item['count']! as int;
                final isSelected = _selectedSizeId == sizeId;

                return GestureDetector(
                  onTap: () => setState(() => _selectedSizeId = sizeId),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 140,
                    margin: const EdgeInsets.only(right: 16, bottom: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFE7F0F8)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF0A2342)
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? const Color(0xFF0A2342).withOpacity(0.15)
                              : Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Decorative vents for size card
                        Positioned(
                          top: 10,
                          left: 10,
                          right: 30,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: List.generate(
                              2,
                              (i) => Container(
                                height: 1.5,
                                width: 20,
                                margin: const EdgeInsets.only(bottom: 2),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF0A2342).withOpacity(0.3)
                                      : Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                item['name'] as String,
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF061A30)
                                      : Colors.black87,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${item['width']}x${item['height']} cm',
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF12355B)
                                      : Colors.grey[600],
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFFD8E8F4)
                                      : Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Trống: $count',
                                  style: TextStyle(
                                    color: isSelected
                                        ? const Color(0xFF0A2342)
                                        : Colors.grey.shade700,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Positioned(
                            right: 8,
                            top: 8,
                            child: Icon(
                              Icons.check_circle,
                              color: const Color(0xFF0A2342),
                              size: 16,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLockerSelection(LockerState state) {
    final allLockers = state.leastUsedLockers;
    final hasAvailable = allLockers.any(
      (l) => l.status == LockerStatus.available,
    );

    if (allLockers.isEmpty && state.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: AISLShadcnTheme.navyPrimary),
        ),
      );
    }

    if (allLockers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.circleAlert, size: 28, color: Colors.black54),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Hiện tại trạm này đã hết ngăn tủ trống. Vui lòng chọn trạm khác.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chọn ngăn tủ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (!hasAvailable) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: const Text(
              'Trạm này không còn ngăn trống. Bạn vẫn có thể xem các ngăn đang có hàng bên dưới.',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allLockers.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            final locker = allLockers[index];
            final id = locker.id;
            final isOccupied = locker.status != LockerStatus.available;
            final isSelected = !isOccupied && _selectedLockerId == id;

            // Common styles for both occupied and available
            final BorderRadius borderRadius = BorderRadius.circular(12);

            if (isOccupied) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: borderRadius,
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Gym Locker Decorative Elements (Horizontal vents)
                    Positioned(
                      top: 12,
                      left: 12,
                      right: 40,
                      child: Column(
                        children: List.generate(
                          3,
                          (i) => Container(
                            height: 2,
                            margin: const EdgeInsets.only(bottom: 3),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Handle element
                    Positioned(
                      right: 12,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          width: 6,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            _formatLockerCode(
                              locker.id,
                              fallback: locker.displayPosition,
                            ),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            locker.sizeLabel,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Icon(
                        LucideIcons.lock,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              );
            }

            final orangeGradient = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xFF5F8FB8), Colors.deepOrange.shade600],
            );

            return GestureDetector(
              onTap: () =>
                  setState(() => _selectedLockerId = isSelected ? null : id),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 150),
                scale: isSelected ? 1.05 : 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: isSelected ? orangeGradient : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: borderRadius,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0A2342)
                          : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? const Color(0xFF0A2342).withOpacity(0.3)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Gym Locker Decorative Elements (Horizontal vents)
                      Positioned(
                        top: 12,
                        left: 12,
                        right: 40,
                        child: Column(
                          children: List.generate(
                            3,
                            (i) => Container(
                              height: 2,
                              margin: const EdgeInsets.only(bottom: 3),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.3)
                                    : const Color(0xFF0A2342).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Handle element
                      Positioned(
                        right: 12,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 30,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withOpacity(0.4)
                                  : const Color(0xFF0A2342).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              _formatLockerCode(
                                locker.id,
                                fallback: locker.displayPosition,
                              ),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              locker.sizeLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white70
                                    : const Color(0xFF12355B),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Positioned(
                          right: 6,
                          top: 6,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _formatLockerCode(String id, {required String fallback}) {
    final number = int.tryParse(id);
    if (number == null) return fallback;
    return 'L-${number.toString().padLeft(2, '0')}';
  }

  Widget _buildInfoForm(LockerProvider provider) {
    if (widget.action == LockerAction.rent) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thông tin người nhận',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        _buildFieldLabel('Số điện thoại người nhận'),
        CustomInput(
          controller: _receiverPhoneController,
          placeholder: 'Nhập số điện thoại người nhận',
          keyboardType: TextInputType.phone,
          backgroundColor: Colors.white,
          borderColor: Colors.grey.shade300,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: Colors.black,
          suffixIcon: ShadButton.ghost(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            onPressed: _isSearchingPhone ? null : _onSearchPhone,
            child: _isSearchingPhone
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(LucideIcons.search, size: 18),
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(LucideIcons.phone, size: 16),
          ),
        ),
        if (_foundUser != null) ...[
          const SizedBox(height: 12),
          const Text(
            'Chọn thông người nhận tìm thấy:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          _buildFoundUsersList(),
        ],
        const SizedBox(height: 16),
        _buildFieldLabel('Họ và tên người nhận'),
        CustomInput(
          controller: _receiverNameController,
          placeholder: 'Tên người nhận',
          backgroundColor: Colors.white,
          borderColor: Colors.grey.shade300,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: Colors.black,
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(LucideIcons.user, size: 16),
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        _buildFieldLabel('Địa chỉ giao hàng (Locker)'),
        _buildAddressSelection(provider.state),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),
        _buildFieldLabel('Ghi chú'),
        CustomInput(
          controller: _noteController,
          placeholder: 'Ghi chú của bạn (không bắt buộc)',
          maxLines: 3,
          height: 100,
          backgroundColor: Colors.white,
          borderColor: Colors.grey.shade300,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          cursorColor: Colors.black,
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Icon(LucideIcons.fileText, size: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildFoundUsersList() {
    if (_foundUser == null) return const SizedBox.shrink();

    final name = _foundUser!.fullName;
    return GestureDetector(
      onTap: () {
        setState(() {
          _receiverNameController.text = name;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF0A2342).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0A2342).withOpacity(0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFF0A2342),
              child: Icon(LucideIcons.user, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSelection(LockerState state) {
    final locations = state.locations;
    if (locations.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Text('Đang tải danh sách vị trí...'),
      );
    }

    return Column(
      children: [
        ...locations.map((loc) {
          final isSelected = _receiverAddressController.text == loc.address;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _receiverAddressController.text = loc.address ?? '';
                  _selectedReceiverLocation = loc;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0A2342).withOpacity(0.08)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0A2342)
                        : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.mapPin,
                      size: 18,
                      color: isSelected ? const Color(0xFF0A2342) : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.name,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            loc.address ?? '',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        LucideIcons.check,
                        color: const Color(0xFF0A2342),
                        size: 18,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}
