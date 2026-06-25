import 'package:smart_laundry_locker/core/routing/app_router.dart';

/// Landing page per signed-in role:
/// ADMIN -> admin home, MANAGER -> ops dashboard, TECHNICIAN -> technician home,
/// MAINTENANCE/STAFF -> staff/maintenance home, else customer home.
String homeForRoles(List<String> roles) {
  if (roles.contains('ADMIN')) {
    return AppRouter.adminHome;
  }
  if (roles.contains('MANAGER')) {
    return AppRouter.managerHome;
  }
  if (roles.contains('TECHNICIAN')) {
    return AppRouter.technicianHome;
  }
  if (roles.contains('MAINTENANCE')) {
    return AppRouter.maintenanceHome;
  }
  if (roles.contains('STAFF')) {
    return AppRouter.staffHome;
  }
  return AppRouter.home;
}
