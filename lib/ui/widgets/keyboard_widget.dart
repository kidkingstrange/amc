// lib/ui/widgets/keyboard_widget.dart
import 'package:flutter/material.dart';
import '../theme.dart';

class InAppKeyboardWidget extends StatelessWidget {
  final ValueChanged<String> onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback? onPencilToggle;
  final bool isPencilMode;

  const InAppKeyboardWidget({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
    this.onPencilToggle,
    this.isPencilMode = false,
  });

  static const List<String> row1 = ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'];
  static const List<String> row2 = ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'];
  static const List<String> row3 = ['Z', 'X', 'C', 'V', 'B', 'N', 'M'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.nightSurface
            : const Color(0xFFF1F5F9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRow(row1),
            const SizedBox(height: 6),
            _buildRow(row2),
            const SizedBox(height: 6),
            _buildRow3(),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.map((key) => _buildKey(key)).toList(),
    );
  }

  Widget _buildRow3() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (onPencilToggle != null) ...[
          _buildActionButton(
            icon: Icons.edit,
            isActive: isPencilMode,
            onTap: onPencilToggle!,
            tooltip: 'Toggle Pencil Mode',
          ),
          const SizedBox(width: 4),
        ],
        ...row3.map((key) => _buildKey(key)),
        const SizedBox(width: 4),
        _buildActionButton(
          icon: Icons.backspace_outlined,
          isActive: false,
          onTap: onBackspace,
          tooltip: 'Backspace',
        ),
      ],
    );
  }

  Widget _buildKey(String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onKeyPressed(label),
            borderRadius: BorderRadius.circular(8.0),
            child: Ink(
              height: 48, // 48dp minimum touch target
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.black12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 1.5),
                    blurRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return SizedBox(
      width: 46,
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.0),
          child: Ink(
            decoration: BoxDecoration(
              color: isActive ? AppColors.yellow : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: isActive ? AppColors.primary : Colors.black12,
                width: isActive ? 1.5 : 1.0,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 20,
                color: isActive ? AppColors.ink : Colors.black54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
