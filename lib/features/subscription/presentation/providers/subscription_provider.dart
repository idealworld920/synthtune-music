import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/subscription_tier.dart';

final subscriptionTierProvider = StateProvider<SubscriptionTier>((ref) {
  return SubscriptionTier.free;
});

final showAdsProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionTierProvider) == SubscriptionTier.free;
});

final isStandardOrAboveProvider = Provider<bool>((ref) {
  return ref.watch(subscriptionTierProvider) != SubscriptionTier.free;
});
