import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/user_profile_provider.dart';
import '../../../subscription/domain/subscription_tier.dart';
import '../../../subscription/presentation/providers/subscription_provider.dart';
import 'appearance_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider).valueOrNull;
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AsyncLoading;
    final photoUrl = firebaseUser?.photoURL;
    final tier = ref.watch(subscriptionTierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        children: [
          // 프로필 섹션
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                  child: photoUrl == null
                      ? Text(
                          (profile?.displayName ?? firebaseUser?.displayName ?? '?')[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile?.displayName ?? firebaseUser?.displayName ?? '사용자',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile?.email ?? firebaseUser?.email ?? '',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 구독 섹션
          _SectionHeader(title: '구독'),
          _SettingsTile(
            icon: Icons.workspace_premium_rounded,
            iconColor: tier == SubscriptionTier.free ? AppColors.textSecondary : AppColors.accentGold,
            title: '현재 플랜: ${tier.name}',
            subtitle: tier.price,
            onTap: () => context.push(RouteNames.subscription),
          ),

          // 외관 섹션
          _SectionHeader(title: '외관'),
          _SettingsTile(
            icon: Icons.palette_rounded,
            iconColor: AppColors.accent,
            title: '테마 및 스타일',
            subtitle: '앱 테마, 글꼴, 악보 스타일',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppearanceScreen())),
          ),

          // 계정 섹션
          _SectionHeader(title: '계정'),
          _SettingsTile(
            icon: Icons.logout_rounded,
            iconColor: AppColors.textSecondary,
            title: '로그아웃',
            onTap: isLoading ? null : _confirmSignOut,
          ),
          _SettingsTile(
            icon: Icons.person_remove_rounded,
            iconColor: AppColors.scoreMiss,
            title: '회원탈퇴',
            titleColor: AppColors.scoreMiss,
            onTap: isLoading ? null : _confirmDelete,
          ),

          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?\n다시 로그인하면 데이터가 유지됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('취소', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authNotifierProvider.notifier).signOut();
              if (mounted) context.go(RouteNames.login);
            },
            child: Text('로그아웃', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete() {
    final reasonCtrl = TextEditingController();
    final tier = ref.read(subscriptionTierProvider);
    final isSubscribed = tier != SubscriptionTier.free;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 안내문
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.scoreMiss, size: 24),
                  const SizedBox(width: 8),
                  Text('회원탈퇴', style: TextStyle(color: AppColors.scoreMiss, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.scoreMiss.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(
                  '탈퇴하면 다음 데이터가 영구적으로 삭제됩니다:\n\n• 모든 학습 기록 및 진행도\n• 커뮤니티 게시글 및 댓글\n• AI 대화 내역\n• 프로필 정보\n\n이 작업은 되돌릴 수 없습니다.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
                ),
              ),
              const SizedBox(height: 20),

              // 2. 탈퇴 사유
              Text('탈퇴 사유 (선택)', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: reasonCtrl,
                maxLines: 2,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: '더 나은 서비스를 위해 이유를 알려주세요',
                  hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  filled: true, fillColor: AppColors.bgCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              // 3. 구독 환불 안내
              if (isSubscribed)
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: AppColors.accentGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.3))),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.accentGold, size: 18),
                      const SizedBox(width: 10),
                      Expanded(child: Text('현재 ${tier.name} 구독 중입니다.\n탈퇴 시 남은 기간에 대해 Google Play를 통해 환불 요청할 수 있습니다.', style: TextStyle(color: AppColors.accentGold, fontSize: 12, height: 1.4))),
                    ],
                  ),
                ),

              // 4. 탈퇴 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await ref.read(authNotifierProvider.notifier).deleteAccount();
                    if (!mounted) return;
                    final state = ref.read(authNotifierProvider);
                    if (state is AsyncError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('탈퇴 실패: ${state.error}'), backgroundColor: AppColors.scoreMiss),
                      );
                    } else {
                      // 5. 마지막 인사
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (dCtx) => AlertDialog(
                          backgroundColor: AppColors.bgCard,
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('👋', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 16),
                              Text('그동안 감사했습니다', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('언제든 다시 오세요.\n음악은 항상 당신을 기다리고 있어요.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () { Navigator.of(dCtx).pop(); context.go(RouteNames.login); },
                              child: Text('안녕히 가세요', style: TextStyle(color: AppColors.primary)),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.scoreMiss, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: const Text('회원탈퇴', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text('취소', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!, style: TextStyle(color: AppColors.textSecondary, fontSize: 12))
          : null,
      trailing: Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
