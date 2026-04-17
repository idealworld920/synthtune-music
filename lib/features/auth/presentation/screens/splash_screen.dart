import '../../../../core/utils/locale_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _welcomeCtrl;
  late AnimationController _portalCtrl;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _welcomeFade;
  late Animation<double> _portalScale;
  bool _showWelcome = false;
  String _userName = '';

  @override
  void initState() {
    super.initState();

    // 로고 등장
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeIn);
    _logoScale = Tween(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));

    // 환영 메시지
    _welcomeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _welcomeFade = CurvedAnimation(parent: _welcomeCtrl, curve: Curves.easeIn);

    // 포탈 효과 (확대되며 사라짐)
    _portalCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _portalScale = Tween(begin: 1.0, end: 3.0).animate(CurvedAnimation(parent: _portalCtrl, curve: Curves.easeIn));

    _logoCtrl.forward();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      _showWelcomeAndEnter();
    });
  }

  void _showWelcomeAndEnter() {
    final authState = ref.read(authStateProvider);
    authState.when(
      data: (user) {
        if (user != null) {
          setState(() {
            _userName = user.displayName ?? '사용자';
            _showWelcome = true;
          });
          _welcomeCtrl.forward();

          // 환영 인사 후 포탈 효과 → 홈
          Future.delayed(const Duration(milliseconds: 1800), () {
            if (!mounted) return;
            _portalCtrl.forward().then((_) {
              if (mounted) context.go(RouteNames.home);
            });
          });
        } else {
          context.go(RouteNames.onboarding);
        }
      },
      loading: () {
        Future.delayed(const Duration(milliseconds: 500), _showWelcomeAndEnter);
      },
      error: (_, __) => context.go(RouteNames.onboarding),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _welcomeCtrl.dispose();
    _portalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: AnimatedBuilder(
        animation: _portalCtrl,
        builder: (_, __) => Opacity(
          opacity: _portalCtrl.isAnimating ? (1.0 - _portalCtrl.value / 3.0).clamp(0.0, 1.0) : 1.0,
          child: Transform.scale(
            scale: _portalScale.value,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 앱 이름
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Text(
                      'SynthTune Music',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  ),

                  const SizedBox(height: 32),

                  // 환영 인사 (로그인 상태일 때)
                  if (_showWelcome)
                    FadeTransition(
                      opacity: _welcomeFade,
                      child: Column(
                        children: [
                          Text(
                            '어서오세요',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$_userName님',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // 반짝이는 파티클 효과 (간단한 점)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(5, (i) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: _TwinkleDot(delay: i * 200),
                            )),
                          ),
                        ],
                      ),
                    )
                  else
                    const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 반짝이는 점 애니메이션
class _TwinkleDot extends StatefulWidget {
  final int delay;
  const _TwinkleDot({required this.delay});

  @override
  State<_TwinkleDot> createState() => _TwinkleDotState();
}

class _TwinkleDotState extends State<_TwinkleDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent.withValues(alpha: 0.3 + _ctrl.value * 0.7),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: _ctrl.value * 0.5),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}
