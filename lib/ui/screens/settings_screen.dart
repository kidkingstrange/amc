// lib/ui/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../../services/game_storage.dart';
import '../theme.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final storage = GameStorage();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & About', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
        children: [
          // Audio & Tactile Section
          const Text('PREFERENCES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Sound Effects', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Play chimes on word solved and level win'),
                  value: storage.soundEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => storage.soundEnabled = val);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Haptic Vibration', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Tactile feedback when tapping keys and solving'),
                  value: storage.hapticsEnabled,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => storage.hapticsEnabled = val);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Switch between Paper Light and Midnight Dark'),
                  value: storage.isDarkMode,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => storage.isDarkMode = val);
                    widget.onThemeChanged();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Privacy & Offline Quality Section
          const Text('DATA SAFETY & PRIVACY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, color: AppColors.mint, size: 28),
                      SizedBox(width: 12),
                      Text('100% Offline & Private', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This paid game contains zero ads, zero trackers, and zero analytics SDKs. No account or login is required. No personal data is ever collected or transmitted.',
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Mandatory Legal IP Disclaimer Section
          const Text('LEGAL DISCLAIMER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: isDark ? AppColors.nightSurface : const Color(0xFFF8FAFC),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Unofficial fan trivia game. Not affiliated with or endorsed by any studio, distributor, or rights holder. All titles, character names, and trademarks belong to their respective owners. Content used under nominative fair use for trivia verification purposes.',
                style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Reset Progress
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.coral,
              side: const BorderSide(color: AppColors.coral),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Reset All Progress?'),
                  content: const Text('This will clear your unlocked stars, streaks, and trivia collection.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral, foregroundColor: Colors.white),
                      onPressed: () {
                        setState(() => storage.resetAll());
                        Navigator.pop(ctx);
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Reset Saved Progress'),
          ),
        ],
      ),
      ),
    );
  }
}
