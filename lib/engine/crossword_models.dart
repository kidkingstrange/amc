// lib/engine/crossword_models.dart

enum ClueDirection { across, down }

class CrosswordCell {
  final int row;
  final int col;
  final String solution;
  final bool isBlocked;
  final int? number;

  String guess;
  bool isPencil;
  bool isError;

  CrosswordCell({
    required this.row,
    required this.col,
    required this.solution,
    this.isBlocked = false,
    this.number,
    this.guess = '',
    this.isPencil = false,
    this.isError = false,
  });

  bool get isCorrect => guess.isNotEmpty && guess == solution;
  bool get isEmpty => guess.isEmpty;

  void clear() {
    guess = '';
    isPencil = false;
    isError = false;
  }
}

class CrosswordWord {
  final int number;
  final ClueDirection direction;
  final String clue;
  final String answer;
  final int row;
  final int col;
  final int length;

  CrosswordWord({
    required this.number,
    required this.direction,
    required this.clue,
    required this.answer,
    required this.row,
    required this.col,
    required this.length,
  });

  factory CrosswordWord.fromJson(Map<String, dynamic> json) {
    return CrosswordWord(
      number: json['number'] as int,
      direction: (json['direction'] as String).toLowerCase() == 'across'
          ? ClueDirection.across
          : ClueDirection.down,
      clue: json['clue'] as String,
      answer: (json['answer'] as String).toUpperCase(),
      row: json['row'] as int,
      col: json['col'] as int,
      length: json['length'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'direction': direction == ClueDirection.across ? 'across' : 'down',
        'clue': clue,
        'answer': answer,
        'row': row,
        'col': col,
        'length': length,
      };
}

class CrosswordPuzzle {
  final String id;
  final String name;
  final String category;
  final String difficulty;
  final int width;
  final int height;
  final List<List<CrosswordCell>> grid;
  final List<CrosswordWord> words;

  CrosswordPuzzle({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.width,
    required this.height,
    required this.grid,
    required this.words,
  });

  factory CrosswordPuzzle.fromJson(Map<String, dynamic> json) {
    final width = json['width'] as int;
    final height = json['height'] as int;
    final rawGrid = (json['grid'] as List)
        .map((row) => (row as List).map((c) => c as String).toList())
        .toList();

    final words = (json['words'] as List)
        .map((w) => CrosswordWord.fromJson(w as Map<String, dynamic>))
        .toList();

    // Determine numbers per cell
    final cellNumbers = <String, int>{};
    for (final w in words) {
      cellNumbers['${w.row},${w.col}'] = w.number;
    }

    final grid = List.generate(height, (r) {
      return List.generate(width, (c) {
        final char = rawGrid[r][c];
        final isBlocked = char == '#';
        final num = cellNumbers['$r,$c'];
        return CrosswordCell(
          row: r,
          col: c,
          solution: isBlocked ? '' : char.toUpperCase(),
          isBlocked: isBlocked,
          number: num,
        );
      });
    });

    return CrosswordPuzzle(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      width: width,
      height: height,
      grid: grid,
      words: words,
    );
  }
}
