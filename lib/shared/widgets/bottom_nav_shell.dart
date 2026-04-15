import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/route_names.dart';
import '../../features/subscription/presentation/providers/subscription_provider.dart';
import '../../l10n/app_localizations.dart';

class BottomNavShell extends ConsumerWidget {
  final Widget child;

  const BottomNavShell({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/lessons') || location.startsWith('/practice')) {
      return 1;
    } else if (location.startsWith(RouteNames.training)) {
      return 2;
    } else if (location.startsWith(RouteNames.community)) {
      return 3;
    } else if (location.startsWith(RouteNames.aiChat)) {
      return 4;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _locationToIndex(location);
    final showAds = ref.watch(showAdsProvider);

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: child),
          // 광고 배너 (무료 티어 - 모든 탭에 표시)
          if (showAds)
            Container(
              height: 50,
              color: AppColors.bgSurface,
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.4)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('AD', style: TextStyle(color: AppColors.textSecondary, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '광고 없이 연습하려면 스탠다드로 업그레이드',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(RouteNames.subscription),
                    style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 12)),
                    child: Text('제거', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go(RouteNames.home);
            case 1:
              context.go(RouteNames.lessons);
            case 2:
              context.go(RouteNames.training);
            case 3:
              context.go(RouteNames.community);
            case 4:
              context.go(RouteNames.aiChat);
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: AppLocalizations.of(context)?.home ?? '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note_rounded), label: AppLocalizations.of(context)?.lessons ?? '레슨'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center_rounded), label: AppLocalizations.of(context)?.practiceStart ?? '연습'),
          BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: AppLocalizations.of(context)?.community ?? '커뮤니티'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_rounded), label: AppLocalizations.of(context)?.ai ?? 'AI'),
        ],
      ),
    );
  }
}
