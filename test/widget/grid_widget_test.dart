// test/widget/grid_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinecross/engine/crossword_models.dart';
import 'package:cinecross/engine/crossword_engine.dart';
import 'package:cinecross/ui/widgets/crossword_grid_widget.dart';

void main() {
  testWidgets('CrosswordGridWidget renders cells and reacts to cell tap', (tester) async {
    final sampleJson = {
      'id': 'test_grid',
      'name': 'Test Grid',
      'category': 'anime',
      'difficulty': 'easy',
      'width': 3,
      'height': 3,
      'grid': [
        ['A', 'B', 'C'],
        ['#', '#', '#'],
        ['#', '#', '#'],
      ],
      'words': [
        {
          'number': 1,
          'direction': 'across',
          'clue': 'ABC',
          'answer': 'ABC',
          'row': 0,
          'col': 0,
          'length': 3,
        }
      ]
    };
    final puzzle = CrosswordPuzzle.fromJson(sampleJson);
    final engine = CrosswordEngine(puzzle);
    bool stateChanged = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CrosswordGridWidget(
            engine: engine,
            onStateChanged: () => stateChanged = true,
          ),
        ),
      ),
    );

    // Initial selected cell is (0,0)
    expect(engine.selectedCol, 0);

    // Tap cell (0, 1)
    final cellFinder = find.byType(GestureDetector);
    expect(cellFinder, findsWidgets);

    // Tap second cell
    await tester.tap(cellFinder.at(1));
    await tester.pumpAndSettle();

    expect(stateChanged, isTrue);
    expect(engine.selectedCol, 1);
  });
}
