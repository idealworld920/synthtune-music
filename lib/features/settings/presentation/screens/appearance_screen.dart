import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/app_settings_provider.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeModeProvider);
    final font = ref.watch(appFontProvider);
    final sheet = ref.watch(sheetStyleProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('테마 및 스타일')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── 테마 ───
          _SectionTitle('앱 테마'),
          const SizedBox(height: 12),
          Row(
            children: AppThemeMode.values.map((t) {
              final isSelected = theme == t;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    ref.read(appThemeModeProvider.notifier).state = t;
                    AppSettingsService.saveTheme(t);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: t.previewColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: t.previewColor,
                            border: Border.all(color: Colors.white24),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t.label.split(' ').first,
                          style: TextStyle(
                            color: isSelected ? AppColors.primary : Colors.white70,
                            fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),

          // ─── 글꼴 ───
          _SectionTitle('글꼴'),
          const SizedBox(height: 12),
          ...AppFont.values.map((f) {
            final isSelected = font == f;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  ref.read(appFontProvider.notifier).state = f;
                  AppSettingsService.saveFont(f);
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.bgSurface, width: isSelected ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary, size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(f.label, style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontFamily: f.fontFamily,
                            )),
                            Text(
                              '가나다라마바사 ABCDEFG 1234567',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontFamily: f.fontFamily),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 28),

          // ─── 악보 스타일 ───
          _SectionTitle('악보 스타일'),
          const SizedBox(height: 12),
          ...SheetStyle.values.map((s) {
            final isSelected = sheet == s;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  ref.read(sheetStyleProvider.notifier).state = s;
                  AppSettingsService.saveSheetStyle(s);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('악보 스타일이 "${s.label}"로 변경되었습니다.'), duration: const Duration(seconds: 1)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? AppColors.accent : AppColors.bgSurface, width: isSelected ? 2 : 1),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                        color: isSelected ? AppColors.accent : AppColors.textSecondary, size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.label, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                            Text(s.description, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: const TextStyle(
      color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700,
    ));
  }
}
