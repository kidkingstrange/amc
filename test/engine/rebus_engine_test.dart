// test/engine/rebus_engine_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinecross/engine/rebus_engine.dart';

void main() {
  group('Rebus Engine Unit Tests', () {
    late RebusPuzzle puzzle;
    late RebusEngine engine;

    setUp(() {
      final sampleJson = {
        'id': 'test_rebus',
        'titleId': 'movie-inception-2010',
        'name': 'Inception',
        'category': 'movie',
        'difficulty': 'easy',
        'emojis': '🌀 💤 🏙️',
        'answer': 'INCEPTION',
        'explanation': 'Spinning top and dream layers.',
        'hintLadder': {
          'hint1': 'Movie released in 2010',
          'hint2': 'First letter: I',
          'hint3': 'Length: 9 letters',
          'hint4': 'Spinning top and dream layers.',
        }
      };
      puzzle = RebusPuzzle.fromJson(sampleJson);
      engine = RebusEngine(puzzle);
    });

    test('Initializes with correct slot count and active slot', () {
      expect(engine.slots.length, 9);
      expect(engine.activeIndex, 0);
      expect(engine.activeSlot.solutionChar, 'I');
      expect(engine.isCompleted, isFalse);
    });

    test('Treats spaces as fixed non-editable separators', () {
      final multiWordJson = {
        'id': 'multi_word',
        'titleId': 'anime-spy-x-family-2022',
        'name': 'Spy x Family',
        'category': 'anime',
        'difficulty': 'easy',
        'emojis': '🕵️ 🥜',
        'answer': 'SPY X FAMILY',
        'explanation': 'Twilight and Anya.',
        'hintLadder': {
          'hint1': 'Anime 2022',
          'hint2': 'First letter: S',
          'hint3': 'Length: 10 letters',
          'hint4': 'Twilight and Anya.',
        }
      };
      final p = RebusPuzzle.fromJson(multiWordJson);
      final eng = RebusEngine(p);

      expect(eng.slots.length, 12); // S P Y _ X _ F A M I L Y
      expect(eng.slots[3].isSeparator, isTrue);
      expect(eng.slots[3].solutionChar, ' ');
      expect(eng.slots[5].isSeparator, isTrue);
      expect(eng.slots[5].solutionChar, ' ');
    });

    test('Entering letters advances slots and checks completion', () {
      final word = 'INCEPTION';
      for (int i = 0; i < word.length; i++) {
        engine.enterLetter(word[i]);
      }
      expect(engine.isCompleted, isTrue);
      expect(engine.stars, 3);
    });

    test('Backspace clears current slot or retreats to previous slot', () {
      engine.enterLetter('I');
      expect(engine.activeIndex, 1);

      engine.backspace();
      expect(engine.activeIndex, 0);
      expect(engine.slots[0].guess, '');
    });

    test('Unlocking hints updates ladder and fills clues', () {
      engine.unlockHint(1);
      expect(engine.unlockedHints.contains(1), isTrue);

      // Hint 2 reveals first letter
      engine.unlockHint(2);
      expect(engine.unlockedHints.contains(2), isTrue);
      expect(engine.slots[0].guess, 'I');
      expect(engine.slots[0].isRevealed, isTrue);

      // Hint 3 reveals random letter
      engine.unlockHint(3);
      expect(engine.unlockedHints.contains(3), isTrue);
      final revealedCount = engine.slots.where((s) => s.isRevealed).length;
      expect(revealedCount, greaterThanOrEqualTo(2));

      // Hint 4: reveal full answer
      engine.revealFullAnswer();
      expect(engine.isCompleted, isTrue);
      expect(engine.slots.map((s) => s.guess).join(), 'INCEPTION');
    });
  });

  group('Prototype Rebus Assets Loading Tests', () {
    test('All 10 generated rebus JSONs parse cleanly', () {
      for (int i = 1; i <= 10; i++) {
        final id = 'rebus_${i.toString().padLeft(2, '0')}';
        final file = File('assets/puzzles/rebus/$id.json');
        expect(file.existsSync(), isTrue, reason: '$id.json must exist');

        final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final p = RebusPuzzle.fromJson(json);
        expect(p.answer.isNotEmpty, isTrue);
        expect(p.emojis.isNotEmpty, isTrue);
        expect(p.explanation.isNotEmpty, isTrue);
      }
    });
  });
}
