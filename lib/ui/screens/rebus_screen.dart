// lib/ui/screens/rebus_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../engine/rebus_engine.dart';
import '../theme.dart';
import '../widgets/keyboard_widget.dart';

class RebusScreen extends StatefulWidget {
  final String levelId;
  final String levelName;

  const RebusScreen({
    super.key,
    required this.levelId,
    required this.levelName,
  });

  @override
  State<RebusScreen> createState() => _RebusScreenState();
}

class _RebusScreenState extends State<RebusScreen> {
  RebusEngine? _engine;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPuzzle();
  }

  Future<void> _loadPuzzle() async {
    final assetPath = 'assets/puzzles/rebus/${widget.levelId}.json';
    final jsonStr = await rootBundle.loadString(assetPath);
    final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
    final puzzle = RebusPuzzle.fromJson(jsonMap);

    setState(() {
      _engine = RebusEngine(puzzle);
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

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('🎯', style: TextStyle(fontSize: 28)),
            SizedBox(width: 8),
            Text('Solved!', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.ink)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _engine!.puzzle.answer,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: Text(
                _engine!.puzzle.explanation,
                style: const TextStyle(fontSize: 14, color: AppColors.ink),
              ),
            ),
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

    final p = _engine!.puzzle;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.levelName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Emoji Rebus Sequence Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.nightSurface : Colors.white,
                        borderRadius: BorderRadius.circular(20.0),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            p.emojis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 36, letterSpacing: 6),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.cellActiveLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${p.category.toUpperCase()} • ${p.difficulty.toUpperCase()}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Letter Slots
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6.0,
                      runSpacing: 8.0,
                      children: List.generate(_engine!.slots.length, (i) {
                        final slot = _engine!.slots[i];
                        if (slot.isSeparator) {
                          return const SizedBox(
                            width: 16,
                            height: 44,
                            child: Center(
                              child: Text(' ', style: TextStyle(fontSize: 20)),
                            ),
                          );
                        }
                        final isActive = _engine!.activeIndex == i;
                        return GestureDetector(
                          onTap: () => setState(() => _engine!.selectSlot(i)),
                          child: Container(
                            width: 36,
                            height: 44,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? (isDark ? const Color(0xFF3730A3) : AppColors.cellSelectedLight)
                                  : (isDark ? AppColors.nightCell : Colors.white),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isActive ? AppColors.primary : Colors.black26,
                                width: isActive ? 2.0 : 1.0,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                slot.guess,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.ink,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    // Hint Ladder Button
                    OutlinedButton.icon(
                      icon: const Icon(Icons.lightbulb_outline, size: 18),
                      label: const Text('Unlock Hint'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          if (!_engine!.unlockedHints.contains(1)) {
                            _engine!.unlockHint(1);
                          } else if (!_engine!.unlockedHints.contains(2)) {
                            _engine!.unlockHint(2);
                          } else {
                            _engine!.unlockHint(3);
                          }
                        });
                        if (_engine!.isCompleted) _showWinDialog();
                      },
                    ),
                    if (_engine!.unlockedHints.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          _engine!.puzzle.hintLadder['hint1'] as String,
                          style: const TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Keyboard
            InAppKeyboardWidget(
              onKeyPressed: _onLetter,
              onBackspace: _onBackspace,
            ),
          ],
        ),
      ),
    );
  }
}
