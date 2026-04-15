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
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/services/ai_voice_service.dart';
import 'appearance_screen.dart';
import 'language_screen.dart';
import 'profile_screen.dart';

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

          // 프로필 섹션
          _SectionHeader(title: '프로필'),
          _SettingsTile(
            icon: Icons.person_rounded,
            iconColor: AppColors.primary,
            title: '프로필 설정',
            subtitle: '사진, 닉네임, 비밀번호 변경',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),

          // 언어 섹션
          _SectionHeader(title: '언어'),
          _SettingsTile(
            icon: Icons.language_rounded,
            iconColor: AppColors.primary,
            title: '앱 언어',
            subtitle: '15개국 언어 지원',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LanguageScreen())),
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

          // AI 음성 섹션
          _SectionHeader(title: 'AI 음성'),
          _SettingsTile(
            icon: Icons.record_voice_over_rounded,
            iconColor: AppColors.accent,
            title: 'AI 음성 설정',
            subtitle: '음성 스타일, 언어, 켜기/끄기',
            onTap: () => _showVoiceSettings(context),
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

  void _showVoiceSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          var enabled = AiVoiceService.isEnabled;
          var style = AiVoiceService.currentStyle;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI 음성 설정', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // 켜기/끄기
                  SwitchListTile(
                    title: Text('AI 음성 피드백', style: TextStyle(color: AppColors.textPrimary)),
                    subtitle: Text('연습 중 실시간 음성 안내', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    value: enabled,
                    activeColor: AppColors.accent,
                    onChanged: (v) { setSheetState(() => enabled = v); AiVoiceService.setEnabled(v); },
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 16),

                  // 성별 선택
                  Text('음성 성별', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    children: VoiceGender.values.map((g) {
                      final isSel = AiVoiceService.currentGender == g;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: g == VoiceGender.female ? 8 : 0),
                          child: ChoiceChip(
                            avatar: Icon(g == VoiceGender.female ? Icons.female_rounded : Icons.male_rounded, size: 18, color: isSel ? Colors.white : AppColors.textSecondary),
                            label: Text(g.label, style: TextStyle(fontSize: 13, color: isSel ? Colors.white : AppColors.textSecondary)),
                            selected: isSel,
                            selectedColor: AppColors.primary,
                            backgroundColor: AppColors.bgCard,
                            onSelected: (_) {
                              AiVoiceService.setGender(g);
                              setSheetState(() {});
                              AiVoiceService.speak('안녕하세요, ${g.label} 음성입니다.');
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // 음성 스타일
                  Text('음성 스타일', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: VoiceStyle.values.map((s) {
                      final isSelected = style == s;
                      return ChoiceChip(
                        label: Text(s.label, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : AppColors.textSecondary)),
                        selected: isSelected,
                        selectedColor: AppColors.accent,
                        backgroundColor: AppColors.bgCard,
                        onSelected: (_) {
                          setSheetState(() => style = s);
                          AiVoiceService.setStyle(s);
                          AiVoiceService.speak('안녕하세요, ${s.label} 스타일입니다.');
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // 테스트 버튼
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => AiVoiceService.speak('좋아요, 음정이 정확합니다. 이 조자로 계속해보세요.'),
                      icon: Icon(Icons.play_arrow_rounded),
                      label: const Text('음성 테스트'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: BorderSide(color: AppColors.accent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: AppColors.accentGold, size: 18),
                          const SizedBox(width: 8),
                          Text('구독 해지 필요', style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('현재 ${tier.name} 구독 중입니다.\n탈퇴 전에 Google Play에서 구독을 해지해주세요.\n해지 후 남은 기간에 대해 환불 요청이 가능합니다.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final uri = Uri.parse('https://play.google.com/store/account/subscriptions');
                            if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
                          },
                          icon: Icon(Icons.open_in_new_rounded, size: 16),
                          label: const Text('Google Play 구독 관리'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accentGold,
                            side: BorderSide(color: AppColors.accentGold),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
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
