import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_names.dart';

class BottomNavShell extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note_rounded), label: '레슨'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center_rounded), label: '연습'),
          BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: '커뮤니티'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_rounded), label: 'AI'),
        ],
      ),
    );
  }
}
