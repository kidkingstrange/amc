// test/widget/keyboard_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinecross/ui/widgets/keyboard_widget.dart';

void main() {
  testWidgets('Keyboard renders keys and triggers letter tap callback', (tester) async {
    String pressedKey = '';
    bool backspacePressed = false;
    bool pencilToggled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InAppKeyboardWidget(
            onKeyPressed: (key) => pressedKey = key,
            onBackspace: () => backspacePressed = true,
            onPencilToggle: () => pencilToggled = true,
            isPencilMode: false,
          ),
        ),
      ),
    );

    // Verify 'A' key exists and tapping it fires callback
    final keyA = find.text('A');
    expect(keyA, findsOneWidget);
    await tester.tap(keyA);
    expect(pressedKey, 'A');

    // Verify backspace button
    final backspaceIcon = find.byIcon(Icons.backspace_outlined);
    expect(backspaceIcon, findsOneWidget);
    await tester.tap(backspaceIcon);
    expect(backspacePressed, isTrue);

    // Verify pencil button
    final editIcon = find.byIcon(Icons.edit);
    expect(editIcon, findsOneWidget);
    await tester.tap(editIcon);
    expect(pencilToggled, isTrue);
  });
}
