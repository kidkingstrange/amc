// tools/scale_crosswords.dart
import 'dart:convert';
import 'dart:io';

class WordClue {
  final String id;
  final String titleId;
  final String clue;
  final String answer;
  final String difficulty;

  WordClue({
    required this.id,
    required this.titleId,
    required this.clue,
    required this.answer,
    required this.difficulty,
  });
}

class PlacedWord {
  int number;
  final String clue;
  final String answer;
  final String direction; // 'across' or 'down'
  final int row;
  final int col;

  PlacedWord({
    this.number = 0,
    required this.clue,
    required this.answer,
    required this.direction,
    required this.row,
    required this.col,
  });

  Map<String, dynamic> toJson() => {
        'number': number,
        'direction': direction,
        'clue': clue,
        'answer': answer,
        'row': row,
        'col': col,
        'length': answer.length,
      };
}

class CrosswordGrid {
  final int width;
  final int height;
  late List<List<String>> cells;
  final List<PlacedWord> placedWords = [];

  CrosswordGrid(this.width, this.height) {
    cells = List.generate(height, (_) => List.generate(width, (_) => '#'));
  }

  bool canPlaceAcross(String word, int r, int c) {
    if (r < 0 || r >= height || c < 0 || c + word.length > width) return false;
    if (c > 0 && cells[r][c - 1] != '#') return false;
    if (c + word.length < width && cells[r][c + word.length] != '#') return false;

    bool hasIntersection = placedWords.isEmpty;
    for (int i = 0; i < word.length; i++) {
      final current = cells[r][c + i];
      if (current != '#' && current != word[i]) return false;
      if (current == word[i]) {
        hasIntersection = true;
      } else {
        if (r > 0 && cells[r - 1][c + i] != '#') return false;
        if (r + 1 < height && cells[r + 1][c + i] != '#') return false;
      }
    }
    return hasIntersection;
  }

  bool canPlaceDown(String word, int r, int c) {
    if (r < 0 || r + word.length > height || c < 0 || c >= width) return false;
    if (r > 0 && cells[r - 1][c] != '#') return false;
    if (r + word.length < height && cells[r + word.length][c] != '#') return false;

    bool hasIntersection = placedWords.isEmpty;
    for (int i = 0; i < word.length; i++) {
      final current = cells[r + i][c];
      if (current != '#' && current != word[i]) return false;
      if (current == word[i]) {
        hasIntersection = true;
      } else {
        if (c > 0 && cells[r + i][c - 1] != '#') return false;
        if (c + 1 < width && cells[r + i][c + 1] != '#') return false;
      }
    }
    return hasIntersection;
  }

  void placeAcross(WordClue clue, int r, int c) {
    for (int i = 0; i < clue.answer.length; i++) {
      cells[r][c + i] = clue.answer[i];
    }
    placedWords.add(PlacedWord(
      clue: clue.clue,
      answer: clue.answer,
      direction: 'across',
      row: r,
      col: c,
    ));
  }

  void placeDown(WordClue clue, int r, int c) {
    for (int i = 0; i < clue.answer.length; i++) {
      cells[r + i][c] = clue.answer[i];
    }
    placedWords.add(PlacedWord(
      clue: clue.clue,
      answer: clue.answer,
      direction: 'down',
      row: r,
      col: c,
    ));
  }

  void assignStandardNumbering() {
    int currentNum = 1;
    for (int r = 0; r < height; r++) {
      for (int c = 0; c < width; c++) {
        if (cells[r][c] == '#') continue;

        bool startsAcross = false;
        bool startsDown = false;

        for (final pw in placedWords) {
          if (pw.row == r && pw.col == c) {
            if (pw.direction == 'across') startsAcross = true;
            if (pw.direction == 'down') startsDown = true;
          }
        }

        if (startsAcross || startsDown) {
          for (final pw in placedWords) {
            if (pw.row == r && pw.col == c) {
              pw.number = currentNum;
            }
          }
          currentNum++;
        }
      }
    }
  }
}

