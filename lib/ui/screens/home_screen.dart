// lib/ui/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../../services/game_storage.dart';
import '../theme.dart';
import 'crossword_screen.dart';
import 'dex_screen.dart';
import 'rebus_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;

  const HomeScreen({super.key, required this.onThemeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = GameStorage();

  static const List<Map<String, String>> crosswords = [
    {'id': 'cw_01', 'name': 'Level 1: Demon & Sorcery', 'cat': 'Anime', 'diff': 'Easy', 'titleId': 'anime-demon-slayer-2019'},
    {'id': 'cw_02', 'name': 'Level 2: Survey Corps & Spies', 'cat': 'Anime', 'diff': 'Easy', 'titleId': 'anime-attack-on-titan-final-2020'},
    {'id': 'cw_03', 'name': 'Level 3: Anime Hits & Romance', 'cat': 'Anime', 'diff': 'Easy', 'titleId': 'anime-your-name-2016'},
    {'id': 'cw_04', 'name': 'Level 4: Cyber & Chainsaw', 'cat': 'Anime', 'diff': 'Medium', 'titleId': 'anime-chainsaw-man-2022'},
    {'id': 'cw_05', 'name': 'Level 5: Rock & Titans', 'cat': 'Anime', 'diff': 'Medium', 'titleId': 'anime-bocchi-the-rock-2022'},
    {'id': 'cw_06', 'name': 'Level 6: Dreams & Knights', 'cat': 'Movies', 'diff': 'Easy', 'titleId': 'movie-inception-2010'},
    {'id': 'cw_07', 'name': 'Level 7: Wakanda & Pandora', 'cat': 'Movies', 'diff': 'Easy', 'titleId': 'movie-black-panther-2018'},
    {'id': 'cw_08', 'name': 'Level 8: Avengers & Multiverse', 'cat': 'Movies', 'diff': 'Easy', 'titleId': 'movie-the-avengers-2012'},
    {'id': 'cw_09', 'name': 'Level 9: Nollywood Blockbusters', 'cat': 'Movies', 'diff': 'Medium', 'titleId': 'movie-a-tribe-called-judah-2023'},
    {'id': 'cw_10', 'name': 'Level 10: Oppenheimer & Barbie', 'cat': 'Movies', 'diff': 'Medium', 'titleId': 'movie-oppenheimer-2023'},
  ];

  static const List<Map<String, String>> rebuses = [
    {'id': 'rebus_01', 'name': 'Rebus 1: Demon Slayer', 'cat': 'Anime', 'diff': 'Easy', 'emojis': '⚔️ 🎋 🐗', 'titleId': 'anime-demon-slayer-2019'},
    {'id': 'rebus_02', 'name': 'Rebus 2: Spy x Family', 'cat': 'Anime', 'diff': 'Easy', 'emojis': '🕵️ 🥜 🗡️', 'titleId': 'anime-spy-x-family-2022'},
    {'id': 'rebus_03', 'name': 'Rebus 3: Your Name', 'cat': 'Anime', 'diff': 'Easy', 'emojis': '☄️ 🎀 📱', 'titleId': 'anime-your-name-2016'},
    {'id': 'rebus_04', 'name': 'Rebus 4: Chainsaw Man', 'cat': 'Anime', 'diff': 'Medium', 'emojis': '🪚 🐶 🩸', 'titleId': 'anime-chainsaw-man-2022'},
    {'id': 'rebus_05', 'name': 'Rebus 5: Frieren', 'cat': 'Anime', 'diff': 'Medium', 'emojis': '🧝‍♀️ ⏳ ✨', 'titleId': 'anime-frieren-2023'},
    {'id': 'rebus_06', 'name': 'Rebus 6: Inception', 'cat': 'Movies', 'diff': 'Easy', 'emojis': '🌀 💤 🏙️', 'titleId': 'movie-inception-2010'},
    {'id': 'rebus_07', 'name': 'Rebus 7: The Dark Knight', 'cat': 'Movies', 'diff': 'Easy', 'emojis': '🦇 🃏 🪙', 'titleId': 'movie-the-dark-knight-2008'},
    {'id': 'rebus_08', 'name': 'Rebus 8: Black Panther', 'cat': 'Movies', 'diff': 'Easy', 'emojis': '🐆 👑 🙅‍♂️', 'titleId': 'movie-black-panther-2018'},
    {'id': 'rebus_09', 'name': 'Rebus 9: A Tribe Called Judah', 'cat': 'Movies', 'diff': 'Medium', 'emojis': '💰 👨‍👦‍👦 🏪', 'titleId': 'movie-a-tribe-called-judah-2023'},
    {'id': 'rebus_10', 'name': 'Rebus 10: Barbie', 'cat': 'Movies', 'diff': 'Medium', 'emojis': '💖 👠 👱‍♂️', 'titleId': 'movie-barbie-2023'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'CineCross: Anime & Movies',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          actions: [
            // Daily Streak flame badge
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.yellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.yellow, width: 1.5),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    '${storage.dailyStreak}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Dex Button
            IconButton(
              icon: const Icon(Icons.menu_book_outlined),
              tooltip: 'Trivia Collection (Dex)',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DexScreen()));
              },
            ),
            // Settings Button
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsScreen(onThemeChanged: widget.onThemeChanged)),
                ).then((_) => setState(() {}));
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.black54,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(icon: Icon(Icons.grid_on), text: 'Crosswords (10)'),
              Tab(icon: Icon(Icons.emoji_emotions_outlined), text: 'Emoji Rebus (10)'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Daily Challenge Highlight Banner
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                    child: const Text('⭐', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DAILY CHALLENGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
                        Text('Level 1: Demon & Sorcery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.yellow,
                      foregroundColor: AppColors.ink,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onPressed: () {
                      storage.recordDailyComplete('2026-10-26');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CrosswordScreen(levelId: 'cw_01', levelName: 'Daily Challenge: Demon & Sorcery'),
                        ),
                      ).then((_) => setState(() {}));
                    },
                    child: const Text('PLAY', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            // Tab View
            Expanded(
              child: TabBarView(
                children: [
                  _buildCrosswordList(context, isDark),
                  _buildRebusList(context, isDark),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrosswordList(BuildContext context, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: crosswords.length,
      itemBuilder: (ctx, i) {
        final item = crosswords[i];
        final isMovie = item['cat'] == 'Movies';
        final stars = storage.getStars(item['id']!);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: CircleAvatar(
              backgroundColor: isMovie ? AppColors.coral : AppColors.primary,
              foregroundColor: Colors.white,
              child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            title: Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Row(
              children: [
                Text('${item['cat']} • ${item['diff']}'),
                const SizedBox(width: 8),
                if (stars > 0)
                  Row(
                    children: List.generate(stars, (_) => const Icon(Icons.star, color: AppColors.yellow, size: 16)),
                  ),
              ],
            ),
            trailing: const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 28),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CrosswordScreen(levelId: item['id']!, levelName: item['name']!),
                ),
              ).then((_) {
                // When level finishes, update Dex unlock and stars
                storage.saveLevelResult(item['id']!, 3, titleId: item['titleId']);
                setState(() {});
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildRebusList(BuildContext context, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: rebuses.length,
      itemBuilder: (ctx, i) {
        final item = rebuses[i];
        final stars = storage.getStars(item['id']!);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Text(item['emojis']!, style: const TextStyle(fontSize: 22)),
            title: Text(item['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            subtitle: Row(
              children: [
                Text('${item['cat']} • ${item['diff']}'),
                const SizedBox(width: 8),
                if (stars > 0)
                  Row(
                    children: List.generate(stars, (_) => const Icon(Icons.star, color: AppColors.yellow, size: 16)),
                  ),
              ],
            ),
            trailing: const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 28),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RebusScreen(levelId: item['id']!, levelName: item['name']!),
                ),
              ).then((_) {
                storage.saveLevelResult(item['id']!, 3, titleId: item['titleId']);
                setState(() {});
              });
            },
          ),
        );
      },
    );
  }
}
