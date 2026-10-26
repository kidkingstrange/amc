// lib/services/game_storage.dart
import 'dart:convert';
import 'dart:io';

class GameStorage {
  static final GameStorage _instance = GameStorage._internal();
  factory GameStorage() => _instance;
  GameStorage._internal();

  File? _file;
  Map<String, dynamic> _data = {
    'stars': <String, int>{},
    'unlockedTitles': <String>[],
    'dailyStreak': 0,
    'lastDailyDate': '',
    'points': 0,
    'soundEnabled': true,
    'hapticsEnabled': true,
    'isDarkMode': false,
  };

  void init({String? customPath}) {
    final path = customPath ?? 'user_save_data.json';
    try {
      _file = File(path);
      if (_file!.existsSync()) {
        final raw = _file!.readAsStringSync();
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _data = decoded;
      } else {
        _persist();
      }
    } catch (_) {
      // In-memory fallback if file system access is constrained
    }
  }

  void _persist() {
    try {
      if (_file != null) {
        _file!.writeAsStringSync(jsonEncode(_data));
      }
    } catch (_) {
      // Graceful fallback
    }
  }

  // Stars and Progress
  int getStars(String levelId) {
    final map = (_data['stars'] as Map?) ?? {};
    return (map[levelId] as int?) ?? 0;
  }

  void saveLevelResult(String levelId, int stars, {String? titleId}) {
    final map = Map<String, dynamic>.from((_data['stars'] as Map?) ?? {});
    final existing = (map[levelId] as int?) ?? 0;
    if (stars > existing) {
      map[levelId] = stars;
      _data['stars'] = map;
    }

    if (titleId != null) {
      unlockTitle(titleId);
    }
    _persist();
  }

  // Points / Score System
  int get points => (_data['points'] as int?) ?? 0;

  void addPoints(int amount) {
    if (amount <= 0) return;
    _data['points'] = points + amount;
    _persist();
  }

  // Collection / Dex Unlocks
  bool isTitleUnlocked(String titleId) {
    final list = List<String>.from((_data['unlockedTitles'] as List?) ?? []);
    return list.contains(titleId);
  }

  void unlockTitle(String titleId) {
    final list = List<String>.from((_data['unlockedTitles'] as List?) ?? []);
    if (!list.contains(titleId)) {
      list.add(titleId);
      _data['unlockedTitles'] = list;
      _persist();
    }
  }

  List<String> get unlockedTitles {
    return List<String>.from((_data['unlockedTitles'] as List?) ?? []);
  }

  // Daily Challenge & Streak
  int get dailyStreak => (_data['dailyStreak'] as int?) ?? 0;
  String get lastDailyDate => (_data['lastDailyDate'] as String?) ?? '';

  void recordDailyComplete(String dateStr) {
    if (lastDailyDate == dateStr) return; // already recorded today

    int currentStreak = dailyStreak;
    // Simple consecutive day calculation
    currentStreak++;
    _data['dailyStreak'] = currentStreak;
    _data['lastDailyDate'] = dateStr;
    _persist();
  }

  // Settings
  bool get soundEnabled => (_data['soundEnabled'] as bool?) ?? true;
  set soundEnabled(bool value) {
    _data['soundEnabled'] = value;
    _persist();
  }

  bool get hapticsEnabled => (_data['hapticsEnabled'] as bool?) ?? true;
  set hapticsEnabled(bool value) {
    _data['hapticsEnabled'] = value;
    _persist();
  }

  bool get isDarkMode => (_data['isDarkMode'] as bool?) ?? false;
  set isDarkMode(bool value) {
    _data['isDarkMode'] = value;
    _persist();
  }

  void resetAll() {
    _data = {
      'stars': <String, int>{},
      'unlockedTitles': <String>[],
      'dailyStreak': 0,
      'lastDailyDate': '',
      'points': 0,
      'soundEnabled': true,
      'hapticsEnabled': true,
      'isDarkMode': false,
    };
    _persist();
  }
}
