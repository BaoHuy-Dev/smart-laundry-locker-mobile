import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_laundry_locker/app.dart';
import 'package:smart_laundry_locker/core/constants/app_constants.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(child: App()));

    // Verify the routed app renders without crashing.
    expect(find.text(AppConstants.appName), findsOneWidget);
  });
}
