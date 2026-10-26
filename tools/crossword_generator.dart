// tools/crossword_generator.dart
import 'dart:convert';
import 'dart:io';

class WordEntry {
  final String id;
  final String titleId;
  final String clue;
  final String answer;
  final String difficulty;

  WordEntry({
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

class GridBuilder {
  final int width;
  final int height;
  late List<List<String>> cells;
  final List<PlacedWord> placedWords = [];

  GridBuilder(this.width, this.height) {
    cells = List.generate(height, (_) => List.generate(width, (_) => '#'));
  }

  bool canPlaceAcross(String word, int r, int c) {
    if (r < 0 || r >= height || c < 0 || c + word.length > width) return false;
    // Check cell before and after
    if (c > 0 && cells[r][c - 1] != '#') return false;
    if (c + word.length < width && cells[r][c + word.length] != '#') return false;

    bool hasIntersection = placedWords.isEmpty;
    for (int i = 0; i < word.length; i++) {
      final current = cells[r][c + i];
      if (current != '#' && current != word[i]) return false;
      if (current == word[i]) {
        hasIntersection = true;
      } else {
        // If placing into an empty cell, ensure no adjacent parallel neighbors
        if (r > 0 && cells[r - 1][c + i] != '#') return false;
        if (r + 1 < height && cells[r + 1][c + i] != '#') return false;
      }
    }
    return hasIntersection;
  }

  bool canPlaceDown(String word, int r, int c) {
    if (r < 0 || r + word.length > height || c < 0 || c >= width) return false;
    // Check cell above and below
    if (r > 0 && cells[r - 1][c] != '#') return false;
    if (r + word.length < height && cells[r + word.length][c] != '#') return false;

    bool hasIntersection = placedWords.isEmpty;
    for (int i = 0; i < word.length; i++) {
      final current = cells[r + i][c];
      if (current != '#' && current != word[i]) return false;
      if (current == word[i]) {
        hasIntersection = true;
      } else {
        // If placing into an empty cell, ensure no adjacent parallel neighbors
        if (c > 0 && cells[r + i][c - 1] != '#') return false;
        if (c + 1 < width && cells[r + i][c + 1] != '#') return false;
      }
    }
    return hasIntersection;
  }

  void placeAcross(WordEntry entry, int r, int c) {
    for (int i = 0; i < entry.answer.length; i++) {
      cells[r][c + i] = entry.answer[i];
    }
    placedWords.add(PlacedWord(
      clue: entry.clue,
      answer: entry.answer,
      direction: 'across',
      row: r,
      col: c,
    ));
  }

  void placeDown(WordEntry entry, int r, int c) {
    for (int i = 0; i < entry.answer.length; i++) {
      cells[r + i][c] = entry.answer[i];
    }
    placedWords.add(PlacedWord(
      clue: entry.clue,
      answer: entry.answer,
      direction: 'down',
      row: r,
      col: c,
    ));
  }

  void assignStandardNumbering() {
    int currentNum = 1;
    // Scan row by row, col by col
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
    stderr.writeln('Missing dataset files.');
    exit(1);
  }

  final cluesData = jsonDecode(cluesFile.readAsStringSync()) as List;
  final titlesData = jsonDecode(titlesFile.readAsStringSync()) as List;
  final titleMap = {for (var t in titlesData) t['id'] as String: t};

  final entries = cluesData.map((c) => WordEntry(
        id: c['id'] as String,
        titleId: c['titleId'] as String,
        clue: c['clue'] as String,
        answer: c['answer'] as String,
        difficulty: c['difficulty'] as String,
      )).toList();

  // Create 10 Prototype Crosswords (Levels 1 to 10)
  // 5 Anime (3 Easy, 2 Medium), 5 Movies (3 Easy, 2 Medium)
  final prototypes = [
    {'id': 'cw_01', 'name': 'Demon & Sorcery', 'type': 'anime', 'diff': 'easy', 'size': 9, 'seed': ['anime-demon-slayer-2019', 'anime-jujutsu-kaisen-2020']},
    {'id': 'cw_02', 'name': 'Survey Corps & Spies', 'type': 'anime', 'diff': 'easy', 'size': 9, 'seed': ['anime-attack-on-titan-final-2020', 'anime-spy-x-family-2022']},
    {'id': 'cw_03', 'name': 'Anime Hits & Romance', 'type': 'anime', 'diff': 'easy', 'size': 9, 'seed': ['anime-your-name-2016', 'anime-frieren-2023']},
    {'id': 'cw_04', 'name': 'Cyber & Chainsaw', 'type': 'anime', 'diff': 'medium', 'size': 11, 'seed': ['anime-chainsaw-man-2022', 'anime-cyberpunk-edgerunners-2022']},
    {'id': 'cw_05', 'name': 'Rock & Titans', 'type': 'anime', 'diff': 'medium', 'size': 11, 'seed': ['anime-bocchi-the-rock-2022', 'anime-mob-psycho-100-2016']},
    {'id': 'cw_06', 'name': 'Dreams & Knights', 'type': 'movie', 'diff': 'easy', 'size': 9, 'seed': ['movie-inception-2010', 'movie-the-dark-knight-2008']},
    {'id': 'cw_07', 'name': 'Wakanda & Pandora', 'type': 'movie', 'diff': 'easy', 'size': 9, 'seed': ['movie-black-panther-2018', 'movie-avatar-2009']},
    {'id': 'cw_08', 'name': 'Avengers & Multiverse', 'type': 'movie', 'diff': 'easy', 'size': 9, 'seed': ['movie-the-avengers-2012', 'movie-spider-man-into-the-spider-verse-2018']},
    {'id': 'cw_09', 'name': 'Nollywood Blockbusters', 'type': 'movie', 'diff': 'medium', 'size': 11, 'seed': ['movie-a-tribe-called-judah-2023', 'movie-the-wedding-party-2016', 'movie-king-of-boys-2018']},
    {'id': 'cw_10', 'name': 'Oppenheimer & Barbie', 'type': 'movie', 'diff': 'medium', 'size': 11, 'seed': ['movie-oppenheimer-2023', 'movie-barbie-2023']},
  ];

  int generated = 0;
  for (final proto in prototypes) {
    final size = proto['size'] as int;
    final pType = proto['type'] as String;
    final pDiff = proto['diff'] as String;
    final seeds = proto['seed'] as List<String>;

    // Filter relevant clues
    final pool = entries.where((e) {
      final t = titleMap[e.titleId];
      if (t == null) return false;
      final matchType = t['type'] == pType;
      final matchSeed = seeds.contains(e.titleId);
      final matchDiff = e.difficulty == pDiff || e.difficulty == 'easy';
      return matchType && (matchSeed || matchDiff) && e.answer.length >= 3 && e.answer.length <= size - 2;
    }).toList();

    // Sort pool by seed titles first
    pool.sort((a, b) {
      final aSeed = seeds.contains(a.titleId) ? 0 : 1;
      final bSeed = seeds.contains(b.titleId) ? 0 : 1;
      return aSeed.compareTo(bSeed);
    });

    final builder = GridBuilder(size, size);
    final usedAnswers = <String>{};

    // 1. Place initial word across the center
    for (final e in pool) {
      if (builder.canPlaceAcross(e.answer, size ~/ 2, (size - e.answer.length) ~/ 2)) {
        builder.placeAcross(e, size ~/ 2, (size - e.answer.length) ~/ 2);
        usedAnswers.add(e.answer);
        break;
      }
    }

    // 2. Try placing intersecting words (alternating down and across)
    for (final e in pool) {
      if (usedAnswers.contains(e.answer) || builder.placedWords.length >= 7) continue;

      bool placed = false;
      // Try down intersections
      for (int r = 0; r < size && !placed; r++) {
        for (int c = 0; c < size && !placed; c++) {
          if (builder.canPlaceDown(e.answer, r, c)) {
            builder.placeDown(e, r, c);
            usedAnswers.add(e.answer);
            placed = true;
          }
        }
      }
      // Try across intersections
      for (int r = 0; r < size && !placed; r++) {
        for (int c = 0; c < size && !placed; c++) {
          if (builder.canPlaceAcross(e.answer, r, c)) {
            builder.placeAcross(e, r, c);
            usedAnswers.add(e.answer);
            placed = true;
          }
        }
      }
    }

    builder.assignStandardNumbering();

    final puzzleJson = {
      'id': proto['id'],
      'name': proto['name'],
      'category': pType,
      'difficulty': pDiff,
      'width': size,
      'height': size,
      'grid': builder.cells,
      'words': builder.placedWords.map((w) => w.toJson()).toList(),
    };

    final outFile = File('assets/puzzles/crosswords/${proto['id']}.json');
    outFile.writeAsStringSync(jsonEncode(puzzleJson));
    generated++;
    stdout.writeln('Generated ${proto['id']}: "${proto['name']}" (${builder.placedWords.length} words placed on ${size}x${size} grid)');
  }

  stdout.writeln('\nSuccessfully generated $generated prototype crosswords in assets/puzzles/crosswords/');
}
