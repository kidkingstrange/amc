// lib/ui/screens/crossword_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../engine/crossword_engine.dart';
import '../../engine/crossword_models.dart';
import '../../services/game_storage.dart';
import '../theme.dart';
import '../widgets/crossword_grid_widget.dart';

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

class _CrosswordScreenState extends State<CrosswordScreen> with WidgetsBindingObserver {
  final storage = GameStorage();
  CrosswordEngine? _engine;
  bool _isLoading = true;

  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController(text: ' ');
  int _earnedPointsInLevel = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPuzzle();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Small delayed re-focus to guarantee Android window transition has finished
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) _requestKeyboardFocus();
      });
    }
  }

  void _requestKeyboardFocus() {
    if (!mounted) return;
    try {
      final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
      if (isKeyboardOpen && _focusNode.hasFocus) {
        return;
      }
    } catch (_) {}

    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
        SystemChannels.textInput.invokeMethod('TextInput.show');
      }
    });
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

    // Auto-focus native keyboard on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _requestKeyboardFocus();
    });
  }

  void _resetInputController() {
    _textController.value = const TextEditingValue(
      text: ' ',
      selection: TextSelection.collapsed(offset: 1),
    );
  }

  void _handleNativeKeyboardInput(String val) {
    if (_engine == null) return;

    if (val.isEmpty) {
      // Backspace was pressed on native keyboard
      _onBackspace();
      _resetInputController();
      return;
    }

    if (val.length > 1) {
      // A character was entered
      final char = val.substring(1).trim().toUpperCase();
      if (char.isNotEmpty) {
        _onLetter(char);
      }
      _resetInputController();
    }
  }

  void _onLetter(String letter) {
    if (_engine == null) return;

    final feedback = _engine!.enterLetter(letter);
    setState(() {});

    if (feedback == WordFeedback.wordCorrect) {
      _earnedPointsInLevel += 50;
      storage.addPoints(50);
      if (storage.hapticsEnabled) HapticFeedback.mediumImpact();
      if (storage.soundEnabled) SystemSound.play(SystemSoundType.click);

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Word Solved! +50 PTS (Locked in place)', style: TextStyle(fontWeight: FontWeight.bold)),
          duration: Duration(milliseconds: 1400),
          backgroundColor: AppColors.mint,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (feedback == WordFeedback.wordWrong) {
      if (storage.hapticsEnabled) HapticFeedback.heavyImpact();

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ Not quite right! Check your letters', style: TextStyle(fontWeight: FontWeight.bold)),
          duration: Duration(milliseconds: 1200),
          backgroundColor: AppColors.coral,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    if (_engine!.isCompleted) {
      _onLevelCompleted();
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

  void _onLevelCompleted() {
    const levelBonus = 200;
    _earnedPointsInLevel += levelBonus;
    storage.addPoints(levelBonus);
    if (storage.hapticsEnabled) HapticFeedback.mediumImpact();

    _showWinDialog();
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
            Text('🏆', style: TextStyle(fontSize: 28)),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mint, width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Text(
                    '+$_earnedPointsInLevel PTS EARNED!',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF065F46)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('Total Balance: ${storage.points} PTS', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            Text('Mistakes: ${_engine!.mistakesCount}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
            Text('Hints Used: ${_engine!.hintsUsed}', style: const TextStyle(fontSize: 14, color: Colors.black87)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Text('🏆', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Trophy Card Unlocked in your Dex!',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
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

  void _showHintShopSheet() {
    if (_engine == null) return;
    final activeWord = _engine!.activeWord;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (activeWord == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tap any word on the grid first to view hints!'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final isWordLocked = _engine!.isWordLocked(activeWord);

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.nightSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          final userPoints = storage.points;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('💡', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Text(
                            'Hint Shop',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                              '$userPoints Coins',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.ink),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${activeWord.number} ${activeWord.direction == ClueDirection.across ? "ACROSS" : "DOWN"}: "${activeWord.clue}"',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  if (isWordLocked)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.mint.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '✓ This word is already solved and locked in place!',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.mint),
                        ),
                      ),
                    )
                  else ...[
                    // Tier 1 Hint: Reveal First Letter (50 Coins)
                    _buildHintOptionCard(
                      tier: 'HINT 1',
                      title: 'Reveal Starting Letter',
                      description: 'Fills the first letter to get you started',
                      cost: 50,
                      userPoints: userPoints,
                      isDark: isDark,
                      onBuy: () {
                        if (storage.spendPoints(50)) {
                          Navigator.pop(ctx);
                          _engine!.revealFirstLetterOfActiveWord();
                          setState(() {});
                          if (storage.soundEnabled) SystemSound.play(SystemSoundType.click);
                          if (storage.hapticsEnabled) HapticFeedback.mediumImpact();
                          _requestKeyboardFocus();
                          if (_engine!.isCompleted) _onLevelCompleted();
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    // Tier 2 Hint: Reveal Random Letter (100 Coins)
                    _buildHintOptionCard(
                      tier: 'HINT 2',
                      title: 'Reveal Another Letter',
                      description: 'Fills in another missing letter to get you closer',
                      cost: 100,
                      userPoints: userPoints,
                      isDark: isDark,
                      onBuy: () {
                        if (storage.spendPoints(100)) {
                          Navigator.pop(ctx);
                          _engine!.revealRandomLetterOfActiveWord();
                          setState(() {});
                          if (storage.soundEnabled) SystemSound.play(SystemSoundType.click);
                          if (storage.hapticsEnabled) HapticFeedback.mediumImpact();
                          _requestKeyboardFocus();
                          if (_engine!.isCompleted) _onLevelCompleted();
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    // Tier 3 Hint: Solve Entire Word (250 Coins)
                    _buildHintOptionCard(
                      tier: 'HINT 3',
                      title: 'Solve Entire Word',
                      description: 'Completely reveals and locks the full word',
                      cost: 250,
                      userPoints: userPoints,
                      isDark: isDark,
                      isFinal: true,
                      onBuy: () {
                        if (storage.spendPoints(250)) {
                          Navigator.pop(ctx);
                          _engine!.revealActiveWord();
                          setState(() {});
                          if (storage.soundEnabled) SystemSound.play(SystemSoundType.click);
                          if (storage.hapticsEnabled) HapticFeedback.heavyImpact();
                          _requestKeyboardFocus();
                          if (_engine!.isCompleted) _onLevelCompleted();
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 14),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHintOptionCard({
    required String tier,
    required String title,
    required String description,
    required int cost,
    required int userPoints,
    required bool isDark,
    required VoidCallback onBuy,
    bool isFinal = false,
  }) {
    final canAfford = userPoints >= cost;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131728) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFinal
              ? AppColors.coral.withValues(alpha: 0.5)
              : (canAfford ? AppColors.primary.withValues(alpha: 0.3) : (isDark ? Colors.white12 : Colors.black12)),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isFinal
                            ? AppColors.coral.withValues(alpha: 0.2)
                            : AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tier,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isFinal ? AppColors.coral : AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: canAfford ? AppColors.yellow : (isDark ? Colors.white12 : Colors.black12),
              foregroundColor: canAfford ? AppColors.ink : (isDark ? Colors.white38 : Colors.black38),
              elevation: canAfford ? 1 : 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: canAfford ? onBuy : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🪙', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
                Text(
                  '$cost',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.levelName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          // Points Counter
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.ink),
                ),
              ],
            ),
          ),
          // Hint Shop Button (Spend Coins)
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: 'Hint Shop (Buy Hints with Coins)',
            onPressed: _showHintShopSheet,
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _requestKeyboardFocus,
          child: Column(
            children: [
              // Hidden TextField to capture phone's native keyboard input
              SizedBox(
                width: 1,
                height: 1,
                child: Opacity(
                  opacity: 0.0,
                  child: TextField(
                    focusNode: _focusNode,
                    controller: _textController,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    autocorrect: false,
                    enableSuggestions: false,
                    showCursor: false,
                    onChanged: _handleNativeKeyboardInput,
                  ),
                ),
              ),
              // Crossword Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: Center(
                    child: CrosswordGridWidget(
                      engine: _engine!,
                      onStateChanged: () => setState(() {}),
                      onTapCell: _requestKeyboardFocus,
                    ),
                  ),
                ),
              ),
            // Clue Bar & Native Keyboard Controls pinned above system keyboard
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.nightSurface : Colors.white,
                borderRadius: BorderRadius.circular(14.0),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                ],
                border: Border.all(
                  color: (activeWord != null && _engine!.isWordLocked(activeWord))
                      ? AppColors.mint
                      : (isDark ? Colors.white12 : Colors.black12),
                  width: (activeWord != null && _engine!.isWordLocked(activeWord)) ? 2.0 : 1.0,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() => _engine!.prevClue());
                          _requestKeyboardFocus();
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (activeWord != null)
                              Row(
                                children: [
                                  Text(
                                    '${activeWord.number} ${activeWord.direction == ClueDirection.across ? "ACROSS" : "DOWN"}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  if (_engine!.isWordLocked(activeWord)) ...[
                                    const SizedBox(width: 6),
                                    const Icon(Icons.lock, size: 12, color: AppColors.mint),
                                    const SizedBox(width: 2),
                                    const Text(
                                      'SOLVED',
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.mint),
                                    ),
                                  ],
                                ],
                              ),
                            Text(
                              activeWord?.clue ?? 'Tap any cell to start typing',
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
                        onPressed: () {
                          setState(() => _engine!.nextClue());
                          _requestKeyboardFocus();
                        },
                      ),
                    ],
                  ),
                  const Divider(height: 8),
                  // Control Buttons: Pencil Mode, Check, Keyboard Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Pencil Mode
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: _engine!.isPencilMode ? AppColors.yellow : (isDark ? Colors.white70 : Colors.black54),
                        ),
                        icon: Icon(_engine!.isPencilMode ? Icons.edit : Icons.edit_outlined, size: 18),
                        label: Text(_engine!.isPencilMode ? 'Pencil ON' : 'Pencil', style: const TextStyle(fontSize: 12)),
                        onPressed: () {
                          _onPencil();
                          _requestKeyboardFocus();
                        },
                      ),
                      // Check Letter
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                        icon: const Icon(Icons.spellcheck, size: 18),
                        label: const Text('Check', style: TextStyle(fontSize: 12)),
                        onPressed: () {
                          final ok = _engine!.checkActiveLetter();
                          setState(() {});
                          _requestKeyboardFocus();
                          if (ok) {
                            if (storage.hapticsEnabled) HapticFeedback.lightImpact();
                          } else {
                            if (storage.hapticsEnabled) HapticFeedback.heavyImpact();
                          }
                        },
                      ),
                      // Hint Shop Button
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                        icon: const Icon(Icons.lightbulb_outline, size: 18),
                        label: const Text('Hint', style: TextStyle(fontSize: 12)),
                        onPressed: _showHintShopSheet,
                      ),
                      // Keyboard Toggle
                      Builder(builder: (btnContext) {
                        final isKeyboardVisible = MediaQuery.of(btnContext).viewInsets.bottom > 0;
                        return TextButton.icon(
                          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                          icon: Icon(isKeyboardVisible ? Icons.keyboard_hide : Icons.keyboard, size: 18),
                          label: Text(isKeyboardVisible ? 'Hide Keybd' : 'Show Keybd', style: const TextStyle(fontSize: 12)),
                          onPressed: () {
                            if (isKeyboardVisible) {
                              _focusNode.unfocus();
                              SystemChannels.textInput.invokeMethod('TextInput.hide');
                            } else {
                              _requestKeyboardFocus();
                            }
                            setState(() {});
                          },
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}
