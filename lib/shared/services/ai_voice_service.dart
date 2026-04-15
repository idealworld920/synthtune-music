import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum VoiceStyle { calm, energetic, teacher, friendly }

extension VoiceStyleExt on VoiceStyle {
  String get label {
    switch (this) {
      case VoiceStyle.calm: return '차분한';
      case VoiceStyle.energetic: return '활기찬';
      case VoiceStyle.teacher: return '선생님';
      case VoiceStyle.friendly: return '친근한';
    }
  }

  double get rate {
    switch (this) {
      case VoiceStyle.calm: return 0.4;
      case VoiceStyle.energetic: return 0.6;
      case VoiceStyle.teacher: return 0.45;
      case VoiceStyle.friendly: return 0.5;
    }
  }

  double get pitch {
    switch (this) {
      case VoiceStyle.calm: return 0.9;
      case VoiceStyle.energetic: return 1.2;
      case VoiceStyle.teacher: return 1.0;
      case VoiceStyle.friendly: return 1.1;
    }
  }
}

class AiVoiceService {
  static final _tts = FlutterTts();
  static VoiceStyle _style = VoiceStyle.calm;
  static bool _enabled = true;
  static String _language = 'ko-KR';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final styleName = prefs.getString('voice_style') ?? 'calm';
    _style = VoiceStyle.values.firstWhere((s) => s.name == styleName, orElse: () => VoiceStyle.calm);
    _enabled = prefs.getBool('voice_enabled') ?? true;
    _language = prefs.getString('voice_language') ?? 'ko-KR';

    await _tts.setLanguage(_language);
    await _tts.setSpeechRate(_style.rate);
    await _tts.setPitch(_style.pitch);
    await _tts.setVolume(0.8);
  }

  static Future<void> speak(String text) async {
    if (!_enabled) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  static Future<void> stop() async {
    await _tts.stop();
  }

  static Future<void> setStyle(VoiceStyle style) async {
    _style = style;
    await _tts.setSpeechRate(style.rate);
    await _tts.setPitch(style.pitch);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('voice_style', style.name);
  }

  static Future<void> setEnabled(bool enabled) async {
    _enabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('voice_enabled', enabled);
  }

  static Future<void> setLanguage(String lang) async {
    _language = lang;
    await _tts.setLanguage(lang);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('voice_language', lang);
  }

  static bool get isEnabled => _enabled;
  static VoiceStyle get currentStyle => _style;
  static String get currentLanguage => _language;

  // 연습 중 실시간 피드백 메시지
  static String getFeedbackMessage(double accuracy, String noteName) {
    if (accuracy >= 0.9) return '좋아요!';
    if (accuracy >= 0.7) return '$noteName 조금 더 정확하게';
    if (accuracy >= 0.5) return '$noteName 음을 확인하세요';
    return '$noteName 다시 해보세요';
  }

  static Future<List<String>> getAvailableLanguages() async {
    final langs = await _tts.getLanguages;
    return (langs as List).map((e) => e.toString()).toList();
  }
}