void main() {
  final cluesFile = File('content/clues.json');
  final titlesFile = File('content/titles.json');
  if (!cluesFile.existsSync() || !titlesFile.existsSync()) {
    stderr.writeln('Dataset files missing.');
    exit(1);
  }

  final cluesData = jsonDecode(cluesFile.readAsStringSync()) as List;
  final titlesData = jsonDecode(titlesFile.readAsStringSync()) as List;
  final titleMap = {for (var t in titlesData) t['id'] as String: t};

  final allClues = cluesData.map((c) => WordClue(
        id: c['id'] as String,
        titleId: c['titleId'] as String,
        clue: c['clue'] as String,
        answer: c['answer'] as String,
        difficulty: c['difficulty'] as String,
      )).toList();

  final packs = [
    {'name': 'Shonen Showdown', 'cat': 'anime', 'diff': 'easy', 'gridSize': 9, 'count': 25},
    {'name': 'Oscar Night', 'cat': 'movie', 'diff': 'easy', 'gridSize': 9, 'count': 25},
    {'name': 'Isekai & Fantasy', 'cat': 'anime', 'diff': 'medium', 'gridSize': 11, 'count': 25},
    {'name': 'Blockbuster Era', 'cat': 'movie', 'diff': 'medium', 'gridSize': 11, 'count': 25},
    {'name': 'Anime Deep Lore', 'cat': 'anime', 'diff': 'hard', 'gridSize': 13, 'count': 25},
    {'name': 'Cinema Masters', 'cat': 'movie', 'diff': 'hard', 'gridSize': 13, 'count': 25},
    {'name': 'Expert Anime Vault', 'cat': 'anime', 'diff': 'expert', 'gridSize': 15, 'count': 25},
    {'name': 'Expert Film Vault', 'cat': 'movie', 'diff': 'expert', 'gridSize': 15, 'count': 25},
  ];

  int totalCrosswords = 0;
  final outDir = Directory('assets/puzzles/crosswords');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  for (final pack in packs) {
    final packName = pack['name'] as String;
    final cat = pack['cat'] as String;
    final diff = pack['diff'] as String;
    final size = pack['gridSize'] as int;
    final count = pack['count'] as int;

    // Filter candidate clues for this pack
    final candidates = allClues.where((c) {
      final t = titleMap[c.titleId];
      if (t == null) return false;
      final matchCat = t['type'] == cat;
      final matchDiff = c.difficulty == diff || c.difficulty == 'easy' || c.difficulty == 'medium';
      return matchCat && matchDiff && c.answer.length >= 3 && c.answer.length <= size - 2;
    }).toList();

    for (int i = 1; i <= count; i++) {
      totalCrosswords++;
      final levelId = 'cw_${totalCrosswords.toString().padLeft(3, '0')}';
      final levelName = '$packName #$i';

      // Seed rotation for variety
      final seedOffset = (i * 7) % candidates.length;
      final pool = candidates.sublist(seedOffset) + candidates.sublist(0, seedOffset);

      CrosswordGrid grid = CrosswordGrid(size, size);
      final usedAnswers = <String>{};

      for (int attempt = 0; attempt < 10 && grid.placedWords.length < 5; attempt++) {
        grid = CrosswordGrid(size, size);
        usedAnswers.clear();

        // 1. Center word
        final centerCandidate = pool[(attempt) % pool.length];
        final startR = size ~/ 2;
        final startC = (size - centerCandidate.answer.length) ~/ 2;
        if (grid.canPlaceAcross(centerCandidate.answer, startR, startC)) {
          grid.placeAcross(centerCandidate, startR, startC);
          usedAnswers.add(centerCandidate.answer);
        }

        // 2. Intersecting words
        for (final c in pool) {
          if (usedAnswers.contains(c.answer) || grid.placedWords.length >= (size >= 13 ? 8 : 6)) {
            continue;
          }

          bool placed = false;
          for (int r = 0; r < size && !placed; r++) {
            for (int col = 0; col < size && !placed; col++) {
              if (grid.canPlaceDown(c.answer, r, col)) {
                grid.placeDown(c, r, col);
                usedAnswers.add(c.answer);
                placed = true;
              } else if (grid.canPlaceAcross(c.answer, r, col)) {
                grid.placeAcross(c, r, col);
                usedAnswers.add(c.answer);
                placed = true;
              }
            }
          }
        }
      }

      grid.assignStandardNumbering();

      final puzzleJson = {
        'id': levelId,
        'name': levelName,
        'category': cat,
        'pack': packName,
        'difficulty': diff,
        'width': size,
        'height': size,
        'grid': grid.cells,
        'words': grid.placedWords.map((w) => w.toJson()).toList(),
      };

      final file = File('${outDir.path}/$levelId.json');
      file.writeAsStringSync(jsonEncode(puzzleJson));
    }
    stdout.writeln('Generated $count levels for pack: "$packName" ($diff tier, ${size}x$size)');
  }

  stdout.writeln('\n=== Successfully generated $totalCrosswords Crossword levels in assets/puzzles/crosswords/ ===');
}
