// lib/engine/crossword_engine.dart
import 'crossword_models.dart';

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
    // Fallback if no matching word in current direction: find other direction word for cell
    for (final w in puzzle.words) {
      if (w.direction != activeDirection) {
        if (w.direction == ClueDirection.across) {
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
      // Toggle direction if cell supports both across and down
      _toggleDirectionIfPossible();
    } else {
      selectedRow = r;
      selectedCol = c;
      // Ensure activeDirection is valid for this new cell
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
    // If active direction does not pass through this cell, switch direction
    if (activeWord == null) {
      activeDirection = activeDirection == ClueDirection.across
          ? ClueDirection.down
          : ClueDirection.across;
    }
  }

  void enterLetter(String rawLetter) {
    if (isCompleted) return;
    if (selectedCell.isBlocked) return;

    final letter = rawLetter.trim().toUpperCase();
    if (letter.isEmpty) return;

    if (isPencilMode) {
      selectedCell.guess = letter;
      selectedCell.isPencil = true;
      selectedCell.isError = false;
    } else {
      selectedCell.guess = letter;
      selectedCell.isPencil = false;
      selectedCell.isError = false;
    }

    // Auto-advance to next cell in current word
    _advanceAlongCurrentWord();

    // Check completion
    _checkPuzzleCompletion();
  }

  void backspace() {
    if (isCompleted) return;
    if (selectedCell.isBlocked) return;

    if (selectedCell.guess.isNotEmpty) {
      selectedCell.clear();
    } else {
      _retreatAlongCurrentWord();
      selectedCell.clear();
    }
  }

  void _advanceAlongCurrentWord() {
    final word = activeWord;
    if (word == null) return;

    if (activeDirection == ClueDirection.across) {
      final nextCol = selectedCol + 1;
      if (nextCol < word.col + word.length && nextCol < puzzle.width) {
        if (!puzzle.grid[selectedRow][nextCol].isBlocked) {
          selectedCol = nextCol;
        }
      }
    } else {
      final nextRow = selectedRow + 1;
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
      final prevCol = selectedCol - 1;
      if (prevCol >= word.col) {
        selectedCol = prevCol;
      }
    } else {
      final prevRow = selectedRow - 1;
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

  void revealActiveLetter() {
    if (selectedCell.isBlocked) return;
    selectedCell.guess = selectedCell.solution;
    selectedCell.isPencil = false;
    selectedCell.isError = false;
    hintsUsed++;
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
    hintsUsed += 2;
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
