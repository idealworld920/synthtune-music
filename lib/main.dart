import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/providers/app_settings_provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  timeago.setLocaleMessages('ko', timeago.KoMessages());
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  ThemeData _getTheme(AppThemeMode mode, Brightness platformBrightness) {
    switch (mode) {
      case AppThemeMode.system:
        return platformBrightness == Brightness.dark ? AppTheme.dark : AppTheme.light;
      case AppThemeMode.dark:
        return AppTheme.dark;
      case AppThemeMode.light:
        return AppTheme.light;
      case AppThemeMode.midnight:
        return AppTheme.midnight;
      case AppThemeMode.forest:
        return AppTheme.forest;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final font = ref.watch(appFontProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);

    var theme = _getTheme(themeMode, platformBrightness);

    // 글꼴 적용
    if (font.fontFamily != null) {
      theme = theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: font.fontFamily),
      );
    }

    return MaterialApp.router(
      title: 'AI 음악 교육',
      theme: theme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
