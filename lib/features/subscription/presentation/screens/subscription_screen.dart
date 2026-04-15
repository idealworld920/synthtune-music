import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/subscription_tier.dart';
import '../providers/subscription_provider.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTier = ref.watch(subscriptionTierProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        backgroundColor: AppColors.bgSurface,
        elevation: 0,
        title: Text(
          '구독 플랜',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header description
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '나에게 맞는 플랜을 선택하여\nAI 음악 학습을 시작하세요',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13.5,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tier cards
            _TierCard(
              tier: SubscriptionTier.free,
              currentTier: currentTier,
            ),
            const SizedBox(height: 12),
            _TierCard(
              tier: SubscriptionTier.standard,
              currentTier: currentTier,
            ),
            const SizedBox(height: 12),
            _TierCard(
              tier: SubscriptionTier.premium,
              currentTier: currentTier,
            ),
            const SizedBox(height: 12),
            _TierCard(
              tier: SubscriptionTier.student,
              currentTier: currentTier,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _TierCard extends ConsumerWidget {
  const _TierCard({
    required this.tier,
    required this.currentTier,
  });

  final SubscriptionTier tier;
  final SubscriptionTier currentTier;

  Color get _borderColor {
    switch (tier) {
      case SubscriptionTier.free: return AppColors.textSecondary;
      case SubscriptionTier.standard: return AppColors.primary;
      case SubscriptionTier.premium: return AppColors.accentGold;
      case SubscriptionTier.student: return AppColors.accent;
    }
  }

  Color get _accentColor {
    switch (tier) {
      case SubscriptionTier.free: return AppColors.textSecondary;
      case SubscriptionTier.standard: return AppColors.primary;
      case SubscriptionTier.premium: return AppColors.accentGold;
      case SubscriptionTier.student: return AppColors.accent;
    }
  }

  IconData get _tierIcon {
    switch (tier) {
      case SubscriptionTier.free: return Icons.music_note_rounded;
      case SubscriptionTier.standard: return Icons.star_rounded;
      case SubscriptionTier.premium: return Icons.workspace_premium_rounded;
      case SubscriptionTier.student: return Icons.school_rounded;
    }
  }

  bool get _isSelected => tier == currentTier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        if (tier == SubscriptionTier.free) return;
        if (tier.isComingSoon) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${tier.name}은 출시 예정입니다. 업데이트를 기다려주세요!', style: TextStyle(color: AppColors.textPrimary)),
              backgroundColor: AppColors.bgCard,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          );
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('결제 기능 준비 중입니다', style: TextStyle(color: AppColors.textPrimary)),
            backgroundColor: AppColors.bgCard,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isSelected
                ? _borderColor
                : _borderColor.withValues(alpha: 0.25),
            width: _isSelected ? 2 : 1,
          ),
          boxShadow: _isSelected
              ? [
                  BoxShadow(
                    color: _borderColor.withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tier header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _tierIcon,
                      color: _accentColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tier.name,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _isSelected ? _accentColor : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tier.price,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: _isSelected
                                ? _accentColor.withValues(alpha: 0.85)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _accentColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      _isSelected ? '현재 플랜' : tier.description,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _accentColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Divider(
                color: _borderColor.withValues(alpha: _isSelected ? 0.3 : 0.15),
                height: 1,
              ),
              const SizedBox(height: 14),

              // Features list
              ...tier.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: _isSelected
                            ? _accentColor
                            : AppColors.accent.withValues(alpha: 0.5),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        feature,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: _isSelected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // CTA button for paid tiers
              if (tier != SubscriptionTier.free) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: tier.isComingSoon ? null : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('결제 기능 준비 중입니다', style: TextStyle(color: AppColors.textPrimary)),
                          backgroundColor: AppColors.bgCard,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tier.isComingSoon
                          ? AppColors.textSecondary.withValues(alpha: 0.3)
                          : _isSelected ? _accentColor.withValues(alpha: 0.2) : _accentColor,
                      foregroundColor: tier.isComingSoon
                          ? AppColors.textSecondary
                          : _isSelected ? _accentColor : AppColors.bgDark,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: _isSelected ? BorderSide(color: _accentColor, width: 1) : BorderSide.none,
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (tier.isComingSoon) Icon(Icons.lock_rounded, size: 16),
                        if (tier.isComingSoon) const SizedBox(width: 6),
                        Text(
                          _isSelected ? '현재 플랜 이용 중'
                              : tier.isComingSoon ? '출시 예정'
                              : '업그레이드',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
