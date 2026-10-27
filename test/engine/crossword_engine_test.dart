// test/engine/crossword_engine_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinecross/engine/crossword_models.dart';
import 'package:cinecross/engine/crossword_engine.dart';

void main() {
  group('Crossword Engine Unit Tests', () {
    late CrosswordPuzzle puzzle;
    late CrosswordEngine engine;

    setUp(() {
      final sampleJson = {
        'id': 'test_cw',
        'name': 'Test Puzzle',
        'category': 'anime',
        'difficulty': 'easy',
        'width': 5,
        'height': 5,
        'grid': [
          ['D', 'E', 'M', 'O', 'N'],
          ['#', '#', 'A', '#', '#'],
          ['#', '#', 'P', '#', '#'],
          ['#', '#', 'P', '#', '#'],
          ['#', '#', 'A', '#', '#'],
        ],
        'words': [
          {
            'number': 1,
            'direction': 'across',
            'clue': 'ufotable hit',
            'answer': 'DEMON',
            'row': 0,
            'col': 0,
            'length': 5,
          },
          {
            'number': 2,
            'direction': 'down',
            'clue': 'JJK studio',
            'answer': 'MAPPA',
            'row': 0,
            'col': 2,
            'length': 5,
          },
        ]
      };
      puzzle = CrosswordPuzzle.fromJson(sampleJson);
      engine = CrosswordEngine(puzzle);
    });

    test('Initializes with first word selection', () {
      expect(engine.selectedRow, 0);
      expect(engine.selectedCol, 0);
      expect(engine.activeDirection, ClueDirection.across);
      expect(engine.activeWord?.answer, 'DEMON');
      expect(engine.isCompleted, isFalse);
    });

    test('Toggles direction when tapping intersecting cell', () {
      // (0, 2) is the intersection of DEMON (across) and MAPPA (down)
      engine.selectCell(0, 2);
      expect(engine.selectedRow, 0);
      expect(engine.selectedCol, 2);
      expect(engine.activeDirection, ClueDirection.across);

      // Tap same cell again -> toggles to down
      engine.selectCell(0, 2);
      expect(engine.activeDirection, ClueDirection.down);
      expect(engine.activeWord?.answer, 'MAPPA');

      // Tap again -> toggles back to across
      engine.selectCell(0, 2);
      expect(engine.activeDirection, ClueDirection.across);
    });

    test('Entering letters auto-advances along current word', () {
      engine.selectCell(0, 0);
      engine.enterLetter('D');
      expect(puzzle.grid[0][0].guess, 'D');
      expect(engine.selectedCol, 1);

      engine.enterLetter('E');
      expect(puzzle.grid[0][1].guess, 'E');
      expect(engine.selectedCol, 2);
    });

    test('Pencil mode sets draft flag without permanent entry', () {
      engine.selectCell(0, 0);
      engine.togglePencilMode();
      expect(engine.isPencilMode, isTrue);

      engine.enterLetter('D');
      expect(puzzle.grid[0][0].guess, 'D');
      expect(puzzle.grid[0][0].isPencil, isTrue);

      engine.togglePencilMode();
      expect(engine.isPencilMode, isFalse);
    });

    test('Backspace clears current cell or retreats and clears', () {
      engine.selectCell(0, 0);
      engine.enterLetter('D'); // advances to (0, 1)
      expect(engine.selectedCol, 1);

      // (0, 1) is empty -> backspace retreats to (0, 0) and clears
      engine.backspace();
      expect(engine.selectedCol, 0);
      expect(puzzle.grid[0][0].guess, '');
    });

    test('Next clue and Prev clue cycle through words', () {
      expect(engine.activeWord?.number, 1);

      engine.nextClue();
      expect(engine.activeWord?.number, 2);
      expect(engine.activeDirection, ClueDirection.down);

      engine.prevClue();
      expect(engine.activeWord?.number, 1);
      expect(engine.activeDirection, ClueDirection.across);
    });

    test('Check letter sets error flag on incorrect guess', () {
      engine.selectCell(0, 0);
      engine.enterLetter('Z'); // incorrect for 'D'

      engine.selectCell(0, 0);
      final isCorrect = engine.checkActiveLetter();
      expect(isCorrect, isFalse);
      expect(puzzle.grid[0][0].isError, isTrue);
      expect(engine.mistakesCount, 1);
    });

    test('Reveal letter and reveal word work as hints', () {
      engine.selectCell(0, 0);
      engine.revealActiveLetter();
      expect(puzzle.grid[0][0].guess, 'D');
      expect(engine.hintsUsed, 1);

      engine.selectCell(0, 2);
      engine.activeDirection = ClueDirection.down;
      engine.revealActiveWord();
      expect(puzzle.grid[0][2].guess, 'M');
      expect(puzzle.grid[1][2].guess, 'A');
      expect(puzzle.grid[2][2].guess, 'P');
      expect(puzzle.grid[3][2].guess, 'P');
      expect(puzzle.grid[4][2].guess, 'A');
      expect(engine.hintsUsed, 3);
    });

    test('3-Tier hint methods reveal progressive hints for active word', () {
      engine.selectCell(0, 0); // 1 ACROSS: DEMON
      expect(puzzle.grid[0][0].guess, '');

      // Hint 1: reveal starting letter
      final ok1 = engine.revealFirstLetterOfActiveWord();
      expect(ok1, isTrue);
      expect(puzzle.grid[0][0].guess, 'D');

      // Hint 2: reveal random letter in DEMON
      final ok2 = engine.revealRandomLetterOfActiveWord();
      expect(ok2, isTrue);
      // At least two letters now filled in DEMON
      final filledCount = [
        puzzle.grid[0][0].guess,
        puzzle.grid[0][1].guess,
        puzzle.grid[0][2].guess,
        puzzle.grid[0][3].guess,
        puzzle.grid[0][4].guess,
      ].where((g) => g.isNotEmpty).length;
      expect(filledCount, greaterThanOrEqualTo(2));

      // Hint 3: solve entire word
      engine.revealActiveWord();
      expect(puzzle.grid[0][0].guess, 'D');
      expect(puzzle.grid[0][1].guess, 'E');
      expect(puzzle.grid[0][2].guess, 'M');
      expect(puzzle.grid[0][3].guess, 'O');
      expect(puzzle.grid[0][4].guess, 'N');
      expect(engine.isWordLocked(puzzle.words[0]), isTrue);
    });

    test('Completing puzzle awards 3 stars with clean play', () {
      // Fill across: DEMON
      engine.selectCell(0, 0);
      for (final ch in ['D', 'E', 'M', 'O', 'N']) {
        engine.enterLetter(ch);
      }
      // Fill down: MAPPA (M is already at 0,2)
      engine.selectCell(1, 2);
      engine.activeDirection = ClueDirection.down;
      for (final ch in ['A', 'P', 'P', 'A']) {
        engine.enterLetter(ch);
      }

      expect(engine.isCompleted, isTrue);
      expect(engine.hintsUsed, 0);
      expect(engine.mistakesCount, 0);
      expect(engine.stars, 3);
    });
  });

  group('Prototype Assets Loading Tests', () {
    test('All 10 generated crossword JSONs parse cleanly', () {
      for (int i = 1; i <= 10; i++) {
        final id = 'cw_${i.toString().padLeft(2, '0')}';
        final file = File('assets/puzzles/crosswords/$id.json');
        expect(file.existsSync(), isTrue, reason: '$id.json must exist');

        final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final p = CrosswordPuzzle.fromJson(json);
        expect(p.words.length, greaterThanOrEqualTo(5));
        expect(p.grid.length, p.height);
        expect(p.grid[0].length, p.width);
      }
    });
  });
}
