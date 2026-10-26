// tools/scale_rebus.dart
import 'dart:convert';
import 'dart:io';

void main() {
  final titlesFile = File('content/titles.json');
  final cluesFile = File('content/clues.json');
  if (!titlesFile.existsSync() || !cluesFile.existsSync()) {
    stderr.writeln('Dataset files missing.');
    exit(1);
  }

  final titlesData = jsonDecode(titlesFile.readAsStringSync()) as List;
  final cluesData = jsonDecode(cluesFile.readAsStringSync()) as List;
  final titleMap = {for (var t in titlesData) t['id'] as String: t};

  final outDir = Directory('assets/puzzles/rebus');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  final tiers = ['easy', 'medium', 'hard', 'expert'];
  int totalRebuses = 0;

  // Generate 50 per tier (25 anime + 25 movie per tier = 200 total)
  for (final tier in tiers) {
    for (final cat in ['anime', 'movie']) {
      final relevantTitles = titlesData.where((t) => t['type'] == cat).toList();
      const count = 25;

      for (int i = 0; i < count; i++) {
        totalRebuses++;
        final levelId = 'rebus_${totalRebuses.toString().padLeft(3, '0')}';
        final titleObj = relevantTitles[i % relevantTitles.length];

        final tId = titleObj['id'] as String;
        final tTitle = titleObj['title'] as String;
        final tYear = titleObj['year'];
        final tEmojis = (titleObj['emojiCandidates'] as List).cast<String>();
        final facts = (titleObj['facts'] as List);
        final factText = facts.isNotEmpty ? facts[0]['text'] as String : '';

        // Select subset of emojis based on tier
        final emojiSeq = tEmojis.take(tier == 'easy' ? 4 : (tier == 'medium' ? 3 : 2)).join(' ');
        final cleanAnswer = tTitle.toUpperCase();

        final puzzleJson = {
          'id': levelId,
          'titleId': tId,
          'name': tTitle,
          'category': cat,
          'difficulty': tier,
          'emojis': emojiSeq,
          'answer': cleanAnswer,
          'explanation': factText.isNotEmpty ? factText : 'Iconic $cat title from $tYear.',
          'hintLadder': {
            'hint1': '$cat title released in $tYear',
            'hint2': 'First letter: ${cleanAnswer[0]}',
            'hint3': 'Length: ${cleanAnswer.replaceAll(RegExp(r'[^A-Z0-9]'), '').length} letters',
            'hint4': factText,
          }
        };

        final file = File('${outDir.path}/$levelId.json');
        file.writeAsStringSync(jsonEncode(puzzleJson));
      }
    }
    stdout.writeln('Generated 50 Rebus levels for tier: $tier');
  }

  stdout.writeln('\n=== Successfully generated $totalRebuses Rebus levels in assets/puzzles/rebus/ ===');
}
