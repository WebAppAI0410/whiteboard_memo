import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

// Premium status provider
final isPremiumProvider = StateNotifierProvider<PremiumNotifier, bool>((ref) {
  return PremiumNotifier();
});

class PremiumNotifier extends StateNotifier<bool> {
  PremiumNotifier() : super(false) {
    _loadPremiumStatus();
  }

  void _loadPremiumStatus() {
    state = StorageService.isPremiumUser();
  }

  Future<void> setPremiumStatus(bool isPremium) async {
    await StorageService.setPremiumStatus(isPremium);
    state = isPremium;
  }

  Future<void> setPremiumExpiryDate(DateTime expiryDate) async {
    await StorageService.setPremiumExpiryDate(expiryDate);
  }

  DateTime? getPremiumExpiryDate() {
    return StorageService.getPremiumExpiryDate();
  }

  bool isSubscriptionActive() {
    final expiryDate = getPremiumExpiryDate();
    if (expiryDate == null) return false;
    return expiryDate.isAfter(DateTime.now()) && state;
  }
}

// Premium features
enum PremiumFeature {
  unlimitedBoards,
  highResolutionExport,
  advancedShapes,
  cloudBackup,
  customThemes,
}

// Provider for checking if a specific premium feature is available
final premiumFeatureProvider = Provider.family<bool, PremiumFeature>((ref, feature) {
  final isPremium = ref.watch(isPremiumProvider);
  if (!isPremium) return false;
  
  final premiumNotifier = ref.read(isPremiumProvider.notifier);
  return premiumNotifier.isSubscriptionActive();
});

// Provider for the maximum number of boards allowed (limited for free users)
final maxBoardsProvider = Provider<int>((ref) {
  final isPremium = ref.watch(premiumFeatureProvider(PremiumFeature.unlimitedBoards));
  return isPremium ? 999 : 3; // Free users get 3 boards, premium users get unlimited
});
