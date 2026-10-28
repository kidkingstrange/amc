// lib/ui/screens/rebus_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../engine/rebus_engine.dart';
import '../../services/game_storage.dart';
import '../theme.dart';

class RebusScreen extends StatefulWidget {
  final String levelId;
  final String levelTitle;

  const RebusScreen({
    super.key,
    required this.levelId,
    required this.levelTitle,
  });

  @override
  State<RebusScreen> createState() => _RebusScreenState();
}

class _RebusScreenState extends State<RebusScreen> with WidgetsBindingObserver {
  final storage = GameStorage();
  RebusEngine? _engine;
  bool _isLoading = true;

  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textController = TextEditingController(text: ' ');
  bool _isWrongAttempt = false;

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
    final assetPath = 'assets/puzzles/rebus/${widget.levelId}.json';
    final jsonStr = await rootBundle.loadString(assetPath);
    final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
    final puzzle = RebusPuzzle.fromJson(jsonMap);

    setState(() {
      _engine = RebusEngine(puzzle);
      _isLoading = false;
    });

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
      _onBackspace();
      _resetInputController();
      return;
    }

    if (val.length > 1) {
      final char = val.substring(1).trim().toUpperCase();
      if (char.isNotEmpty) {
        _onLetter(char);
      }
      _resetInputController();
    }
  }

  void _onLetter(String letter) {
    if (_engine == null) return;

    setState(() {
      _isWrongAttempt = false;
      _engine!.enterLetter(letter);
    });

    // Check if player filled all slots
    final allFilled = _engine!.slots.every((s) => s.isSeparator || s.guess.isNotEmpty);
    if (allFilled) {
      if (_engine!.isCompleted) {
        // Success Feedback
        if (storage.hapticsEnabled) HapticFeedback.mediumImpact();
        if (storage.soundEnabled) SystemSound.play(SystemSoundType.click);
        storage.addPoints(100);

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Correct Title! +100 PTS', style: TextStyle(fontWeight: FontWeight.bold)),
            duration: Duration(milliseconds: 1400),
            backgroundColor: AppColors.mint,
            behavior: SnackBarBehavior.floating,
          ),
        );

        _showWinDialog();
      } else {
        // Wrong Guess Feedback
        setState(() => _isWrongAttempt = true);
        if (storage.hapticsEnabled) HapticFeedback.heavyImpact();

        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Not quite right! Check your letters or use a hint', style: TextStyle(fontWeight: FontWeight.bold)),
            duration: Duration(milliseconds: 1400),
            backgroundColor: AppColors.coral,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _onBackspace() {
    if (_engine == null) return;
    setState(() {
      _isWrongAttempt = false;
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
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mint, width: 1.5),
              ),
              child: const Row(
                children: [
                  Text('🪙', style: TextStyle(fontSize: 20)),
                  SizedBox(width: 8),
                  Text(
                    '+100 PTS REWARD!',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF065F46)),
                  ),
                ],
              ),
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
                style: const TextStyle(fontSize: 14, color: AppColors.ink, height: 1.3),
              ),
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hints = _engine!.unlockedHints;

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
                            'Rebus Hint Shop',
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
                    'Emojis: ${_engine!.puzzle.emojis} • Guess the ${_engine!.puzzle.category}',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (_engine!.isCompleted)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.mint.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '✓ Puzzle is already solved!',
                          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.mint),
                        ),
                      ),
                    )
                  else ...[
                    // Tier 1 Hint: Category & Year Trivia Hint (50 Coins)
                    _buildHintOptionCard(
                      tier: 'HINT 1',
                      title: 'Category & Year Trivia',
                      description: hints.contains(1)
                          ? 'Unlocked: "${_engine!.puzzle.hintLadder['hint1'] ?? ''}"'
                          : 'Reveals release year and extra trivia context',
                      cost: 50,
                      isUnlocked: hints.contains(1),
                      userPoints: userPoints,
                      isDark: isDark,
                      onBuy: () {
                        if (storage.spendPoints(50)) {
                          Navigator.pop(ctx);
                          _engine!.unlockHint(1);
                          setState(() {});
                          if (storage.soundEnabled) SystemSound.play(SystemSoundType.click);
                          if (storage.hapticsEnabled) HapticFeedback.mediumImpact();
                          _requestKeyboardFocus();
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    // Tier 2 Hint: Reveal First Letter (100 Coins)
                    _buildHintOptionCard(
                      tier: 'HINT 2',
                      title: 'Reveal Starting Letter',
                      description: hints.contains(2)
                          ? 'Unlocked: First letter placed in slot'
                          : 'Fills the first letter of the title',
                      cost: 100,
                      isUnlocked: hints.contains(2),
                      userPoints: userPoints,
                      isDark: isDark,
                      onBuy: () {
                        if (storage.spendPoints(100)) {
                          Navigator.pop(ctx);
                          _engine!.unlockHint(2);
                          setState(() {});
                          if (storage.soundEnabled) SystemSound.play(SystemSoundType.click);
                          if (storage.hapticsEnabled) HapticFeedback.mediumImpact();
                          _requestKeyboardFocus();
                          if (_engine!.isCompleted) _showWinDialog();
                        }
                      },
                    ),
                    const SizedBox(height: 10),

                    // Tier 3 Hint: Solve Full Title (250 Coins)
                    _buildHintOptionCard(
                      tier: 'HINT 3',
                      title: 'Solve Entire Title',
                      description: 'Completely reveals and solves the full puzzle',
                      cost: 250,
                      isUnlocked: false,
                      userPoints: userPoints,
                      isDark: isDark,
                      isFinal: true,
                      onBuy: () {
                        if (storage.spendPoints(250)) {
                          Navigator.pop(ctx);
                          _engine!.revealFullAnswer();
                          setState(() {});
                          if (storage.soundEnabled) SystemSound.play(SystemSoundType.click);
                          if (storage.hapticsEnabled) HapticFeedback.heavyImpact();
                          _showWinDialog();
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
    required bool isUnlocked,
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
          color: isUnlocked
              ? AppColors.mint.withValues(alpha: 0.5)
              : (isFinal
                  ? AppColors.coral.withValues(alpha: 0.5)
                  : (canAfford ? AppColors.primary.withValues(alpha: 0.3) : (isDark ? Colors.white12 : Colors.black12))),
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
                        color: isUnlocked
                            ? AppColors.mint.withValues(alpha: 0.2)
                            : (isFinal ? AppColors.coral.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.15)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isUnlocked ? '$tier ✓' : tier,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? AppColors.mint : (isFinal ? AppColors.coral : AppColors.primary),
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
          if (isUnlocked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.mint.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'ACTIVE',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mint),
              ),
            )
          else
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

  List<List<RebusSlot>> _getWordSlots() {
    final List<List<RebusSlot>> words = [];
    List<RebusSlot> currentWord = [];

    for (final slot in _engine!.slots) {
      if (slot.solutionChar == ' ') {
        if (currentWord.isNotEmpty) {
          words.add(currentWord);
          currentWord = [];
        }
      } else {
        currentWord.add(slot);
      }
    }
    if (currentWord.isNotEmpty) {
      words.add(currentWord);
    }
    return words;
  }

  Widget _buildSlotItem(RebusSlot slot, bool isDark) {
    if (slot.isSeparator) {
      return SizedBox(
        width: 18,
        height: 48,
        child: Center(
          child: Text(
            slot.solutionChar,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppColors.ink,
            ),
          ),
        ),
      );
    }

    final isActive = _engine!.activeIndex == slot.index;
    final isFilledCorrect = _engine!.isCompleted;

    Color slotBg;
    if (isFilledCorrect) {
      slotBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
    } else if (_isWrongAttempt) {
      slotBg = AppColors.cellError;
    } else if (isActive) {
      slotBg = isDark ? const Color(0xFF3730A3) : AppColors.cellSelectedLight;
    } else {
      slotBg = isDark ? AppColors.nightCell : Colors.white;
    }

    Color borderColor;
    if (isFilledCorrect) {
      borderColor = AppColors.mint;
    } else if (_isWrongAttempt) {
      borderColor = AppColors.coral;
    } else if (isActive) {
      borderColor = AppColors.primary;
    } else {
      borderColor = isDark ? Colors.white24 : Colors.black26;
    }

    return GestureDetector(
      onTap: () {
        setState(() => _engine!.selectSlot(slot.index));
        _requestKeyboardFocus();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 38,
        height: 48,
        decoration: BoxDecoration(
          color: slotBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: borderColor,
            width: (isActive || _isWrongAttempt || isFilledCorrect) ? 2.0 : 1.0,
          ),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
          ],
        ),
        child: Center(
          child: Text(
            slot.guess,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isFilledCorrect
                  ? (isDark ? Colors.white : const Color(0xFF065F46))
                  : (isDark ? Colors.white : AppColors.ink),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWordRows(bool isDark) {
    final words = _getWordSlots();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int w = 0; w < words.length; w++) ...[
          if (w > 0) const SizedBox(height: 10.0),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < words[w].length; i++) ...[
                  if (i > 0) const SizedBox(width: 6.0),
                  _buildSlotItem(words[w][i], isDark),
                ],
              ],
            ),
          ),
        ],
      ],
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.levelTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
          // Hint Shop Button
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: 'Hint Shop (Buy Hints with Coins)',
            onPressed: _showHintShopSheet,
          ),
          // Keyboard toggle
          Builder(builder: (btnContext) {
            final isKeyboardVisible = MediaQuery.of(btnContext).viewInsets.bottom > 0;
            return IconButton(
              icon: Icon(isKeyboardVisible ? Icons.keyboard_hide : Icons.keyboard),
              tooltip: isKeyboardVisible ? 'Hide Keyboard' : 'Show Keyboard',
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 12),
                    // Emoji Rebus Sequence Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
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
                            style: const TextStyle(fontSize: 40, letterSpacing: 8),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.cellActiveLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'GUESS THE ${p.category.toUpperCase()} • ${p.difficulty.toUpperCase()}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Letter Slots (Each word on its own dedicated row)
                    _buildWordRows(isDark),
                    const SizedBox(height: 24),
                    // Hint Shop Button
                    OutlinedButton.icon(
                      icon: const Icon(Icons.lightbulb_outline, size: 20),
                      label: const Text('Buy Hints with Coins (🪙 50 - 250)'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _showHintShopSheet,
                    ),
                    if (_engine!.unlockedHints.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.nightSurface : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Hint: ${_engine!.puzzle.hintLadder['hint1'] ?? ''}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }
}
