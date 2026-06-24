import 'package:flutter_test/flutter_test.dart';
import 'package:smart_laundry_locker/core/routing/role_routes.dart';

void main() {
  group('homeForRoles', () {
    group('ADMIN (highest priority)', () {
      test('ADMIN routes to /admin-home', () {
        expect(homeForRoles(['ADMIN']), equals('/admin-home'));
      });
      test('ADMIN+MANAGER routes to /admin-home (ADMIN wins)', () {
        expect(homeForRoles(['ADMIN', 'MANAGER']), equals('/admin-home'));
      });
      test('ADMIN+CUSTOMER routes to /admin-home (ADMIN wins)', () {
        expect(homeForRoles(['CUSTOMER', 'ADMIN']), equals('/admin-home'));
      });
      test('ADMIN does NOT route to /manager', () {
        expect(homeForRoles(['ADMIN']), isNot(equals('/manager')));
      });
    });

    group('MANAGER', () {
      test('MANAGER routes to /manager', () {
        expect(homeForRoles(['MANAGER']), equals('/manager'));
      });
      test('MANAGER does NOT route to /admin-home', () {
        expect(homeForRoles(['MANAGER']), isNot(equals('/admin-home')));
      });
    });

    group('TECHNICIAN', () {
      test('TECHNICIAN routes to /technician-home', () {
        expect(homeForRoles(['TECHNICIAN']), equals('/technician-home'));
      });
    });

    group('MAINTENANCE', () {
      test('MAINTENANCE routes to /maintenance-home, NOT /staff-home', () {
        expect(homeForRoles(['MAINTENANCE']), equals('/maintenance-home'));
      });
    });

    group('STAFF', () {
      test('STAFF routes to /staff-home', () {
        expect(homeForRoles(['STAFF']), equals('/staff-home'));
      });
    });

    group('CUSTOMER / fallback', () {
      test('CUSTOMER routes to /home', () {
        expect(homeForRoles(['CUSTOMER']), equals('/home'));
      });
      test('USER (legacy seed) routes to /home', () {
        expect(homeForRoles(['USER']), equals('/home'));
      });
      test('empty roles routes to /home', () {
        expect(homeForRoles([]), equals('/home'));
      });
      test('unknown role routes to /home', () {
        expect(homeForRoles(['UNKNOWN']), equals('/home'));
      });
    });

    group('role priority order: ADMIN > MANAGER > TECHNICIAN > MAINTENANCE > STAFF > customer', () {
      test('ADMIN beats MANAGER', () {
        expect(homeForRoles(['MANAGER', 'ADMIN']), equals('/admin-home'));
      });
      test('MANAGER beats TECHNICIAN', () {
        expect(homeForRoles(['TECHNICIAN', 'MANAGER']), equals('/manager'));
      });
      test('MANAGER beats CUSTOMER', () {
        expect(homeForRoles(['CUSTOMER', 'MANAGER']), equals('/manager'));
      });
      test('TECHNICIAN beats CUSTOMER', () {
        expect(homeForRoles(['CUSTOMER', 'TECHNICIAN']), equals('/technician-home'));
      });
      test('MAINTENANCE and STAFF have separate home pages', () {
        expect(homeForRoles(['MAINTENANCE']), isNot(equals('/staff-home')));
        expect(homeForRoles(['STAFF']), isNot(equals('/maintenance-home')));
      });
    });
  });
}
