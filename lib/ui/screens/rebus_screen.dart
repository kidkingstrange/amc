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
                    // Letter Slots (Tap slot to focus and type)
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6.0,
                      runSpacing: 8.0,
                      children: List.generate(_engine!.slots.length, (i) {
                        final slot = _engine!.slots[i];
                        if (slot.isSeparator) {
                          return const SizedBox(
                            width: 16,
                            height: 48,
                            child: Center(
                              child: Text(' ', style: TextStyle(fontSize: 20)),
                            ),
                          );
                        }
                        final isActive = _engine!.activeIndex == i;
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
                            setState(() => _engine!.selectSlot(i));
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
                      }),
                    ),
                    const SizedBox(height: 24),
                    // Hint Ladder Button
                    OutlinedButton.icon(
                      icon: const Icon(Icons.lightbulb_outline, size: 20),
                      label: Text(
                        _engine!.unlockedHints.isEmpty
                            ? 'Unlock Category & Year Hint'
                            : (_engine!.unlockedHints.length == 1
                                ? 'Reveal First Letter'
                                : 'Reveal Random Letter'),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                        _requestKeyboardFocus();
                        if (_engine!.isCompleted) _showWinDialog();
                      },
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
