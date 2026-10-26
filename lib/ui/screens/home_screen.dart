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

  const HomeScreen({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = GameStorage();

  // Prototype level metadata
  final List<Map<String, String>> crosswords = [
    {'id': 'cw_01', 'name': 'Demon & Sorcery', 'cat': 'Anime', 'diff': 'Easy', 'titleId': 'ds_kimetsu'},
    {'id': 'cw_02', 'name': 'Titans & Heroes', 'cat': 'Anime', 'diff': 'Easy', 'titleId': 'aot_snk'},
    {'id': 'cw_03', 'name': 'Curses & Ghouls', 'cat': 'Anime', 'diff': 'Medium', 'titleId': 'jjk_sorcery'},
    {'id': 'cw_04', 'name': 'Alchemy & Ninja', 'cat': 'Anime', 'diff': 'Medium', 'titleId': 'naruto_ship'},
    {'id': 'cw_05', 'name': 'Pirates & Spirits', 'cat': 'Anime', 'diff': 'Hard', 'titleId': 'one_piece'},
    {'id': 'cw_06', 'name': 'Dark Knights & Inception', 'cat': 'Movies', 'diff': 'Easy', 'titleId': 'dark_knight'},
    {'id': 'cw_07', 'name': 'Interstellar & Parasite', 'cat': 'Movies', 'diff': 'Easy', 'titleId': 'interstellar'},
    {'id': 'cw_08', 'name': 'Avengers & Infinity', 'cat': 'Movies', 'diff': 'Medium', 'titleId': 'avengers_inf'},
    {'id': 'cw_09', 'name': 'Nollywood Blockbusters', 'cat': 'Movies', 'diff': 'Medium', 'titleId': 'wedding_party'},
    {'id': 'cw_010', 'name': 'Cinema Masters & Epics', 'cat': 'Movies', 'diff': 'Hard', 'titleId': 'oppenheimer'},
  ];

  final List<Map<String, String>> rebuses = [
    {'id': 'rebus_001', 'name': 'Demon Slayer', 'emojis': '⚔️ 👹 🚂 🌊', 'cat': 'Anime', 'diff': 'Easy', 'titleId': 'ds_kimetsu'},
    {'id': 'rebus_002', 'name': 'Attack on Titan', 'emojis': '🧱 👤 ⚔️ 🩸', 'cat': 'Anime', 'diff': 'Easy', 'titleId': 'aot_snk'},
    {'id': 'rebus_003', 'name': 'Jujutsu Kaisen', 'emojis': '🤞 👁️ 💀 🏫', 'cat': 'Anime', 'diff': 'Medium', 'titleId': 'jjk_sorcery'},
    {'id': 'rebus_004', 'name': 'Spirited Away', 'emojis': '🐷 ♨️ 🐉 👧', 'cat': 'Anime', 'diff': 'Easy', 'titleId': 'spirited_away'},
    {'id': 'rebus_005', 'name': 'Chainsaw Man', 'emojis': '🪚 🐕 🩸 👿', 'cat': 'Anime', 'diff': 'Medium', 'titleId': 'chainsaw_man'},
    {'id': 'rebus_006', 'name': 'The Dark Knight', 'emojis': '🦇 🃏 🏙️ 🤡', 'cat': 'Movies', 'diff': 'Easy', 'titleId': 'dark_knight'},
    {'id': 'rebus_007', 'name': 'Inception', 'emojis': '💤 🌀 🏙️ ⏳', 'cat': 'Movies', 'diff': 'Easy', 'titleId': 'inception'},
    {'id': 'rebus_008', 'name': 'Interstellar', 'emojis': '🚀 ⏳ 🌌 🌽', 'cat': 'Movies', 'diff': 'Medium', 'titleId': 'interstellar'},
    {'id': 'rebus_009', 'name': 'A Tribe Called Judah', 'emojis': '💰 👨‍👦‍👦 🏪 🚨', 'cat': 'Movies', 'diff': 'Medium', 'titleId': 'tribe_judah'},
    {'id': 'rebus_010', 'name': 'Oppenheimer', 'emojis': '💣 ⚛️ ⏳ 🎩', 'cat': 'Movies', 'diff': 'Hard', 'titleId': 'oppenheimer'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: const Text(
            'Anime and Movies Crossword',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
          actions: [
            // Points Badge
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.yellow.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.yellow, width: 1.5),
              ),
              child: Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '${storage.points}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Daily Streak flame badge
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.coral.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.coral, width: 1.5),
              ),
              child: Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 3),
                  Text(
                    '${storage.dailyStreak}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink, fontSize: 12),
                  ),
                ],
              ),
            ),
            // Dex Button
            IconButton(
              icon: const Icon(Icons.menu_book_outlined),
              tooltip: 'Trivia Collection (Dex)',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DexScreen())).then((_) => setState(() {}));
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
        body: SafeArea(
          bottom: true,
          child: Column(
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
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('✨', style: TextStyle(fontSize: 22)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DAILY CHALLENGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.2)),
                          SizedBox(height: 2),
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
                            builder: (_) => const CrosswordScreen(levelId: 'cw_01', levelName: 'Daily Challenge: Demon & Sorcery'),
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
      ),
    );
  }

  Widget _buildCrosswordList(BuildContext context, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      itemCount: rebuses.length,
      itemBuilder: (ctx, i) {
        final item = rebuses[i];
        final stars = storage.getStars(item['id']!);
        final isSolved = stars > 0;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Text(item['emojis']!, style: const TextStyle(fontSize: 22)),
            // If unsolved, do not spoil title! Show Level number and category
            title: Text(
              isSolved ? 'Level ${i + 1}: ${item['name']}' : 'Level ${i + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            subtitle: Row(
              children: [
                Text(isSolved ? '${item['cat']} • ${item['diff']}' : 'Guess the ${item['cat']} • ${item['diff']}'),
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
                  builder: (_) => RebusScreen(
                    levelId: item['id']!,
                    levelTitle: 'Level ${i + 1} • Rebus',
                  ),
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
