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

    final totalCrosswords = crosswords.length;
    final totalRebus = rebuses.length;
    final totalLevels = totalCrosswords + totalRebus;

    final completedCrosswords = crosswords.where((cw) => storage.getStars(cw['id']!) > 0).length;
    final completedRebus = rebuses.where((r) => storage.getStars(r['id']!) > 0).length;
    final totalCompleted = completedCrosswords + completedRebus;

    int totalStars = 0;
    for (final cw in crosswords) {
      totalStars += storage.getStars(cw['id']!);
    }
    for (final r in rebuses) {
      totalStars += storage.getStars(r['id']!);
    }
    final maxStars = totalLevels * 3;
    final double progress = totalLevels > 0 ? (totalCompleted / totalLevels).clamp(0.0, 1.0) : 0.0;
    final int progressPercent = (progress * 100).toInt();

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
            // Trophy Room & Dex Button
            IconButton(
              icon: const Icon(Icons.emoji_events_outlined),
              tooltip: 'Trophy Room & Trivia Dex',
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
              // Overall Game Completion Progress Bar Card
              _buildOverallProgressCard(
                context: context,
                isDark: isDark,
                progress: progress,
                progressPercent: progressPercent,
                totalCompleted: totalCompleted,
                totalLevels: totalLevels,
                totalStars: totalStars,
                maxStars: maxStars,
                completedCrosswords: completedCrosswords,
                totalCrosswords: totalCrosswords,
                completedRebus: completedRebus,
                totalRebus: totalRebus,
              ),

              // Daily Challenge Highlight Banner
              Container(
                margin: const EdgeInsets.fromLTRB(12, 4, 12, 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF6366F1)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('✨', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DAILY CHALLENGE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 1.1)),
                          SizedBox(height: 2),
                          Text('Level 1: Demon & Sorcery', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.yellow,
                        foregroundColor: AppColors.ink,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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

  Widget _buildOverallProgressCard({
    required BuildContext context,
    required bool isDark,
    required double progress,
    required int progressPercent,
    required int totalCompleted,
    required int totalLevels,
    required int totalStars,
    required int maxStars,
    required int completedCrosswords,
    required int totalCrosswords,
    required int completedRebus,
    required int totalRebus,
  }) {
    final isAllCompleted = progress >= 1.0 && totalLevels > 0;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        _showProgressDetailsSheet(
          context: context,
          isDark: isDark,
          progress: progress,
          progressPercent: progressPercent,
          totalCompleted: totalCompleted,
          totalLevels: totalLevels,
          totalStars: totalStars,
          maxStars: maxStars,
          completedCrosswords: completedCrosswords,
          totalCrosswords: totalCrosswords,
          completedRebus: completedRebus,
          totalRebus: totalRebus,
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E2438) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      isAllCompleted ? '🎉' : '🏆',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isAllCompleted ? 'Game 100% Completed!' : 'Overall Game Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? Colors.white : AppColors.ink,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAllCompleted
                        ? AppColors.mint.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isAllCompleted ? AppColors.mint : AppColors.primary,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$progressPercent% Done',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isAllCompleted ? AppColors.mint : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress Bar Track
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  isAllCompleted ? AppColors.mint : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Sub stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '🎯 $totalCompleted of $totalLevels Levels',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                Text(
                  '⭐ $totalStars / $maxStars Stars',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                Text(
                  '🎁 ${storage.unlockedTitles.length} Trophies',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProgressDetailsSheet({
    required BuildContext context,
    required bool isDark,
    required double progress,
    required int progressPercent,
    required int totalCompleted,
    required int totalLevels,
    required int totalStars,
    required int maxStars,
    required int completedCrosswords,
    required int totalCrosswords,
    required int completedRebus,
    required int totalRebus,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E2438) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Text('🏆', style: TextStyle(fontSize: 26)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overall Game Completion',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.ink,
                            ),
                          ),
                          Text(
                            '$progressPercent% of the full game completed',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 12,
                    backgroundColor: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress >= 1.0 ? AppColors.mint : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Detailed Breakdown List
                _buildProgressDetailRow(
                  icon: '📝',
                  title: 'Crossword Puzzles',
                  value: '$completedCrosswords / $totalCrosswords Cleared',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _buildProgressDetailRow(
                  icon: '🧩',
                  title: 'Emoji Rebus Puzzles',
                  value: '$completedRebus / $totalRebus Cleared',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _buildProgressDetailRow(
                  icon: '⭐',
                  title: 'Mastery Stars',
                  value: '$totalStars / $maxStars Earned',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _buildProgressDetailRow(
                  icon: '🪙',
                  title: 'Trivia Points',
                  value: '${storage.points} PTS',
                  isDark: isDark,
                ),
                const SizedBox(height: 10),
                _buildProgressDetailRow(
                  icon: '🏆',
                  title: 'Trophy Room Cards',
                  value: '${storage.unlockedTitles.length} / 190 Unlocked',
                  isDark: isDark,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.emoji_events, size: 18),
                        label: const Text('View Dex'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const DexScreen()),
                          ).then((_) => setState(() {}));
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProgressDetailRow({
    required String icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : AppColors.ink,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.ink,
          ),
        ),
      ],
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
        // Sequential level unlock rule: Level 1 is always unlocked. Next level unlocked if previous has at least 1 star.
        final bool isUnlocked = i == 0 || storage.getStars(crosswords[i - 1]['id']!) > 0;

        if (!isUnlocked) {
          // Locked Level Card
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: isDark ? const Color(0xFF131728) : const Color(0xFFF1F5F9),
            elevation: 0,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: CircleAvatar(
                backgroundColor: isDark ? Colors.white12 : Colors.black12,
                foregroundColor: isDark ? Colors.white38 : Colors.black38,
                child: const Icon(Icons.lock, size: 18),
              ),
              title: Text(
                'Level ${i + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
              subtitle: Text(
                '🔒 Complete Level $i to unlock',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white30 : Colors.black38,
                ),
              ),
              trailing: Icon(
                Icons.lock_outline,
                color: isDark ? Colors.white24 : Colors.black26,
                size: 22,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🔒 Complete Level $i to unlock Level ${i + 1}!', style: const TextStyle(fontWeight: FontWeight.bold)),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
          );
        }

        // Unlocked Level Card
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
            title: Text('Level ${i + 1}: ${item['name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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
            trailing: Icon(
              stars > 0 ? Icons.check_circle_outline_rounded : Icons.play_arrow_rounded,
              color: stars > 0 ? AppColors.mint : AppColors.primary,
              size: 28,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CrosswordScreen(levelId: item['id']!, levelName: 'Level ${i + 1}: ${item['name']}'),
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
        // Sequential level unlock rule: Level 1 is always unlocked. Next level unlocked if previous has at least 1 star.
        final bool isUnlocked = i == 0 || storage.getStars(rebuses[i - 1]['id']!) > 0;

        if (!isUnlocked) {
          // Locked Rebus Card
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: isDark ? const Color(0xFF131728) : const Color(0xFFF1F5F9),
            elevation: 0,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              leading: const Text('🔒', style: TextStyle(fontSize: 22)),
              title: Text(
                'Level ${i + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
              subtitle: Text(
                '🔒 Complete Level $i to unlock',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white30 : Colors.black38,
                ),
              ),
              trailing: Icon(
                Icons.lock_outline,
                color: isDark ? Colors.white24 : Colors.black26,
                size: 22,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🔒 Complete Level $i to unlock Level ${i + 1}!', style: const TextStyle(fontWeight: FontWeight.bold)),
                    duration: const Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
          );
        }

        // Unlocked Rebus Card
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: Text(item['emojis']!, style: const TextStyle(fontSize: 22)),
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
            trailing: Icon(
              stars > 0 ? Icons.check_circle_outline_rounded : Icons.play_arrow_rounded,
              color: stars > 0 ? AppColors.mint : AppColors.primary,
              size: 28,
            ),
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
