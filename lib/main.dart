// lib/main.dart
import 'package:flutter/material.dart';
import 'services/game_storage.dart';
import 'ui/theme.dart';
import 'ui/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  GameStorage().init();
  runApp(const CineCrossApp());
}

class CineCrossApp extends StatefulWidget {
  const CineCrossApp({super.key});

  @override
  State<CineCrossApp> createState() => _CineCrossAppState();
}

class _CineCrossAppState extends State<CineCrossApp> {
  final storage = GameStorage();

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anime and Movies Crossword',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: storage.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: HomeScreen(onThemeChanged: _onThemeChanged),
    );
  }
}
