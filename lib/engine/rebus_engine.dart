// lib/engine/rebus_engine.dart
import 'dart:math';

class RebusPuzzle {
  final String id;
  final String titleId;
  final String name;
  final String category;
  final String difficulty;
  final String emojis;
  final String answer; // Uppercase, e.g. "DEMON SLAYER"
  final String explanation;
  final Map<String, dynamic> hintLadder;

  RebusPuzzle({
    required this.id,
    required this.titleId,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.emojis,
    required this.answer,
    required this.explanation,
    required this.hintLadder,
  });

  factory RebusPuzzle.fromJson(Map<String, dynamic> json) {
    return RebusPuzzle(
      id: json['id'] as String,
      titleId: json['titleId'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      emojis: json['emojis'] as String,
      answer: (json['answer'] as String).toUpperCase(),
      explanation: json['explanation'] as String,
      hintLadder: json['hintLadder'] as Map<String, dynamic>,
    );
  }
}

class RebusSlot {
  final int index;
  final String solutionChar;
  final bool isSeparator; // true for space, hyphen, punctuation

  String guess;
  bool isRevealed;

  RebusSlot({
    required this.index,
    required this.solutionChar,
    this.isSeparator = false,
    this.guess = '',
    this.isRevealed = false,
  });

  bool get isFilled => isSeparator || guess.isNotEmpty;
  bool get isCorrect => isSeparator || (guess == solutionChar);
}

class RebusEngine {
  final RebusPuzzle puzzle;
  late List<RebusSlot> slots;
  int activeIndex = 0;
  final Set<int> unlockedHints = {};
  int mistakesCount = 0;
  bool isCompleted = false;

  RebusEngine(this.puzzle) {
    _initSlots();
  }

  void _initSlots() {
    slots = [];
    for (int i = 0; i < puzzle.answer.length; i++) {
      final char = puzzle.answer[i];
      final isSep = !RegExp(r'[A-Z0-9]').hasMatch(char);
      slots.add(RebusSlot(
        index: i,
        solutionChar: char,
        isSeparator: isSep,
        guess: isSep ? char : '',
      ));
    }
    _advanceToFirstEditable();
  }

  void _advanceToFirstEditable() {
    for (int i = 0; i < slots.length; i++) {
      if (!slots[i].isSeparator && slots[i].guess.isEmpty) {
        activeIndex = i;
        return;
      }
    }
    activeIndex = 0;
  }

  RebusSlot get activeSlot => slots[activeIndex];

  void selectSlot(int index) {
    if (index >= 0 && index < slots.length && !slots[index].isSeparator) {
      activeIndex = index;
    }
  }

  void enterLetter(String rawLetter) {
    if (isCompleted) return;
    final letter = rawLetter.trim().toUpperCase();
    if (letter.isEmpty) return;

    if (!activeSlot.isSeparator) {
      activeSlot.guess = letter;
      _advanceNextSlot();
      _checkCompletion();
    }
  }

  void backspace() {
    if (isCompleted) return;
    if (!activeSlot.isSeparator && activeSlot.guess.isNotEmpty) {
      activeSlot.guess = '';
    } else {
      _retreatPrevSlot();
      if (!activeSlot.isSeparator) {
        activeSlot.guess = '';
      }
    }
  }

  void _advanceNextSlot() {
    for (int i = activeIndex + 1; i < slots.length; i++) {
      if (!slots[i].isSeparator && slots[i].guess.isEmpty) {
        activeIndex = i;
        return;
      }
    }
    // If all forward slots filled, find any empty slot
    for (int i = 0; i < slots.length; i++) {
      if (!slots[i].isSeparator && slots[i].guess.isEmpty) {
        activeIndex = i;
        return;
      }
    }
  }

  void _retreatPrevSlot() {
    for (int i = activeIndex - 1; i >= 0; i--) {
      if (!slots[i].isSeparator) {
        activeIndex = i;
        return;
      }
    }
  }

  void unlockHint(int hintLevel) {
    if (hintLevel < 1 || hintLevel > 4) return;
    unlockedHints.add(hintLevel);

    if (hintLevel == 2) {
      // Reveal first letter
      for (final slot in slots) {
        if (!slot.isSeparator) {
          slot.guess = slot.solutionChar;
          slot.isRevealed = true;
          break;
        }
      }
    } else if (hintLevel == 3) {
      // Reveal a random unrevealed letter
      final unrevealed = slots.where((s) => !s.isSeparator && !s.isRevealed && s.guess != s.solutionChar).toList();
      if (unrevealed.isNotEmpty) {
        final rand = unrevealed[Random().nextInt(unrevealed.length)];
        rand.guess = rand.solutionChar;
        rand.isRevealed = true;
      }
    }
    _checkCompletion();
  }

  void _checkCompletion() {
    for (final slot in slots) {
      if (!slot.isCorrect) {
        isCompleted = false;
        return;
      }
    }
    isCompleted = true;
  }

  int get stars {
    if (!isCompleted) return 0;
    if (unlockedHints.isEmpty && mistakesCount == 0) return 3;
    if (unlockedHints.length <= 2) return 2;
    return 1;
  }
}
