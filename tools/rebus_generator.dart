// tools/rebus_generator.dart
import 'dart:convert';
import 'dart:io';

void main() {
  final titlesFile = File('content/titles.json');
  if (!titlesFile.existsSync()) {
    stderr.writeln('content/titles.json missing.');
    exit(1);
  }

  final titlesData = jsonDecode(titlesFile.readAsStringSync()) as List;
  final titleMap = {for (var t in titlesData) t['id'] as String: t};

  // 10 Rebus Prototype Levels (5 Anime, 5 Movies)
  final rebusPrototypes = [
    {
      'id': 'rebus_01',
      'titleId': 'anime-demon-slayer-2019',
      'name': 'Demon Slayer',
      'difficulty': 'easy',
      'emojis': '⚔️ 🎋 🐗 ⚡ 👹',
      'explanation': 'Tanjiro uses a water/sun sword (⚔️), Nezuko wears a bamboo muzzle (🎋), with Inosuke the boar (🐗) and Zenitsu thunder (⚡) fighting demons (👹).'
    },
    {
      'id': 'rebus_02',
      'titleId': 'anime-spy-x-family-2022',
      'name': 'Spy x Family',
      'difficulty': 'easy',
      'emojis': '🕵️ 🥜 🗡️ 🐶 🏫',
      'explanation': 'Twilight the master spy (🕵️), telepathic Anya who loves peanuts (🥜), Yor the assassin (🗡️), and big dog Bond (🐶) aiming for Eden Academy (🏫).'
    },
    {
      'id': 'rebus_03',
      'titleId': 'anime-your-name-2016',
      'name': 'Your Name',
      'difficulty': 'easy',
      'emojis': '☄️ 🎀 📱 🌅 ✍️',
      'explanation': 'A split comet (☄️), a red braided cord (🎀), mobile phone diaries (📱), meeting at sunset (🌅), and writing names on hands (✍️).'
    },
    {
      'id': 'rebus_04',
      'titleId': 'anime-chainsaw-man-2022',
      'name': 'Chainsaw Man',
      'difficulty': 'medium',
      'emojis': '🪚 🐶 🩸 🦊 🚬',
      'explanation': 'Denji with chainsaws (🪚), demon dog Pochita (🐶), blood-drinking fiends (🩸), Aki Kon fox hand sign (🦊), and cigarette packs (🚬).'
    },
    {
      'id': 'rebus_05',
      'titleId': 'anime-frieren-2023',
      'name': 'Frieren',
      'difficulty': 'medium',
      'emojis': '🧝‍♀️ ⏳ ✨ 🗡️ 🪦',
      'explanation': 'An elven mage (🧝‍♀️) experiencing centuries of time (⏳), collecting magical grimoires (✨), honoring hero Himmel\'s grave (🪦).'
    },
    {
      'id': 'rebus_06',
      'titleId': 'movie-inception-2010',
      'name': 'Inception',
      'difficulty': 'easy',
      'emojis': '🌀 💤 🏙️ ⏳ 🔫',
      'explanation': 'A spinning totem top (🌀), dreaming inside dreams (💤), folding Paris cityscapes (🏙️), and time dilation down in limbo (⏳).'
    },
    {
      'id': 'rebus_07',
      'titleId': 'movie-the-dark-knight-2008',
      'name': 'The Dark Knight',
      'difficulty': 'easy',
      'emojis': '🦇 🃏 🪙 🌃 💥',
      'explanation': 'Batman (🦇), the chaos-loving Joker (🃏), Harvey Dent\'s two-headed coin (🪙), and Gotham City at night (🌃).'
    },
    {
      'id': 'rebus_08',
      'titleId': 'movie-black-panther-2018',
      'name': 'Black Panther',
      'difficulty': 'easy',
      'emojis': '🐆 👑 🙅‍♂️ 💎 🌍',
      'explanation': 'The Black Panther (🐆), King of Wakanda (👑), the iconic Wakanda Forever chest salute (🙅‍♂️), and vibranium riches (💎).'
    },
    {
      'id': 'rebus_09',
      'titleId': 'movie-a-tribe-called-judah-2023',
      'name': 'A Tribe Called Judah',
      'difficulty': 'medium',
      'emojis': '💰 👨‍👦‍👦 🏪 🏥 🇳🇬',
      'explanation': 'Five brothers (👨‍👦‍👦) plan a mall furniture robbery (🏪) to pay their mother\'s medical bills (🏥) in Nigeria (🇳🇬), breaking 1B Naira records (💰).'
    },
    {
      'id': 'rebus_10',
      'titleId': 'movie-barbie-2023',
      'name': 'Barbie',
      'difficulty': 'medium',
      'emojis': '💖 👠 👱‍♂️ 🎀 🚗',
      'explanation': 'All-pink everything (💖), arched high-heel feet (👠), Ken (👱‍♂️), and a pink convertible road trip (🚗) out of Barbie Land.'
    },
  ];

  for (final proto in rebusPrototypes) {
    final titleId = proto['titleId'] as String;
    final titleObj = titleMap[titleId];
    if (titleObj == null) {
      stderr.writeln('Title $titleId not found!');
      exit(1);
    }

    final category = titleObj['type'] as String;
    final year = titleObj['year'];
    final cleanAnswer = (proto['name'] as String).toUpperCase();

    final puzzleJson = {
      'id': proto['id'],
      'titleId': titleId,
      'name': proto['name'],
      'category': category,
      'difficulty': proto['difficulty'],
      'emojis': proto['emojis'],
      'answer': cleanAnswer,
      'explanation': proto['explanation'],
      'hintLadder': {
        'hint1': '$category title released in $year',
        'hint2': 'First letter: ${cleanAnswer[0]}',
        'hint3': 'Length: ${cleanAnswer.replaceAll(' ', '').length} letters',
        'hint4': proto['explanation'],
      }
    };

    final outFile = File('assets/puzzles/rebus/${proto['id']}.json');
    outFile.writeAsStringSync(jsonEncode(puzzleJson));
    stdout.writeln('Generated ${proto['id']}: "${proto['name']}" (${proto['emojis']})');
  }

  stdout.writeln('\nSuccessfully generated 10 prototype rebus puzzles in assets/puzzles/rebus/');
}
