// test/services/game_storage_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinecross/services/game_storage.dart';

void main() {
  group('GameStorage Tests', () {
    late GameStorage storage;
    const testPath = 'test_save_data.json';

    setUp(() {
      final f = File(testPath);
      if (f.existsSync()) f.deleteSync();

      storage = GameStorage();
      storage.init(customPath: testPath);
      storage.resetAll();
    });

    tearDown(() {
      final f = File(testPath);
      if (f.existsSync()) f.deleteSync();
    });

    test('Initializes with default zero stats', () {
      expect(storage.getStars('cw_01'), 0);
      expect(storage.dailyStreak, 0);
      expect(storage.soundEnabled, isTrue);
      expect(storage.hapticsEnabled, isTrue);
      expect(storage.isDarkMode, isFalse);
      expect(storage.unlockedTitles, isEmpty);
    });

    test('Saving level results retains highest star count and unlocks title', () {
      storage.saveLevelResult('cw_01', 2, titleId: 'anime-demon-slayer-2019');
      expect(storage.getStars('cw_01'), 2);
      expect(storage.isTitleUnlocked('anime-demon-slayer-2019'), isTrue);

      // Re-saving with lower stars does not overwrite higher stars
      storage.saveLevelResult('cw_01', 1);
      expect(storage.getStars('cw_01'), 2);

      // Re-saving with higher stars updates count
      storage.saveLevelResult('cw_01', 3);
      expect(storage.getStars('cw_01'), 3);
    });

    test('Daily challenge increments streak counter', () {
      storage.recordDailyComplete('2026-10-26');
      expect(storage.dailyStreak, 1);
      expect(storage.lastDailyDate, '2026-10-26');

      // Calling again on the same day does not double-increment
      storage.recordDailyComplete('2026-10-26');
      expect(storage.dailyStreak, 1);

      // Next day increments
      storage.recordDailyComplete('2026-10-27');
      expect(storage.dailyStreak, 2);
    });

    test('Toggles preferences correctly', () {
      storage.soundEnabled = false;
      expect(storage.soundEnabled, isFalse);

      storage.hapticsEnabled = false;
      expect(storage.hapticsEnabled, isFalse);

      storage.isDarkMode = true;
      expect(storage.isDarkMode, isTrue);
    });

    test('Points earning and spending for hints works correctly', () {
      expect(storage.points, 0);
      storage.addPoints(300);
      expect(storage.points, 300);

      // Spend 50 on Hint 1
      final ok1 = storage.spendPoints(50);
      expect(ok1, isTrue);
      expect(storage.points, 250);

      // Spend 100 on Hint 2
      final ok2 = storage.spendPoints(100);
      expect(ok2, isTrue);
      expect(storage.points, 150);

      // Cannot spend 250 with only 150 balance
      final ok3 = storage.spendPoints(250);
      expect(ok3, isFalse);
      expect(storage.points, 150);

      // Earn more and spend 250 on Hint 3
      storage.addPoints(200);
      expect(storage.points, 350);
      final ok4 = storage.spendPoints(250);
      expect(ok4, isTrue);
      expect(storage.points, 100);
    });
  });
}
