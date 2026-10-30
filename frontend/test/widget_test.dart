import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/main.dart';

void main() {
  testWidgets('App root smoke test renders Onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FmEaaApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Reduce Food Waste'), findsOneWidget);
    expect(find.text('Enable Notifications'), findsOneWidget);
  });
}
