import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/subscription_tier.dart';
import '../providers/subscription_provider.dart';

// 인증된 학교 도메인 목록
const _validDomains = [
  '.ac.kr',   // 한국 대학교
  '.edu',     // 미국 대학교
  '.ac.jp',   // 일본 대학교
  '.ac.uk',   // 영국 대학교
  '.edu.au',  // 호주 대학교
];

bool _isStudentEmail(String email) {
  final lower = email.toLowerCase().trim();
  return _validDomains.any((d) => lower.endsWith(d));
}

class StudentVerificationScreen extends ConsumerStatefulWidget {
  const StudentVerificationScreen({super.key});

  @override
  ConsumerState<StudentVerificationScreen> createState() =>
      _StudentVerificationScreenState();
}

class _StudentVerificationScreenState
    extends ConsumerState<StudentVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isDone = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final email = _emailCtrl.text.trim().toLowerCase();
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid != null) {
        // Firestore에 인증 정보 저장
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'studentEmail': email,
          'studentVerified': true,
          'studentVerifiedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // 로컬 구독 티어를 student로 변경
      ref.read(subscriptionTierProvider.notifier).state = SubscriptionTier.student;

      if (mounted) setState(() { _isLoading = false; _isDone = true; });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: $e'),
          backgroundColor: AppColors.scoreMiss,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('학생 인증')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _isDone ? _SuccessView() : _FormView(
            formKey: _formKey,
            emailCtrl: _emailCtrl,
            isLoading: _isLoading,
            onVerify: _verify,
          ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool isLoading;
  final VoidCallback onVerify;

  const _FormView({
    required this.formKey,
    required this.emailCtrl,
    required this.isLoading,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.school_rounded, color: AppColors.accent, size: 32),
          ),
          const SizedBox(height: 20),
          Text(
            '학생 인증',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '학교 이메일로 인증하면 프리미엄 기능을\n₩4,900/월에 이용할 수 있습니다.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 32),

          // 지원 도메인 안내
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.accent, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '지원 이메일 도메인',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _validDomains.map((d) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '*$d',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                  )).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 이메일 입력
          TextFormField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: '학교 이메일',
              hintText: 'example@university.ac.kr',
              prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return '이메일을 입력해주세요';
              if (!v.contains('@')) return '올바른 이메일 형식이 아닙니다';
              if (!_isStudentEmail(v)) {
                return '지원되는 학교 이메일 도메인이 아닙니다\n(.ac.kr, .edu 등)';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),

          // 인증 버튼
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLoading ? null : onVerify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('인증하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),

          const SizedBox(height: 16),
          Text(
            '※ 허위 정보 입력 시 계정이 정지될 수 있습니다.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SuccessView extends ConsumerWidget {
  const _SuccessView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.scorePerfect.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, color: AppColors.scorePerfect, size: 44),
        ),
        const SizedBox(height: 24),
        Text(
          '학생 인증 완료!',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppColors.scorePerfect,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '학생 할인 요금(₩4,900/월)이 적용되었습니다.\n프리미엄 기능을 마음껏 사용하세요!',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.scorePerfect,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('확인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}
