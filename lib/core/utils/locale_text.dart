import 'package:flutter/widgets.dart';

/// Returns [en] if the current locale is English, otherwise [ko].
///
/// Usage:
/// ```dart
/// localeText(context, ko: '다음', en: 'Next')
/// ```
String localeText(BuildContext context, {required String ko, required String en}) {
  final lang = Localizations.localeOf(context).languageCode;
  return lang == 'en' ? en : ko;
}
