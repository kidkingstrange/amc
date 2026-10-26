// test/widget_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cinecross/main.dart';

void main() {
  testWidgets('CineCrossApp loads Home Screen with tabs, daily banner, and levels', (tester) async {
    await tester.pumpWidget(const CineCrossApp());
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Anime and Movies Crossword'), findsOneWidget);

    // Verify Tabs
    expect(find.text('Crosswords (10)'), findsOneWidget);
    expect(find.text('Emoji Rebus (10)'), findsOneWidget);

    // Verify Daily Challenge banner
    expect(find.text('DAILY CHALLENGE'), findsOneWidget);

    // Verify level item appears
    expect(find.text('Level 1: Demon & Sorcery'), findsWidgets);
  });
}
