import 'dart:convert';
import 'dart:io';

void main() {
  final file = File('content/titles.json');
  if (!file.existsSync()) {
    stderr.writeln('Error: content/titles.json does not exist.');
    exit(1);
  }

  final raw = file.readAsStringSync();
  final dynamic jsonList;
  try {
    jsonList = jsonDecode(raw);
  } catch (e) {
    stderr.writeln('Error: Failed to parse content/titles.json as JSON: $e');
    exit(1);
  }

  if (jsonList is! List) {
    stderr.writeln('Error: Root of content/titles.json must be a JSON array.');
    exit(1);
  }

  final ids = <String>{};
  int animeCount = 0;
  int movieCount = 0;
  final errors = <String>[];

  for (int i = 0; i < jsonList.length; i++) {
    final item = jsonList[i];
    if (item is! Map<String, dynamic>) {
      errors.add('Entry at index $i is not a JSON object.');
      continue;
    }

    final id = item['id'];
    if (id is! String || id.trim().isEmpty) {
      errors.add('Entry $i: missing or invalid "id"');
    } else if (ids.contains(id)) {
      errors.add('Duplicate id found: "$id"');
    } else {
      ids.add(id);
    }

    final type = item['type'];
    if (type != 'anime' && type != 'movie') {
      errors.add('Entry $id: type must be "anime" or "movie", got "$type"');
    } else {
      if (type == 'anime') animeCount++;
      if (type == 'movie') movieCount++;
    }

    final title = item['title'];
    if (title is! String || title.trim().isEmpty) {
      errors.add('Entry $id: missing or invalid "title"');
    }

    final year = item['year'];
    if (year is! int) {
      errors.add('Entry $id: "year" must be an integer');
    } else {
      if (type == 'anime' && (year < 2016 || year > 2026)) {
        errors.add('Entry $id (anime): year $year out of range 2016-2026');
      }
      if (type == 'movie' && (year < 2006 || year > 2026)) {
        errors.add('Entry $id (movie): year $year out of range 2006-2026');
      }
    }

    final studioOrDirector = item['studioOrDirector'];
    if (studioOrDirector is! String || studioOrDirector.trim().isEmpty) {
      errors.add('Entry $id: missing or invalid "studioOrDirector"');
    }

    final genres = item['genres'];
    if (genres is! List || genres.isEmpty) {
      errors.add('Entry $id: "genres" must be a non-empty list');
    }

    final popSignals = item['popularitySignals'];
    if (popSignals is! List || popSignals.isEmpty) {
      errors.add('Entry $id: "popularitySignals" must be a non-empty list');
    }

    final characters = item['characters'];
    if (characters is! List || characters.length < 2) {
      errors.add('Entry $id: "characters" must contain at least 2 characters');
    }

    final keyTerms = item['keyTerms'];
    if (keyTerms is! List || keyTerms.isEmpty) {
      errors.add('Entry $id: "keyTerms" must be a non-empty list');
    }

    final facts = item['facts'];
    if (facts is! List || facts.isEmpty) {
      errors.add('Entry $id: "facts" must be a non-empty list');
    } else {
      for (int f = 0; f < facts.length; f++) {
        final fact = facts[f];
        if (fact is! Map<String, dynamic>) {
          errors.add('Entry $id, fact $f is not an object');
          continue;
        }
        final text = fact['text'];
        if (text is! String || text.trim().isEmpty) {
          errors.add('Entry $id, fact $f missing "text"');
        }
        final sources = fact['sources'];
        if (sources is! List || sources.length < 2) {
          errors.add('Entry $id, fact $f has fewer than 2 independent sources (found ${sources is List ? sources.length : 0})');
        }
      }
    }

    final emojiCandidates = item['emojiCandidates'];
    if (emojiCandidates is! List || emojiCandidates.isEmpty) {
      errors.add('Entry $id: "emojiCandidates" must be a non-empty list');
    }

    final status = item['status'];
    if (status != 'VERIFIED') {
      errors.add('Entry $id: status must be "VERIFIED" (unverified titles cannot be shipped)');
    }
  }

  if (errors.isNotEmpty) {
    stderr.writeln('=== Title Verification FAILED with ${errors.length} errors ===');
    for (final err in errors.take(30)) {
      stderr.writeln(' - $err');
    }
    if (errors.length > 30) {
      stderr.writeln(' ... and ${errors.length - 30} more errors.');
    }
    exit(1);
  }

  stdout.writeln('=== Title Verification PASSED ===');
  stdout.writeln('Total Titles: ${jsonList.length}');
  stdout.writeln('  Anime (2016-2026): $animeCount');
  stdout.writeln('  Movies (2006-2026): $movieCount');
  stdout.writeln('All entries validated with >= 2 independent sources per fact and valid schema.');
}
