import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/premium_provider.dart';

class PremiumUpgradeScreen extends ConsumerWidget {
  const PremiumUpgradeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              elevation: 4,
              margin: EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Features',
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    FeatureItem(
                      icon: Icons.dashboard,
                      title: 'Unlimited Boards',
                      description: 'Create as many boards as you need',
                    ),
                    SizedBox(height: 8),
                    FeatureItem(
                      icon: Icons.high_quality,
                      title: 'High Quality Export',
                      description: 'Export your boards in high resolution',
                    ),
                    SizedBox(height: 8),
                    FeatureItem(
                      icon: Icons.brush,
                      title: 'Advanced Drawing Tools',
                      description: 'Access to more shapes and brushes',
                    ),
                  ],
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                // Activate premium (in a real app, this would handle payment)
                await ref.read(isPremiumProvider.notifier).setPremiumStatus(true);
                
                // Set expiry date to 1 year from now
                final expiryDate = DateTime.now().add(const Duration(days: 365));
                await ref.read(isPremiumProvider.notifier).setPremiumExpiryDate(expiryDate);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Premium features activated!')),
                );
                
                Navigator.pop(context);
              },
              icon: const Icon(Icons.star),
              label: const Text('Upgrade Now'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Maybe Later'),
            ),
          ],
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  
  const FeatureItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                description,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
