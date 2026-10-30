import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/main.dart';

void main() {
  testWidgets('App root smoke test renders Sign In screen by default', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FmEaaApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}
