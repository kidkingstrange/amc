// lib/ui/screens/dex_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/game_storage.dart';
import '../theme.dart';

class DexScreen extends StatefulWidget {
  const DexScreen({super.key});

  @override
  State<DexScreen> createState() => _DexScreenState();
}

class _DexScreenState extends State<DexScreen> {
  List<Map<String, dynamic>> _allTitles = [];
  bool _isLoading = true;
  String _filter = 'All'; // 'All', 'Anime', 'Movies'
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTitles();
  }

  Future<void> _loadTitles() async {
    final raw = await rootBundle.loadString('content/titles.json');
    final decoded = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    setState(() {
      _allTitles = decoded;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final storage = GameStorage();
    final unlockedIds = storage.unlockedTitles.toSet();

    final filtered = _allTitles.where((t) {
      final type = t['type'] as String;
      if (_filter == 'Anime' && type != 'anime') return false;
      if (_filter == 'Movies' && type != 'movie') return false;
      if (_searchQuery.isNotEmpty) {
        final title = (t['title'] as String).toLowerCase();
        if (!title.contains(_searchQuery.toLowerCase())) return false;
      }
      return true;
    }).toList();

    final totalCount = _allTitles.length;
    final unlockedCount = _allTitles.where((t) => unlockedIds.contains(t['id'])).length;
    final progress = totalCount > 0 ? unlockedCount / totalCount : 0.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trophy Room & Trivia Dex', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            // How it Works Explainer Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Gameplay Trophy Hall',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Every puzzle you solve in the game unlocks its behind-the-scenes trivia card here. Play puzzles to collect all 190!',
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppColors.ink, height: 1.25),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Progress Header
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.nightSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Trophies Collected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(
                        '$unlockedCount / $totalCount Unlocked (${(progress * 100).toInt()}%)',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mint),
                    ),
                  ),
                ],
              ),
            ),
            // Filter Chips & Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Row(
                children: [
                  _buildFilterChip('All'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Anime'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Movies'),
                  const Spacer(),
                  SizedBox(
                    width: 130,
                    height: 38,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        prefixIcon: const Icon(Icons.search, size: 18),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                        filled: true,
                        fillColor: isDark ? AppColors.nightCell : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                  ),
                ],
              ),
            ),
            // List of Cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final item = filtered[i];
                  final isUnlocked = unlockedIds.contains(item['id']);
                  return _buildDexCard(item, isUnlocked, isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filter = label),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.ink,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDexCard(Map<String, dynamic> item, bool isUnlocked, bool isDark) {
    if (!isUnlocked) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDark ? const Color(0xFF131728) : const Color(0xFFF8FAFC),
        elevation: 0,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: const Row(
                  children: [
                    Text('🏆', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 8),
                    Text('Mystery Trophy Card', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                content: const Text(
                  'This trivia card will unlock automatically when you beat its puzzle in the game!\n\nNo purchase needed — all 190 cards are earned through your trivia skills.',
                  style: TextStyle(fontSize: 14, height: 1.3),
                ),
                actions: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Got it!'),
                  ),
                ],
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.nightCell : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(child: Text('❓', style: TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Undiscovered Mystery Title',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black54),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item['type'].toUpperCase()} • Solve puzzles in the game to collect',
                        style: const TextStyle(fontSize: 12, color: Colors.black38),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.info_outline, size: 20, color: Colors.black26),
              ],
            ),
          ),
        ),
      );
    }

    final facts = (item['facts'] as List?) ?? [];
    final firstFact = facts.isNotEmpty ? facts[0]['text'] as String : '';
    final isMovie = item['type'] == 'movie';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isMovie ? AppColors.coral.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${item['year']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isMovie ? AppColors.coral : AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${item['type'].toUpperCase()} • ${item['studioOrDirector']}',
              style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w600),
            ),
            if (firstFact.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.nightCell : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡 ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        firstFact,
                        style: const TextStyle(fontSize: 13, color: AppColors.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
