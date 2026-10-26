// lib/ui/screens/crossword_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../engine/crossword_engine.dart';
import '../../engine/crossword_models.dart';
import '../theme.dart';
import '../widgets/crossword_grid_widget.dart';
import '../widgets/keyboard_widget.dart';

class CrosswordScreen extends StatefulWidget {
  final String levelId;
  final String levelName;

  const CrosswordScreen({
    super.key,
    required this.levelId,
    required this.levelName,
  });

  @override
  State<CrosswordScreen> createState() => _CrosswordScreenState();
}

class _CrosswordScreenState extends State<CrosswordScreen> {
  CrosswordEngine? _engine;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPuzzle();
  }

  Future<void> _loadPuzzle() async {
    final assetPath = 'assets/puzzles/crosswords/${widget.levelId}.json';
    final jsonStr = await rootBundle.loadString(assetPath);
    final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
    final puzzle = CrosswordPuzzle.fromJson(jsonMap);

    setState(() {
      _engine = CrosswordEngine(puzzle);
      _isLoading = false;
    });
  }

  void _onLetter(String letter) {
    if (_engine == null) return;
    setState(() {
      _engine!.enterLetter(letter);
    });
    if (_engine!.isCompleted) {
      _showWinDialog();
    }
  }

  void _onBackspace() {
    if (_engine == null) return;
    setState(() {
      _engine!.backspace();
    });
  }

  void _onPencil() {
    if (_engine == null) return;
    setState(() {
      _engine!.togglePencilMode();
    });
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🎉', style: TextStyle(fontSize: 28)),
            SizedBox(width: 8),
            Text('Puzzle Solved!', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                return Icon(
                  i < _engine!.stars ? Icons.star : Icons.star_border,
                  color: AppColors.yellow,
                  size: 36,
                );
              }),
            ),
            const SizedBox(height: 16),
            Text('Mistakes: ${_engine!.mistakesCount}', style: const TextStyle(fontSize: 16)),
            Text('Hints Used: ${_engine!.hintsUsed}', style: const TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Back to Levels'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _engine == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final activeWord = _engine!.activeWord;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.levelName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: 'Reveal Letter Hint',
            onPressed: () {
              setState(() {
                _engine!.revealActiveLetter();
              });
              if (_engine!.isCompleted) _showWinDialog();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Crossword Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Center(
                  child: CrosswordGridWidget(
                    engine: _engine!,
                    onStateChanged: () => setState(() {}),
                  ),
                ),
              ),
            ),
            // Clue Navigation Bar pinned above keyboard
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.nightSurface : Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => setState(() => _engine!.prevClue()),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (activeWord != null)
                          Text(
                            '${activeWord.number} ${activeWord.direction == ClueDirection.across ? "ACROSS" : "DOWN"}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        Text(
                          activeWord?.clue ?? 'Select a cell',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => setState(() => _engine!.nextClue()),
                  ),
                ],
              ),
            ),
            // Custom In-App Keyboard
            InAppKeyboardWidget(
              onKeyPressed: _onLetter,
              onBackspace: _onBackspace,
              onPencilToggle: _onPencil,
              isPencilMode: _engine!.isPencilMode,
            ),
          ],
        ),
      ),
    );
  }
}
