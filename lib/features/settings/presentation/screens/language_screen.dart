import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_colors.dart';

final appLanguageProvider = StateProvider<String>((ref) => 'ko');

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  String? _pendingLang;

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
  Widget build(BuildContext context) {
    final current = ref.watch(appLanguageProvider);
    final selected = _pendingLang ?? current;

    return Scaffold(
      appBar: AppBar(title: const Text('언어 설정')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: languages.length,
              itemBuilder: (context, i) {
                final lang = languages[i];
                final isSelected = selected == lang.$1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: ListTile(
                    leading: Text(lang.$3, style: const TextStyle(fontSize: 24)),
                    title: Text(lang.$2, style: TextStyle(color: AppColors.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    trailing: isSelected ? Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                    tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.1) : AppColors.bgCard,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onTap: () => setState(() => _pendingLang = lang.$1),
                  ),
                );
              },
            ),
          ),
          if (_pendingLang != null && _pendingLang != current)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveAndRestart,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Text(
                    '${languages.firstWhere((l) => l.$1 == _pendingLang).$2}로 변경 및 재시작',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _saveAndRestart() async {
    final lang = _pendingLang!;

    // SharedPreferences에 저장
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', lang);

    // Provider 업데이트
    ref.read(appLanguageProvider.notifier).state = lang;

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: Text('언어 변경 완료', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('앱을 재시작하여 변경사항을 적용합니다.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              SystemNavigator.pop();
            },
            child: Text('재시작', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
