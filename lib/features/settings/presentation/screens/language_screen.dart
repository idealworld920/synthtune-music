import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';

final appLanguageProvider = StateProvider<String>((ref) => 'ko');

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  static const languages = [
    ('ko', '한국어', '🇰🇷'),
    ('en', 'English', '🇺🇸'),
    ('ja', '日本語', '🇯🇵'),
    ('zh', '中文', '🇨🇳'),
    ('fr', 'Français', '🇫🇷'),
    ('pt', 'Português', '🇧🇷'),
    ('es', 'Español', '🇪🇸'),
    ('de', 'Deutsch', '🇩🇪'),
    ('it', 'Italiano', '🇮🇹'),
    ('ru', 'Русский', '🇷🇺'),
    ('vi', 'Tiếng Việt', '🇻🇳'),
    ('th', 'ภาษาไทย', '🇹🇭'),
    ('ar', 'العربية', '🇸🇦'),
    ('hi', 'हिन्दी', '🇮🇳'),
    ('id', 'Bahasa Indonesia', '🇮🇩'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(appLanguageProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('언어 설정')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: languages.length,
        itemBuilder: (context, i) {
          final lang = languages[i];
          final isSelected = current == lang.$1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: ListTile(
              leading: Text(lang.$3, style: const TextStyle(fontSize: 24)),
              title: Text(lang.$2, style: TextStyle(color: AppColors.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              trailing: isSelected ? Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
              tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.bgCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onTap: () async {
                ref.read(appLanguageProvider.notifier).state = lang.$1;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('app_language', lang.$1);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${lang.$2}로 변경되었습니다. 앱 재시작 시 적용됩니다.'), duration: const Duration(seconds: 2)),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
