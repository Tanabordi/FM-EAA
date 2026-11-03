import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/core/theme/freshness_colors.dart';
import 'package:fm_eaa/shared/widgets/status_badge.dart';

void main() {
  group('StatusBadge Widget Tests', () {
    testWidgets('Renders Fresh status correctly with outline star', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: FreshnessStatus.fresh),
          ),
        ),
      );

      expect(find.text('Fresh'), findsOneWidget);
      expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);
    });

    testWidgets('Renders Use soon with custom days text and clock icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(
              status: FreshnessStatus.useSoon,
              customLabel: '2 days left',
            ),
          ),
        ),
      );

      expect(find.text('2 days left'), findsOneWidget);
      expect(find.byIcon(Icons.access_time_rounded), findsOneWidget);
    });

    testWidgets('Renders Expired status correctly with alert circle outline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: FreshnessStatus.expired),
          ),
        ),
      );

      expect(find.text('Expired'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });
  });
}
