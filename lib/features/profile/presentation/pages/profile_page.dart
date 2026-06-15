import 'dart:io';

import 'package:smart_laundry_locker/core/services/token_service.dart';
import 'package:smart_laundry_locker/features/notifications/presentation/providers/notification_provider.dart';
import 'package:smart_laundry_locker/core/network/api_client.dart';
import 'package:smart_laundry_locker/features/profile/presentation/providers/profile_provider.dart';
import 'package:smart_laundry_locker/features/delegations/presentation/providers/delegation_provider.dart';
import 'package:smart_laundry_locker/features/delegations/presentation/providers/delegation_injection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:smart_laundry_locker/core/routing/app_router.dart';
import 'package:smart_laundry_locker/core/services/courier_mode_provider.dart';
import 'package:smart_laundry_locker/core/services/app_initial_tab_service.dart';
import 'package:smart_laundry_locker/core/theme/shadcn_theme.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/presentation/providers/courier_dispatch_injection.dart';
import 'package:smart_laundry_locker/features/courier_dispatch/presentation/providers/courier_dispatch_provider.dart';
import 'package:smart_laundry_locker/features/profile/presentation/mixins/profile_image_actions_mixin.dart';
import 'package:smart_laundry_locker/features/profile/presentation/pages/staff_application_page.dart';
import 'package:smart_laundry_locker/features/profile/presentation/widgets/profile_header.dart';
import 'package:smart_laundry_locker/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:smart_laundry_locker/features/staff_application/presentation/providers/staff_application_injection.dart';
import 'package:smart_laundry_locker/features/staff_application/presentation/providers/staff_application_provider.dart';
import 'package:smart_laundry_locker/shared/widgets/user_ui_kit.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with ProfileImageActionsMixin {
  @override
  File? localAvatarFile;

  @override
  File? localBannerFile;

  @override
  bool isAvatarSyncing = false;

  // User data
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  bool _isLoggedIn = false;
  late ProfileProvider _profileProvider;
  late DelegationProvider _delegationProvider;
  late StaffApplicationProvider _staffApplicationProvider;
  late CourierDispatchProvider _courierDispatchProvider;
  bool _isCourierModeSwitching = false;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    _profileProvider = context.read<ProfileProvider>();
    _delegationProvider = DelegationInjection.provideDelegationProvider(
      apiClient,
    );
    _staffApplicationProvider = StaffApplicationInjection.provideProvider(
      apiClient,
    );
    _courierDispatchProvider =
        CourierDispatchInjection.provideCourierDispatchProvider();
    TokenService.authState.addListener(_onAuthStateChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserProfile();
    });
  }

  Future<void> _switchCourierModeWithReload(bool nextValue) async {
    if (_isCourierModeSwitching) return;

    final courierModeProvider = context.read<CourierModeProvider>();
    final prevValue = courierModeProvider.isCourierModeActive;

    setState(() {
      _isCourierModeSwitching = true;
    });

    try {
      try {
        await AppInitialTabService.setInitialTab(4);
      } catch (e) {
        debugPrint('setInitialTab failed: $e');
      }

      SmartDialog.showLoading<void>(msg: 'Đang chuyển đổi giao diện...');
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (!mounted) return;

      String? syncError;
      try {
        if (!nextValue) {
          await _courierDispatchProvider.goOffline();
        } else {
          await _courierDispatchProvider.toggleOnlineStatus(true);
        }
        syncError = _courierDispatchProvider.error;
      } catch (e) {
        syncError = e.toString();
        debugPrint('courier location sync failed: $e');
      }

      await courierModeProvider.setCourierModeActive(nextValue);

      if (!mounted) return;

      if (syncError != null && syncError.isNotEmpty) {
        _showProfileSnackBar(
          'Đã chuyển giao diện, nhưng chưa đồng bộ trạng thái online/offline với server.',
        );
      }
    } catch (e) {
      debugPrint('switchCourierModeWithReload failed: $e');
      if (mounted) {
        try {
          await courierModeProvider.setCourierModeActive(prevValue);
        } catch (e2) {
          debugPrint('revert courierMode failed: $e2');
        }
      }
      if (mounted) {
        _showProfileSnackBar('Không thể chuyển đổi chế độ. Vui lòng thử lại.');
      }
    } finally {
      SmartDialog.dismiss<void>();
      if (mounted) {
        setState(() {
          _isCourierModeSwitching = false;
        });
      }
    }
  }

  void _onAuthStateChanged() {
    if (TokenService.authState.value) {
      _loadUserProfile();
    } else {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _userData = null;
        });
      }
    }
  }

  @override
  void dispose() {
    TokenService.authState.removeListener(_onAuthStateChanged);
    _delegationProvider.dispose();
    _staffApplicationProvider.dispose();
    super.dispose();
  }

  bool _hasRole(String role) {
    final rolesRaw = _userData?['roles'];
    if (rolesRaw is! List) return false;
    return rolesRaw.any((r) => r.toString().toUpperCase() == role);
  }

  String? _effectiveStaffStatus(StaffApplicationProvider provider) {
    final dynamic statusFromUser = _userData?['staffStatus'];
    if (statusFromUser != null) {
      return statusFromUser.toString().toUpperCase();
    }
    final app = provider.application;
    return app?.status.name.toUpperCase();
  }

  bool _isApprovedCourier(StaffApplicationProvider provider) {
    final status = _effectiveStaffStatus(provider);
    return status == 'APPROVED' ||
        _hasRole('TECHNICIAN') ||
        _hasRole('COURIER');
  }

  bool _isPendingCourier(StaffApplicationProvider provider) {
    final status = _effectiveStaffStatus(provider);
    return status == 'PENDING';
  }

  Future<void> _loadUserProfile({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
    });

    final hasToken = await TokenService.hasToken();
    if (!mounted) return;

    if (!hasToken) {
      setState(() {
        _isLoggedIn = false;
        _userData = null;
        _isLoading = false;
      });
      return;
    }

    await _profileProvider.loadProfile();
    if (!mounted) return;

    final isLoggedIn = _profileProvider.profile != null;

    if (isLoggedIn) {
      await _delegationProvider.fetchMyDelegations();
    }
    if (!mounted) return;

    List<String> roles = [];
    if (isLoggedIn) {
      roles = await TokenService.getCurrentRoles();
    }

    setState(() {
      _isLoggedIn = isLoggedIn;
      if (_profileProvider.profile != null) {
        final profile = _profileProvider.profile!;
        _userData = {
          'id': profile.id.toString(),
          'fullName': profile.fullName.toString(),
          'email': profile.email.toString(),
          'phoneNumber': profile.phoneNumber.toString(),
          'avatar': profile.avatarUrl,
          'isEmailVerified': profile.isVerified,
          'isPhoneVerified': profile.isVerified,
          'status': profile.status.name,
          'isActive': profile.isActive,
          'roles': roles,
        };
      } else {
        _userData = null;
      }
      _isLoading = false;
    });

    // Load staff application status for Profile UI
    final userId = _userData?['id'] as String?;
    if (userId != null && userId.isNotEmpty) {
      await _staffApplicationProvider.loadStatus(userId);
    }
  }

  @override
  String? get currentUserIdForAvatar => _userData?['id'] as String?;

  @override
  Widget build(BuildContext context) {
    // Show loading
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF2F4F7),
        body: const Column(
          children: [
            BrandHeroHeader(
              title: 'Hồ sơ',
              subtitle: 'Quản lý tài khoản của bạn',
            ),
            Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      );
    }

    // nếu chưa đăng nhập thì chuyển về màn hình đăng nhập
    if (!_isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(AppRouter.onboarding);
      });
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: _delegationProvider),
          ChangeNotifierProvider.value(value: _staffApplicationProvider),
        ],
        child: Column(
          children: [
            BrandHeroHeader(
              title: 'Hồ sơ',
              subtitle: 'Quản lý tài khoản của bạn',
              trailing: BrandCircleIconButton(
                icon: LucideIcons.pencil,
                onTap: _handleEditProfile,
                iconSize: 16,
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _loadUserProfile(forceRefresh: true);
                },
                color: AISLShadcnTheme.navyPrimary,
                backgroundColor: Colors.white,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      if (_userData != null)
                        ProfileHeader(
                          user: _userData!,
                          avatarVersion: 0,
                          localAvatarFile: localAvatarFile,
                          isAvatarSyncing: isAvatarSyncing,
                          showSaveAvatarButton: localAvatarFile != null,
                          onEditAvatar: handleAvatarSelection,
                          onSaveAvatar: uploadAvatarImage,
                          onCancelAvatar: cancelAvatarSelection,
                        ),

                      const SizedBox(height: 24),

                      _buildMenuSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
          // Account section
          _buildMenuGroup(
            title: 'Tài khoản',
            items: [
              _buildCourierModeSwitcher(),
              ProfileMenuItem(
                icon: LucideIcons.user,
                title: 'Thông tin cá nhân',
                onTap: _handleEditProfile,
              ),
              ListenableBuilder(
                listenable: _profileProvider,
                builder: (context, _) {
                  final isRegistered = _profileProvider.isFaceRegistered;
                  return ProfileMenuItem(
                    icon: Icons.face_retouching_natural_outlined,
                    title: isRegistered
                        ? 'Đăng ký lại khuôn mặt'
                        : 'Đăng ký khuôn mặt',
                    onTap: _handleFaceRegistration,
                  );
                },
              ),
              ProfileMenuItem(
                icon: LucideIcons.shield,
                title: 'Bảo mật',
                onTap: _handleSecurity,
              ),
              ProfileMenuItem(
                icon: LucideIcons.badgePercent,
                title: 'Gói dịch vụ',
                onTap: _handlePlans,
              ),
              ProfileMenuItem(
                icon: LucideIcons.ticket,
                title: 'Ưu đãi & Quà tặng',
                onTap: _handleMyVouchers,
              ),
              Consumer<NotificationProvider>(
                builder: (context, provider, child) {
                  return ProfileMenuItem(
                    icon: LucideIcons.bell,
                    title: 'Thông báo',
                    onTap: () {
                      context.push(AppRouter.notifications);
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (provider.unreadCount > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              provider.unreadCount > 99
                                  ? '99+'
                                  : '${provider.unreadCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 16,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, indent: 16, endIndent: 16),
          const SizedBox(height: 8),
          // Properties section
          _buildMenuGroup(
            title: 'Quản lý',
            items: [
              Consumer<DelegationProvider>(
                builder: (context, provider, child) {
                  final delegations = provider.myDelegations
                      .where((d) => d.isActive && d.usedAt == null)
                      .toList();

                  return ProfileMenuItem(
                    icon: LucideIcons.packageOpen,
                    title: 'Đơn ủy quyền',
                    onTap: () => context.push(AppRouter.myDelegations),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (delegations.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              delegations.length > 99
                                  ? '99+'
                                  : '${delegations.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 16,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  );
                },
              ),
              ProfileMenuItem(
                icon: LucideIcons.arrowLeftRight,
                title: 'Giao dịch',
                onTap: () => context.push(AppRouter.transactions),
                trailing: Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: Colors.black54,
                ),
              ),
              Consumer<StaffApplicationProvider>(
                builder: (context, provider, child) {
                  final app = provider.application;
                  final bool isApprovedCourier = _isApprovedCourier(provider);
                  final bool isPendingCourier = _isPendingCourier(provider);

                  // Courier: ẩn mục chuyển sang giao diện courier ở phần "Quản lý"
                  // (đã có card Switch "Chế độ Người giao hàng" ở phía trên).
                  if (isApprovedCourier) return const SizedBox.shrink();

                  // PENDING: thay bằng container không cho nhấn
                  if (isPendingCourier) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7F0F8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFB7D0E6)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            LucideIcons.clock,
                            size: 18,
                            color: const Color(0xFF12355B),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Đang chờ duyệt hồ sơ...',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF0A2342),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // REJECTED: hiển thị nút + dòng lý do đỏ
                  if (app != null && app.status.name == 'REJECTED') {
                    final reason = (app.reviewNote ?? '').trim();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ProfileMenuItem(
                          icon: LucideIcons.truck,
                          title: 'Đăng ký trở thành Nhân viên',
                          onTap: _handleNavigateToCourierRegistration,
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(56, 0, 16, 8),
                          child: Text(
                            reason.isEmpty
                                ? 'Đơn trước đó bị từ chối.'
                                : 'Đơn trước đó bị từ chối: $reason',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.red.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  // Chưa nộp hoặc chưa có dữ liệu: hiển thị nút đăng ký
                  return ProfileMenuItem(
                    icon: LucideIcons.truck,
                    title: 'Đăng ký trở thành Nhân viên',
                    onTap: _handleNavigateToCourierRegistration,
                  );
                },
              ),
              ProfileMenuItem(
                icon: LucideIcons.clipboardList,
                title: 'Báo cáo của tôi',
                onTap: () => context.pushNamed('my_reports'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, indent: 16, endIndent: 16),
          const SizedBox(height: 8),
          // Settings section
          _buildMenuGroup(
            title: 'Cài đặt',
            items: [
              ProfileMenuItem(
                icon: LucideIcons.globe,
                title: 'Ngôn ngữ',
                onTap: _handleLanguage,
                trailing: Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
              ),
              ProfileMenuItem(
                icon: LucideIcons.palette,
                title: 'Giao diện',
                onTap: _handleTheme,
                trailing: Icon(
                  LucideIcons.chevronRight,
                  size: 16,
                  color: ShadTheme.of(context).colorScheme.mutedForeground,
                ),
              ),
              ProfileMenuItem(
                icon: LucideIcons.mapPin,
                title: 'Vị trí',
                onTap: _handleLocation,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, indent: 16, endIndent: 16),
          const SizedBox(height: 8),
          // Support section
          _buildMenuGroup(
            title: 'Hỗ trợ',
            items: [
              ProfileMenuItem(
                icon: LucideIcons.handHelping,
                title: 'Trợ giúp',
                onTap: _handleHelp,
              ),
              ProfileMenuItem(
                icon: LucideIcons.messageCircle,
                title: 'Liên hệ',
                onTap: _handleContact,
              ),
              ProfileMenuItem(
                icon: LucideIcons.fileText,
                title: 'Điều khoản',
                onTap: _handleTerms,
              ),
              ProfileMenuItem(
                icon: LucideIcons.shieldCheck,
                title: 'Chính sách bảo mật',
                onTap: _handlePrivacy,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, indent: 16, endIndent: 16),
          const SizedBox(height: 8),
          // Account actions
          _buildMenuGroup(
            items: [
              ProfileMenuItem(
                icon: LucideIcons.doorOpen,
                title: 'Đăng xuất',
                onTap: _handleLogout,
                textColor: ShadTheme.of(context).colorScheme.destructive,
                iconColor: ShadTheme.of(context).colorScheme.destructive,
              ),
            ],
          ),

          const SizedBox(height: 8),
        ],
    );
  }

  Widget _buildCourierModeSwitcher() {
    return Consumer<StaffApplicationProvider>(
      builder: (context, staffProvider, _) {
        final bool isApprovedCourier = _isApprovedCourier(staffProvider);
        final bool canToggle = isApprovedCourier && !_isCourierModeSwitching;

        final theme = ShadTheme.of(context);
        const titleColor = Colors.black87;
        const subtitleColor = Colors.black54;
        final isCourierModeActive = context
            .watch<CourierModeProvider>()
            .isCourierModeActive;

        return Opacity(
          opacity: isApprovedCourier ? 1 : 0.5,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Icon(
              LucideIcons.truck,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            title: Text(
              'Chế độ người giao hàng',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: titleColor,
              ),
            ),
            subtitle: isApprovedCourier
                ? Text(
                    'Bật để bắt đầu nhận đơn và kiếm tiền',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: subtitleColor,
                      height: 1.35,
                    ),
                  )
                : null,
            trailing: Transform.scale(
              scale: 0.82,
              alignment: Alignment.centerRight,
              child: CupertinoSwitch(
                value: isCourierModeActive,
                activeColor: AISLShadcnTheme.navyPrimary,
                onChanged: canToggle
                    ? (v) => _switchCourierModeWithReload(v)
                    : null,
              ),
            ),
            onTap: canToggle
                ? () => _switchCourierModeWithReload(!isCourierModeActive)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildMenuGroup({required List<Widget> items, String? title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'Manrope',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: ShadTheme.of(context).colorScheme.mutedForeground,
              ),
            ),
          ),
        ],
        ...items,
      ],
    );
  }

  void _handleEditProfile() {
    if (!mounted) return;
    context.pushNamed('profile_detail');
  }

  void _handleFaceRegistration() {
    if (!mounted) return;
    context.push(AppRouter.faceRegistration);
  }

  void _handleSecurity() {
    if (!mounted) return;
    context.push(AppRouter.security);
  }

  void _handlePlans() {
    if (!mounted) return;
    context.push(AppRouter.plans);
  }

  void _handleMyVouchers() {
    if (!mounted) return;
    context.push(AppRouter.myVouchers);
  }

  void _handleLanguage() {
    _showProfileSnackBar('Tính năng đang được phát triển');
  }

  void _handleTheme() {
    _showProfileSnackBar('Tính năng đang được phát triển');
  }

  void _handleLocation() {
    _showProfileSnackBar('Tính năng đang được phát triển');
  }

  void _handleHelp() {
    _showProfileSnackBar('Tính năng đang được phát triển');
  }

  void _handleContact() {
    _showProfileSnackBar('Tính năng đang được phát triển');
  }

  void _handleTerms() {
    if (!mounted) return;
    context.push(
      AppRouter.policy,
      extra: {
        'title': 'Điều khoản sử dụng',
        'assetPath': 'assets/markdown/terms_of_service.md',
      },
    );
  }

  void _handlePrivacy() {
    if (!mounted) return;
    context.push(
      AppRouter.policy,
      extra: {
        'title': 'Chính sách bảo mật',
        'assetPath': 'assets/markdown/privacy_policy.md',
      },
    );
  }

  /// Show snackbar with white background and dark text for profile page
  void _showProfileSnackBar(String message) {
    if (!mounted) return;
    SmartDialog.showToast(
      '',
      alignment: Alignment.center,
      builder: (context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _handleLogout() {
    showCupertinoDialog<void>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await TokenService.clearTokens();
              setState(() {
                _userData = null;
                _isLoggedIn = false;
              });
              _showProfileSnackBar('Đã đăng xuất');
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNavigateToCourierRegistration() async {
    if (!mounted) return;

    final userId = _userData?['id'] as String?;
    if (userId == null || userId.isEmpty) {
      _showProfileSnackBar('Không thể lấy userId. Vui lòng thử lại.');
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const EmployeeRegistrationPage()),
    );

    if (!mounted) return;
    if (result == true) {
      await _staffApplicationProvider.loadStatus(userId);
    }
  }
}
