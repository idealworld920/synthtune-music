import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'l10n/app_localizations.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/presentation/providers/app_settings_provider.dart';
import 'features/settings/presentation/screens/language_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // AI 음성은 추후 업데이트에서 활성화
  // await AiVoiceService.init();
  timeago.setLocaleMessages('ko', timeago.KoMessages());

  // 저장된 언어 불러오기
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('app_language') ?? 'ko';

  runApp(ProviderScope(
    overrides: [
      appLanguageProvider.overrideWith((ref) => savedLang),
    ],
    child: const MyApp(),
  ));
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
    final langCode = ref.watch(appLanguageProvider);
    final platformBrightness = MediaQuery.platformBrightnessOf(context);

    var theme = _getTheme(themeMode, platformBrightness);

    if (font.fontFamily != null) {
      theme = theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: font.fontFamily),
      );
    }

    return MaterialApp.router(
      title: 'SynthTune Music',
      theme: theme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      locale: Locale(langCode),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'),
        Locale('en'),
      ],
    );
  }
}
