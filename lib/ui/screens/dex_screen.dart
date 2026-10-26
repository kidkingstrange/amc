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
  String _filter = 'All'; // 'All', 'Anime', 'Movies'
  String _searchQuery = '';
  bool _isLoading = true;

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
        title: const Text('Trivia Collection (Dex)', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Progress Header
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                    const Text('Total Collection Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(
                      '$unlockedCount / $totalCount Unlocked (${(progress * 100).toInt()}%)',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
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
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Anime'),
                const SizedBox(width: 8),
                _buildFilterChip('Movies'),
                const Spacer(),
                SizedBox(
                  width: 140,
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
          const SizedBox(height: 8),
          // List of Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
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
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDark ? const Color(0xFF131728) : const Color(0xFFF8FAFC),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.nightCell : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.lock_outline, color: Colors.black38),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('??? Locked Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black54)),
                  Text('${item['type'].toUpperCase()} • Solve puzzles to reveal', style: const TextStyle(fontSize: 12, color: Colors.black38)),
                ],
              ),
            ],
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
                    color: isMovie ? AppColors.coral.withOpacity(0.15) : AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${item['year']}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isMovie ? AppColors.coral : AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${isMovie ? "Director" : "Studio"}: ${item['studioOrDirector']}',
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            if (firstFact.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
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
