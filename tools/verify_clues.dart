import 'dart:convert';
import 'dart:io';

void main() {
  final cluesFile = File('content/clues.json');
  final titlesFile = File('content/titles.json');

  if (!cluesFile.existsSync()) {
    stderr.writeln('Error: content/clues.json does not exist.');
    exit(1);
  }
  if (!titlesFile.existsSync()) {
    stderr.writeln('Error: content/titles.json does not exist.');
    exit(1);
  }

  final List<dynamic> cluesList;
  final List<dynamic> titlesList;
  try {
    cluesList = jsonDecode(cluesFile.readAsStringSync()) as List<dynamic>;
    titlesList = jsonDecode(titlesFile.readAsStringSync()) as List<dynamic>;
  } catch (e) {
    stderr.writeln('Error parsing JSON files: $e');
    exit(1);
  }

  final validTitleIds = titlesList.map((e) => e['id'] as String).toSet();
  final validTypes = {
    'title',
    'character',
    'creator',
    'actor',
    'term',
    'fill_in_blank',
    'year_number',
  };
  final validDifficulties = {'easy', 'medium', 'hard', 'expert'};
  final answerRegex = RegExp(r'^[A-Z0-9]+$');

  final clueIds = <String>{};
  final errors = <String>[];
  final typeCounts = <String, int>{};
  final diffCounts = <String, int>{};

  for (int i = 0; i < cluesList.length; i++) {
    final item = cluesList[i];
    if (item is! Map<String, dynamic>) {
      errors.add('Clue index $i is not a JSON object.');
      continue;
    }

    final id = item['id'];
    if (id is! String || id.trim().isEmpty) {
      errors.add('Clue $i: missing or invalid "id"');
    } else if (clueIds.contains(id)) {
      errors.add('Duplicate clue id: "$id"');
    } else {
      clueIds.add(id);
    }

    final titleId = item['titleId'];
    if (titleId is! String || !validTitleIds.contains(titleId)) {
      errors.add('Clue $id: titleId "$titleId" not found in content/titles.json');
    }

    final type = item['type'];
    if (type is! String || !validTypes.contains(type)) {
      errors.add('Clue $id: invalid type "$type" (allowed: $validTypes)');
    } else {
      typeCounts[type] = (typeCounts[type] ?? 0) + 1;
    }

    final clue = item['clue'];
    if (clue is! String || clue.trim().isEmpty) {
      errors.add('Clue $id: missing or empty clue text');
    } else if (clue.length > 80) {
      errors.add('Clue $id: clue text exceeds 80 characters (${clue.length} chars): "$clue"');
    }

    final answer = item['answer'];
    if (answer is! String || answer.trim().isEmpty) {
      errors.add('Clue $id: missing or empty answer');
    } else {
      if (!answerRegex.hasMatch(answer)) {
        errors.add('Clue $id: answer "$answer" contains invalid characters (A-Z and 0-9 only)');
      }
      if (answer.length < 3 || answer.length > 15) {
        errors.add('Clue $id: answer length (${answer.length}) out of crossword range (3-15 chars): "$answer"');
      }
    }

    final diff = item['difficulty'];
    if (diff is! String || !validDifficulties.contains(diff)) {
      errors.add('Clue $id: invalid difficulty "$diff"');
    } else {
      diffCounts[diff] = (diffCounts[diff] ?? 0) + 1;
    }
  }

  if (cluesList.length < 1500) {
    errors.add('Target requirement failed: Minimum 1,500 clues required, found ${cluesList.length}');
  }

  if (errors.isNotEmpty) {
    stderr.writeln('=== Clue Verification FAILED with ${errors.length} errors ===');
    for (final err in errors.take(30)) {
      stderr.writeln(' - $err');
    }
    if (errors.length > 30) {
      stderr.writeln(' ... and ${errors.length - 30} more errors.');
    }
    exit(1);
  }

  stdout.writeln('=== Clue Verification PASSED ===');
  stdout.writeln('Total Verified Clues: ${cluesList.length}');
  stdout.writeln('Difficulty Distribution:');
  for (final entry in diffCounts.entries) {
    stdout.writeln('  - ${entry.key}: ${entry.value}');
  }
  stdout.writeln('Type Distribution:');
  for (final entry in typeCounts.entries) {
    stdout.writeln('  - ${entry.key}: ${entry.value}');
  }
  stdout.writeln('All clues under 80 characters with clean A-Z/0-9 answers.');
}
