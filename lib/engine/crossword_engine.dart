// lib/engine/crossword_engine.dart
import 'dart:math';
import 'crossword_models.dart';

enum WordFeedback { none, wordCorrect, wordWrong }

class CrosswordEngine {
  final CrosswordPuzzle puzzle;

  int selectedRow = 0;
  int selectedCol = 0;
  ClueDirection activeDirection = ClueDirection.across;
  bool isPencilMode = false;

  int hintsUsed = 0;
  int mistakesCount = 0;
  int timerSeconds = 0;
  bool isCompleted = false;

  final Set<String> _lockedWords = {};

  CrosswordEngine(this.puzzle) {
    _initFirstSelection();
  }

  void _initFirstSelection() {
    if (puzzle.words.isNotEmpty) {
      final firstWord = puzzle.words.first;
      selectedRow = firstWord.row;
      selectedCol = firstWord.col;
      activeDirection = firstWord.direction;
    }
  }

  CrosswordCell get selectedCell => puzzle.grid[selectedRow][selectedCol];

  CrosswordWord? get activeWord {
    for (final w in puzzle.words) {
      if (w.direction == activeDirection) {
        if (activeDirection == ClueDirection.across) {
          if (w.row == selectedRow &&
              selectedCol >= w.col &&
              selectedCol < w.col + w.length) {
            return w;
          }
        } else {
          if (w.col == selectedCol &&
              selectedRow >= w.row &&
              selectedRow < w.row + w.length) {
            return w;
          }
        }
      }
    }
    return null;
  }

  void selectCell(int r, int c) {
    if (r < 0 || r >= puzzle.height || c < 0 || c >= puzzle.width) return;
    if (puzzle.grid[r][c].isBlocked) return;

    if (selectedRow == r && selectedCol == c) {
      _toggleDirectionIfPossible();
    } else {
      selectedRow = r;
      selectedCol = c;
      _ensureValidDirectionForCell();
    }
  }

  void _toggleDirectionIfPossible() {
    final other = activeDirection == ClueDirection.across
        ? ClueDirection.down
        : ClueDirection.across;

    bool hasWordInOther = false;
    for (final w in puzzle.words) {
      if (w.direction == other) {
        if (other == ClueDirection.across) {
          if (w.row == selectedRow &&
              selectedCol >= w.col &&
              selectedCol < w.col + w.length) {
            hasWordInOther = true;
            break;
          }
        } else {
          if (w.col == selectedCol &&
              selectedRow >= w.row &&
              selectedRow < w.row + w.length) {
            hasWordInOther = true;
            break;
          }
        }
      }
    }

    if (hasWordInOther) {
      activeDirection = other;
    }
  }

  void _ensureValidDirectionForCell() {
    if (activeWord == null) {
      activeDirection = activeDirection == ClueDirection.across
          ? ClueDirection.down
          : ClueDirection.across;
    }
  }

  bool isWordLocked(CrosswordWord word) {
    return _lockedWords.contains('${word.number}_${word.direction.name}');
  }

  int get solvedWordsCount => _lockedWords.length;

  bool _isWordCompletelyFilled(CrosswordWord word) {
    for (int i = 0; i < word.length; i++) {
      final r = word.direction == ClueDirection.across ? word.row : word.row + i;
      final c = word.direction == ClueDirection.across ? word.col + i : word.col;
      if (puzzle.grid[r][c].guess.isEmpty) return false;
    }
    return true;
  }

  bool _isWordCompletelyCorrect(CrosswordWord word) {
    for (int i = 0; i < word.length; i++) {
      final r = word.direction == ClueDirection.across ? word.row : word.row + i;
      final c = word.direction == ClueDirection.across ? word.col + i : word.col;
      final cell = puzzle.grid[r][c];
      if (cell.guess != cell.solution) return false;
    }
    return true;
  }

  void _lockWord(CrosswordWord word) {
    _lockedWords.add('${word.number}_${word.direction.name}');
    for (int i = 0; i < word.length; i++) {
      final r = word.direction == ClueDirection.across ? word.row : word.row + i;
      final c = word.direction == ClueDirection.across ? word.col + i : word.col;
      final cell = puzzle.grid[r][c];
      cell.isLocked = true;
      cell.isError = false;
      cell.isPencil = false;
    }
  }

  void _markWordErrors(CrosswordWord word) {
    mistakesCount++;
    for (int i = 0; i < word.length; i++) {
      final r = word.direction == ClueDirection.across ? word.row : word.row + i;
      final c = word.direction == ClueDirection.across ? word.col + i : word.col;
      final cell = puzzle.grid[r][c];
      if (!cell.isLocked && cell.guess != cell.solution) {
        cell.isError = true;
      }
    }
  }

