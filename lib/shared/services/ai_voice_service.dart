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
}

enum VoiceGender { female, male }

extension VoiceGenderExt on VoiceGender {
  String get label => this == VoiceGender.female ? '여성' : '남성';
}

class AiVoiceService {
  static final _tts = FlutterTts();
  static VoiceStyle _style = VoiceStyle.calm;
  static VoiceGender _gender = VoiceGender.female;
  static bool _enabled = true;
  static String _language = 'ko-KR';

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final styleName = prefs.getString('voice_style') ?? 'calm';
    _style = VoiceStyle.values.firstWhere((s) => s.name == styleName, orElse: () => VoiceStyle.calm);
    _enabled = prefs.getBool('voice_enabled') ?? true;
    _language = prefs.getString('voice_language') ?? 'ko-KR';
    final genderName = prefs.getString('voice_gender') ?? 'female';
    _gender = genderName == 'male' ? VoiceGender.male : VoiceGender.female;

    await _applySettings();
  }

  static Future<void> _applySettings() async {
    await _tts.setLanguage(_language);
    await _tts.setVolume(0.85);

    // 자연스러운 음성 설정
    double rate, pitch;
    switch (_style) {
      case VoiceStyle.calm:
        rate = 0.45; pitch = _gender == VoiceGender.female ? 1.05 : 0.85;
      case VoiceStyle.energetic:
        rate = 0.55; pitch = _gender == VoiceGender.female ? 1.15 : 0.95;
      case VoiceStyle.teacher:
        rate = 0.48; pitch = _gender == VoiceGender.female ? 1.0 : 0.9;
      case VoiceStyle.friendly:
        rate = 0.5; pitch = _gender == VoiceGender.female ? 1.1 : 0.9;
    }
    await _tts.setSpeechRate(rate);
    await _tts.setPitch(pitch);

    // 성별에 맞는 음성 선택 시도
    try {
      final voices = await _tts.getVoices;
      if (voices is List) {
        final voiceList = voices.cast<Map>();
        final targetGender = _gender == VoiceGender.female ? 'female' : 'male';

        // 언어+성별 매칭 음성 찾기
        final matched = voiceList.where((v) {
          final name = (v['name'] ?? '').toString().toLowerCase();
          final locale = (v['locale'] ?? '').toString().toLowerCase();
          final langMatch = locale.startsWith(_language.split('-').first.toLowerCase());
          final genderMatch = name.contains(targetGender) || name.contains(targetGender[0]);
          return langMatch && genderMatch;
        }).toList();

        if (matched.isNotEmpty) {
          await _tts.setVoice({'name': matched.first['name'], 'locale': matched.first['locale']});
        }
      }
    } catch (_) {}
  }

  static Future<void> speak(String text) async {
    if (!_enabled || text.isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  static Future<void> stop() async => await _tts.stop();

  static Future<void> setStyle(VoiceStyle style) async {
    _style = style;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('voice_style', style.name);
    await _applySettings();
  }

  static Future<void> setGender(VoiceGender gender) async {
    _gender = gender;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('voice_gender', gender.name);
    await _applySettings();
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
    await _applySettings();
  }

  static bool get isEnabled => _enabled;
  static VoiceStyle get currentStyle => _style;
  static VoiceGender get currentGender => _gender;
  static String get currentLanguage => _language;

  static String getFeedbackMessage(double accuracy, String noteName) {
    if (accuracy >= 0.9) return '좋아요!';
    if (accuracy >= 0.7) return '$noteName 조금 더 정확하게';
    if (accuracy >= 0.5) return '$noteName 음을 확인하세요';
    return '$noteName 다시 해보세요';
  }
}
