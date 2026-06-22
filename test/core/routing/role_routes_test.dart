import 'package:flutter_test/flutter_test.dart';
import 'package:smart_laundry_locker/core/routing/role_routes.dart';

void main() {
  group('homeForRoles', () {
    group('MANAGER / ADMIN', () {
      test('MANAGER routes to /manager', () {
        expect(homeForRoles(['MANAGER']), equals('/manager'));
      });
      test('ADMIN routes to /manager', () {
        expect(homeForRoles(['ADMIN']), equals('/manager'));
      });
      test('MANAGER+ADMIN routes to /manager', () {
        expect(homeForRoles(['MANAGER', 'ADMIN']), equals('/manager'));
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

    group('role priority (highest wins)', () {
      test('MANAGER takes priority over CUSTOMER', () {
        expect(homeForRoles(['CUSTOMER', 'MANAGER']), equals('/manager'));
      });
      test('TECHNICIAN takes priority over CUSTOMER', () {
        expect(homeForRoles(['CUSTOMER', 'TECHNICIAN']), equals('/technician-home'));
      });
      test('MAINTENANCE is separate from STAFF', () {
        // MAINTENANCE and STAFF are different roles with different home pages
        expect(homeForRoles(['MAINTENANCE']), isNot(equals('/staff-home')));
        expect(homeForRoles(['STAFF']), isNot(equals('/maintenance-home')));
      });
    });
  });
}