  void _advanceToNextUnsolvedWord() {
    for (final w in puzzle.words) {
      if (!isWordLocked(w)) {
        selectedRow = w.row;
        selectedCol = w.col;
        activeDirection = w.direction;
        while (selectedCell.isLocked && !_isAtEndOfWord(w)) {
          _advanceAlongCurrentWord();
        }
        break;
      }
    }
  }

  bool _isAtEndOfWord(CrosswordWord w) {
    if (w.direction == ClueDirection.across) {
      return selectedCol >= w.col + w.length - 1;
    } else {
      return selectedRow >= w.row + w.length - 1;
    }
  }

  WordFeedback enterLetter(String rawLetter) {
    if (isCompleted) return WordFeedback.none;
    if (selectedCell.isBlocked) return WordFeedback.none;

    final letter = rawLetter.trim().toUpperCase();
    if (letter.isEmpty) return WordFeedback.none;

    if (!selectedCell.isLocked) {
      if (isPencilMode) {
        selectedCell.guess = letter;
        selectedCell.isPencil = true;
        selectedCell.isError = false;
      } else {
        selectedCell.guess = letter;
        selectedCell.isPencil = false;
        selectedCell.isError = false;
      }
    }

    // Auto-advance to next unlocked cell along current word
    _advanceAlongCurrentWord();

    // Check if the current word just became completely filled
    WordFeedback feedback = WordFeedback.none;
    final currentWord = activeWord;
    if (currentWord != null && !isWordLocked(currentWord)) {
      if (_isWordCompletelyFilled(currentWord)) {
        if (_isWordCompletelyCorrect(currentWord)) {
          _lockWord(currentWord);
          feedback = WordFeedback.wordCorrect;
          _advanceToNextUnsolvedWord();
        } else {
          _markWordErrors(currentWord);
          feedback = WordFeedback.wordWrong;
        }
      }
    }

    _checkPuzzleCompletion();
    return feedback;
  }

  void backspace() {
    if (isCompleted) return;
    if (selectedCell.isBlocked) return;

    if (!selectedCell.isLocked && selectedCell.guess.isNotEmpty) {
      selectedCell.clear();
    } else {
      _retreatAlongCurrentWord();
      if (!selectedCell.isLocked) {
        selectedCell.clear();
      }
    }
  }

  void _advanceAlongCurrentWord() {
    final word = activeWord;
    if (word == null) return;

    if (activeDirection == ClueDirection.across) {
      int nextCol = selectedCol + 1;
      while (nextCol < word.col + word.length &&
          nextCol < puzzle.width &&
          puzzle.grid[selectedRow][nextCol].isLocked) {
        nextCol++;
      }
      if (nextCol < word.col + word.length && nextCol < puzzle.width) {
        if (!puzzle.grid[selectedRow][nextCol].isBlocked) {
          selectedCol = nextCol;
        }
      }
    } else {
      int nextRow = selectedRow + 1;
      while (nextRow < word.row + word.length &&
          nextRow < puzzle.height &&
          puzzle.grid[nextRow][selectedCol].isLocked) {
        nextRow++;
      }
      if (nextRow < word.row + word.length && nextRow < puzzle.height) {
        if (!puzzle.grid[nextRow][selectedCol].isBlocked) {
          selectedRow = nextRow;
        }
      }
    }
  }

  void _retreatAlongCurrentWord() {
    final word = activeWord;
    if (word == null) return;

    if (activeDirection == ClueDirection.across) {
      int prevCol = selectedCol - 1;
      while (prevCol >= word.col && puzzle.grid[selectedRow][prevCol].isLocked) {
        prevCol--;
      }
      if (prevCol >= word.col) {
        selectedCol = prevCol;
      }
    } else {
      int prevRow = selectedRow - 1;
      while (prevRow >= word.row && puzzle.grid[prevRow][selectedCol].isLocked) {
        prevRow--;
      }
      if (prevRow >= word.row) {
        selectedRow = prevRow;
      }
    }
  }

  void nextClue() {
    if (puzzle.words.isEmpty) return;
    final current = activeWord;
    final currentIndex = current == null ? -1 : puzzle.words.indexOf(current);
    final nextIndex = (currentIndex + 1) % puzzle.words.length;
    final nextWord = puzzle.words[nextIndex];

    selectedRow = nextWord.row;
    selectedCol = nextWord.col;
    activeDirection = nextWord.direction;
  }

