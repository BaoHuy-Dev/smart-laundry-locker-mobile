# Testing Guide — Smart Laundry Locker Mobile

## Overview

This project uses **Flutter unit & widget tests** — fast, no device or emulator required. Tests run in the Dart VM in ~2–5 seconds.

```
test/
├── helpers/
│   └── test_helpers.dart          # Shared mock Dio factory + response builders
├── core/
│   └── routing/
│       └── role_routes_test.dart  # Pure Dart unit tests for role-based routing
└── features/
    └── locker_ops/
        └── locker_ops_service_test.dart  # HTTP service tests (mocked network)
```

---

## Running Tests

```bash
# Run all tests
flutter test

# Run a single file
flutter test test/core/routing/role_routes_test.dart

# Run with verbose output
flutter test --reporter expanded

# Run tests matching a name pattern
flutter test --name "MAINTENANCE"
```

> Flutter must be on your PATH. If not, use the full path: `~/flutter/bin/flutter test`

---

## Test Architecture

### 1. Pure Dart unit tests

For functions with no Flutter or network dependencies. No setup needed.

```dart
// test/core/routing/role_routes_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_laundry_locker/core/routing/role_routes.dart';

void main() {
  test('MAINTENANCE routes to /maintenance-home', () {
    expect(homeForRoles(['MAINTENANCE']), equals('/maintenance-home'));
  });
}
```

Use this pattern for: routing logic, validators, formatters, pure utility functions.

---

### 2. Service tests (mocked HTTP via `http_mock_adapter`)

`LockerOpsService` accepts an optional `Dio` in its constructor — pass a mock `Dio` with a `DioAdapter` to intercept all HTTP calls without hitting the real backend.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_laundry_locker/features/locker_ops/data/locker_ops_service.dart';
import '../../helpers/test_helpers.dart';

void main() {
  late LockerOpsService service;
  late DioAdapter adapter;

  setUp(() {
    final mock = createMockDio();   // creates Dio + DioAdapter bound together
    adapter = mock.adapter;
    service = LockerOpsService(dio: mock.dio);
  });

  test('myOrders() returns order list', () async {
    // 1. Register a mock route
    adapter.onGet('/api/orders/my-orders', (server) => server.reply(
      200,
      apiOk([{'id': 1, 'type': 'SEND', 'status': 'INITIALIZED'}]),
    ));

    // 2. Call the service
    final result = await service.myOrders();

    // 3. Assert
    expect(result, hasLength(1));
    expect(result.first['type'], equals('SEND'));
  });
}
```

#### HTTP method reference

| DioAdapter method | When to use |
|---|---|
| `adapter.onGet(path, handler)` | GET requests |
| `adapter.onPost(path, handler)` | POST requests |
| `adapter.onPut(path, handler)` | PUT requests (status changes, confirms, cancels) |
| `adapter.onDelete(path, handler)` | DELETE requests |

#### Response status codes

```dart
server.reply(200, apiOk(data))        // success — wraps data in {success: true, data: ...}
server.reply(400, apiError('message')) // client error — service should throw
server.reply(401, apiError('Unauthorized'))
server.reply(500, apiError('Internal Server Error'))
```

---

## Helper Reference (`test/helpers/test_helpers.dart`)

| Helper | Purpose |
|---|---|
| `createMockDio()` | Returns `({Dio dio, DioAdapter adapter})` — create once per `setUp` |
| `apiOk(data)` | Wraps data in the backend success envelope `{success, code, message, data}` |
| `apiError(message)` | Wraps message in the error envelope |
| `mockSecureStorage()` | Initializes `FlutterSecureStorage` with empty in-memory store (needed if the code under test reads tokens) |
| `kTestBaseUrl` | Base URL constant used by `createMockDio()` (`http://test.local`) |

---

## Writing a New Service Test

Follow these steps when a new endpoint is added to `LockerOpsService`:

**Step 1** — Find the method signature and HTTP details:
```dart
// In lib/features/locker_ops/data/locker_ops_service.dart
Future<Map<String, dynamic>> claimReport(int reportId) =>
    _map('PUT', '/api/maintenance/reports/$reportId/claim');
```

**Step 2** — Add a test group in `locker_ops_service_test.dart`:
```dart
test('claimReport() returns IN_PROGRESS status', () async {
  adapter.onPut('/api/maintenance/reports/42/claim', (server) => server.reply(
    200,
    apiOk({'id': 42, 'status': 'IN_PROGRESS'}),
  ));

  final result = await service.claimReport(42);
  expect(result['status'], equals('IN_PROGRESS'));
});
```

**Step 3** — Run and verify:
```bash
flutter test test/features/locker_ops/locker_ops_service_test.dart
```

---

## Writing a New Routing Test

When a new role or route is added to `role_routes.dart`, add a case in `role_routes_test.dart`:

```dart
group('NEW_ROLE', () {
  test('NEW_ROLE routes to /new-home', () {
    expect(homeForRoles(['NEW_ROLE']), equals('/new-home'));
  });

  test('NEW_ROLE does not fall back to /home', () {
    expect(homeForRoles(['NEW_ROLE']), isNot(equals('/home')));
  });
});
```

---

## What Is NOT Tested Here

| Topic | Why excluded |
|---|---|
| UI rendering (widgets) | Requires `pumpWidget` + full app context; added separately when needed |
| Auth flow (login/OTP) | Depends on `TokenService` + `FlutterSecureStorage`; use integration tests |
| STOMP WebSocket | Real-time; unit testing provides low value |
| GoRouter navigation | Requires full router setup; test with `GoRouter.of(context)` integration tests |

---

## CI Status

> **Not yet automated.** Tests currently run manually only.
>
> To add CI, create `.github/workflows/flutter-test.yml` in this repo:
>
> ```yaml
> name: Flutter Tests
> on:
>   pull_request:
>     branches: [develop, main]
> jobs:
>   test:
>     runs-on: ubuntu-latest
>     steps:
>       - uses: actions/checkout@v4
>       - uses: subosito/flutter-action@v2
>         with:
>           flutter-version: '3.44.0'
>       - run: flutter pub get
>       - run: flutter test
> ```
