import 'package:smart_laundry_locker/core/routing/app_router.dart';

/// Landing page per signed-in role:
/// MANAGER/ADMIN -> ops dashboard, MAINTENANCE -> work queue, else customer home.
String homeForRoles(List<String> roles) {
  if (roles.contains('MANAGER') || roles.contains('ADMIN')) {
    return AppRouter.managerHome;
  }
  if (roles.contains('MAINTENANCE')) {
    return AppRouter.maintenanceHome;
  }
  return AppRouter.home;
}