  void prevClue() {
    if (puzzle.words.isEmpty) return;
    final current = activeWord;
    final currentIndex = current == null ? 0 : puzzle.words.indexOf(current);
    final prevIndex =
        (currentIndex - 1 + puzzle.words.length) % puzzle.words.length;
    final prevWord = puzzle.words[prevIndex];

    selectedRow = prevWord.row;
    selectedCol = prevWord.col;
    activeDirection = prevWord.direction;
  }

  void togglePencilMode() {
    isPencilMode = !isPencilMode;
  }

  bool checkActiveLetter() {
    if (selectedCell.isBlocked || selectedCell.isEmpty) return false;
    final correct = selectedCell.guess == selectedCell.solution;
    if (!correct) {
      selectedCell.isError = true;
      mistakesCount++;
    } else {
      selectedCell.isError = false;
    }
    return correct;
  }

  bool revealFirstLetterOfActiveWord() {
    final word = activeWord;
    if (word == null || isWordLocked(word)) return false;

    for (int i = 0; i < word.length; i++) {
      final r = word.direction == ClueDirection.across ? word.row : word.row + i;
      final c = word.direction == ClueDirection.across ? word.col + i : word.col;
      final cell = puzzle.grid[r][c];
      if (cell.guess != cell.solution) {
        cell.guess = cell.solution;
        cell.isPencil = false;
        cell.isError = false;
        hintsUsed++;
        if (_isWordCompletelyFilled(word) && _isWordCompletelyCorrect(word)) {
          _lockWord(word);
        }
        _checkPuzzleCompletion();
        return true;
      }
    }
    return false;
  }

  bool revealRandomLetterOfActiveWord() {
    final word = activeWord;
    if (word == null || isWordLocked(word)) return false;

    final unrevealedIndices = <int>[];
    for (int i = 0; i < word.length; i++) {
      final r = word.direction == ClueDirection.across ? word.row : word.row + i;
      final c = word.direction == ClueDirection.across ? word.col + i : word.col;
      final cell = puzzle.grid[r][c];
      if (cell.guess != cell.solution) {
        unrevealedIndices.add(i);
      }
    }

    if (unrevealedIndices.isEmpty) return false;

    final randomIndex = unrevealedIndices[Random().nextInt(unrevealedIndices.length)];
    final r = word.direction == ClueDirection.across ? word.row : word.row + randomIndex;
    final c = word.direction == ClueDirection.across ? word.col + randomIndex : word.col;
    final cell = puzzle.grid[r][c];
    cell.guess = cell.solution;
    cell.isPencil = false;
    cell.isError = false;
    hintsUsed++;

    if (_isWordCompletelyFilled(word) && _isWordCompletelyCorrect(word)) {
      _lockWord(word);
    }
    _checkPuzzleCompletion();
    return true;
  }

  void revealActiveLetter() {
    if (selectedCell.isBlocked) return;
    selectedCell.guess = selectedCell.solution;
    selectedCell.isPencil = false;
    selectedCell.isError = false;
    hintsUsed++;

    final currentWord = activeWord;
    if (currentWord != null && !isWordLocked(currentWord)) {
      if (_isWordCompletelyFilled(currentWord) && _isWordCompletelyCorrect(currentWord)) {
        _lockWord(currentWord);
      }
    }

    _advanceAlongCurrentWord();
    _checkPuzzleCompletion();
  }

  void revealActiveWord() {
    final word = activeWord;
    if (word == null) return;

    for (int i = 0; i < word.length; i++) {
      final r = word.direction == ClueDirection.across ? word.row : word.row + i;
      final c = word.direction == ClueDirection.across ? word.col + i : word.col;
      final cell = puzzle.grid[r][c];
      cell.guess = cell.solution;
      cell.isPencil = false;
      cell.isError = false;
    }
    _lockWord(word);
    hintsUsed += 2;
    _advanceToNextUnsolvedWord();
    _checkPuzzleCompletion();
  }

  void _checkPuzzleCompletion() {
    for (int r = 0; r < puzzle.height; r++) {
      for (int c = 0; c < puzzle.width; c++) {
        final cell = puzzle.grid[r][c];
        if (!cell.isBlocked) {
          if (cell.guess != cell.solution) {
            isCompleted = false;
            return;
          }
        }
      }
    }
    isCompleted = true;
  }

  int get stars {
    if (!isCompleted) return 0;
    if (hintsUsed == 0 && mistakesCount <= 2) return 3;
    if (hintsUsed <= 2 && mistakesCount <= 5) return 2;
    return 1;
  }
}
