import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/welcome_onboarding_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/lesson/presentation/screens/lessons_screen.dart';
import '../../features/lesson/presentation/screens/lesson_detail_screen.dart';
import '../../features/practice/presentation/screens/practice_screen.dart';
import '../../features/ai_feedback/presentation/screens/feedback_result_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
import '../../features/community/presentation/screens/community_screen.dart';
import '../../features/training/presentation/screens/training_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/subscription/presentation/screens/subscription_screen.dart';
import '../../features/ai_chat/presentation/screens/ai_chat_screen.dart';
import '../../features/compose/presentation/screens/compose_screen.dart';
import '../../features/progress/presentation/screens/advanced_report_screen.dart';
import '../../features/subscription/presentation/screens/student_verification_screen.dart';
import '../../shared/widgets/bottom_nav_shell.dart';
import 'route_names.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final path = state.uri.path;

      if (path == RouteNames.splash) return null;

      final authRoutes = [
        RouteNames.login,
        RouteNames.register,
        RouteNames.onboarding,
      ];
      final isAuthRoute = authRoutes.any((r) => path.startsWith(r));

      if (!isLoggedIn && !isAuthRoute) return RouteNames.login;
      // 온보딩 중이면 리다이렉트 하지 않음
      if (path == RouteNames.onboarding) return null;
      if (isLoggedIn && isAuthRoute) return RouteNames.home;
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (_, __) => const WelcomeOnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => BottomNavShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (_, __) => const HomeScreen(),
          ),
          GoRoute(
            path: RouteNames.lessons,
            builder: (_, __) => const LessonsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) => LessonDetailScreen(
                  lessonId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/practice/:lessonId',
            builder: (context, state) => PracticeScreen(
              lessonId: state.pathParameters['lessonId']!,
            ),
          ),
          GoRoute(
            path: RouteNames.feedback,
            builder: (context, state) => FeedbackResultScreen(
              extra: state.extra as Map<String, dynamic>?,
            ),
          ),
          GoRoute(
            path: RouteNames.progress,
            builder: (_, __) => const ProgressScreen(),
          ),
          GoRoute(
            path: RouteNames.training,
            builder: (_, __) => const TrainingScreen(),
          ),
          GoRoute(
            path: RouteNames.community,
            builder: (_, __) => const CommunityScreen(),
          ),
          GoRoute(
            path: RouteNames.aiChat,
            builder: (_, __) => const AiChatScreen(),
          ),
          GoRoute(
            path: RouteNames.settings,
            builder: (_, __) => const SettingsScreen(),
          ),
          GoRoute(
            path: RouteNames.subscription,
            builder: (_, __) => const SubscriptionScreen(),
          ),
          GoRoute(
            path: RouteNames.studentVerification,
            builder: (_, __) => const StudentVerificationScreen(),
          ),
          GoRoute(
            path: RouteNames.compose,
            builder: (_, __) => const ComposeScreen(),
          ),
          GoRoute(
            path: RouteNames.advancedReport,
            builder: (_, __) => const AdvancedReportScreen(),
          ),
        ],
      ),
    ],
  );
}
