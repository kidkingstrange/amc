// test/widget/rebus_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinecross/ui/screens/rebus_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('RebusScreen renders words on separate dedicated rows', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RebusScreen(
          levelId: 'rebus_01',
          levelTitle: 'Level 1: Rebus',
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify screen loaded
    expect(find.text('Level 1: Rebus'), findsOneWidget);
    expect(find.text('GUESS THE ANIME • EASY'), findsOneWidget);

    // Answer is "DEMON SLAYER" (2 words: DEMON, SLAYER)
    // Find FittedBoxes in the slot area
    final fittedBoxes = find.byType(FittedBox);
    expect(fittedBoxes, findsWidgets);

    // There should be exactly 2 word rows for DEMON and SLAYER
    // Check that each word row contains the expected number of letter slots
    final rowsInsideFittedBox = find.descendant(
      of: find.byType(FittedBox),
      matching: find.byType(Row),
    );
    expect(rowsInsideFittedBox, findsNWidgets(2));
  });
}
