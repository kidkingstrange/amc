// lib/ui/widgets/crossword_grid_widget.dart
import 'package:flutter/material.dart';
import '../../engine/crossword_engine.dart';
import '../../engine/crossword_models.dart';
import '../theme.dart';

class CrosswordGridWidget extends StatelessWidget {
  final CrosswordEngine engine;
  final VoidCallback onStateChanged;
  final VoidCallback? onTapCell;

  const CrosswordGridWidget({
    super.key,
    required this.engine,
    required this.onStateChanged,
    this.onTapCell,
  });

  @override
  Widget build(BuildContext context) {
    final puzzle = engine.puzzle;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AspectRatio(
      aspectRatio: puzzle.width / puzzle.height,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.nightSurface : Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: List.generate(puzzle.height, (r) {
            return Expanded(
              child: Row(
                children: List.generate(puzzle.width, (c) {
                  return Expanded(
                    child: _buildCell(context, r, c, isDark),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildCell(BuildContext context, int r, int c, bool isDark) {
    final cell = engine.puzzle.grid[r][c];

    if (cell.isBlocked) {
      return Container(
        margin: const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F1221) : const Color(0xFFE2E8F0),
          borderRadius: BorderRadius.circular(4.0),
        ),
      );
    }

    final isSelected = engine.selectedRow == r && engine.selectedCol == c;
    final isInActiveWord = _isCellInActiveWord(r, c);

    Color cellBg;
    if (cell.isError) {
      cellBg = AppColors.cellError;
    } else if (isSelected) {
      cellBg = isDark ? const Color(0xFF3730A3) : AppColors.cellSelectedLight;
    } else if (cell.isLocked) {
      cellBg = isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5);
    } else if (isInActiveWord) {
      cellBg = isDark ? AppColors.nightCellActive : AppColors.cellActiveLight;
    } else {
      cellBg = isDark ? AppColors.nightCell : Colors.white;
    }

    return GestureDetector(
      onTap: () {
        engine.selectCell(r, c);
        onStateChanged();
        onTapCell?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.all(1.0),
        decoration: BoxDecoration(
          color: cellBg,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : cell.isError
                    ? AppColors.coral
                    : cell.isLocked
                        ? AppColors.mint
                        : (isDark ? Colors.white12 : const Color(0xFFCBD5E1)),
            width: isSelected ? 2.5 : (cell.isLocked ? 1.5 : 1.0),
          ),
        ),
        child: Stack(
          children: [
            // Number in top-left
            if (cell.number != null)
              Positioned(
                top: 2,
                left: 3,
                child: Text(
                  '${cell.number}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ),
            // Locked check indicator in top-right
            if (cell.isLocked)
              const Positioned(
                top: 2,
                right: 3,
                child: Icon(
                  Icons.check,
                  size: 10,
                  color: AppColors.mint,
                ),
              ),
            // Entered Guess Letter
            Center(
              child: Text(
                cell.guess,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cell.isLocked
                      ? (isDark ? Colors.white : const Color(0xFF065F46))
                      : cell.isPencil
                          ? (isDark ? Colors.white38 : Colors.black38)
                          : (isDark ? Colors.white : AppColors.ink),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isCellInActiveWord(int r, int c) {
    final word = engine.activeWord;
    if (word == null) return false;
    if (word.direction == ClueDirection.across) {
      return r == word.row && c >= word.col && c < word.col + word.length;
    } else {
      return c == word.col && r >= word.row && r < word.row + word.length;
    }
  }
}
