import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/theme.dart';
import '../providers/premium_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Theme settings
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text('Theme'),
            subtitle: const Text('Light, Dark, or System'),
            trailing: DropdownButton<ThemeMode>(
              value: Theme.of(context).brightness == Brightness.dark 
                  ? ThemeMode.dark 
                  : ThemeMode.light,
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
              ],
              onChanged: (ThemeMode? newValue) {
                // TODO: Implement theme switching
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme switching coming in future update')),
                );
              },
            ),
          ),
          
          const Divider(),
          
          // Premium status
          ListTile(
            leading: const Icon(Icons.star),
            title: const Text('Premium Status'),
            subtitle: Text(isPremium ? 'Active' : 'Free Version'),
            trailing: isPremium 
              ? const Icon(Icons.check_circle, color: Colors.green)
              : TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to the board list screen
                    // The upgrade button will be visible there
                  },
                  child: const Text('Upgrade'),
                ),
          ),
          
          const Divider(),
          
          // About section
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'WhiteboardMemo',
                applicationVersion: '1.0.0',
                applicationIcon: const FlutterLogo(size: 50),
                children: [
                  const Text('A digital whiteboard for your ideas and notes.'),
                ],
              );
            },
          ),
          
          // Privacy policy
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            onTap: () {
              // Show privacy policy
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Privacy Policy'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'WhiteboardMemo respects your privacy. '
                      'All your data is stored locally on your device and is not transmitted to any servers.',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
