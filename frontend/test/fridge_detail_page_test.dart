import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fm_eaa/features/fridge_detail/presentation/pages/fridge_detail_page.dart';

void main() {
  testWidgets('FridgeDetailPage renders search bar, category chips, and tabs', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: FridgeDetailPage(fridgeId: 'fridge_kitchen'),
        ),
      ),
    );

    // Verify search trigger exists
    expect(find.text('Search for items'), findsOneWidget);

    // Verify category chips exist
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Proteins'), findsOneWidget);

    // Verify Fridge / Freezer tabs exist
    expect(find.text('Fridge'), findsOneWidget);
    expect(find.text('Freezer'), findsOneWidget);
  });
}

