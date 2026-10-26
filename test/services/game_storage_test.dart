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
  });
}
