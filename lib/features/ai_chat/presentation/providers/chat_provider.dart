import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final String? mediaType;

  ChatMessage({required this.text, required this.isUser, DateTime? time, this.mediaType})
      : time = time ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'time': time.toIso8601String(),
    'mediaType': mediaType,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'] as String,
    isUser: json['isUser'] as bool,
    time: DateTime.parse(json['time'] as String),
    mediaType: json['mediaType'] as String?,
  );
}

// ─── 말투 설정 ───
enum ChatTone {
  friendly,  // 친근한 반말
  polite,    // 존댓말
  teacher,   // 선생님 말투
  casual,    // 캐주얼
}

extension ChatToneExt on ChatTone {
  String get label {
    switch (this) {
      case ChatTone.friendly: return '친근한 반말';
      case ChatTone.polite: return '존댓말';
      case ChatTone.teacher: return '선생님';
      case ChatTone.casual: return '캐주얼';
    }
  }

  String get emoji {
    switch (this) {
      case ChatTone.friendly: return '😊';
      case ChatTone.polite: return '🤝';
      case ChatTone.teacher: return '👨‍🏫';
      case ChatTone.casual: return '😎';
    }
  }
}

// ─── Providers ───
final chatToneProvider = StateProvider<ChatTone>((ref) => ChatTone.polite);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  static const _storageKey = 'chat_messages';
  static const _retentionKey = 'chat_retention_days';
  static const _toneKey = 'chat_tone';

  ChatNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final retentionDays = prefs.getInt(_retentionKey) ?? 30;
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr != null) {
      final list = (jsonDecode(jsonStr) as List)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
      final cutoff = DateTime.now().subtract(Duration(days: retentionDays));
      final filtered = list.where((m) => m.time.isAfter(cutoff)).toList();
      state = filtered.isEmpty ? [_welcomeMessage()] : filtered;
      if (filtered.length != list.length) await _save();
    } else {
      state = [_welcomeMessage()];
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.map((m) => m.toJson()).toList()));
  }

  void addMessage(ChatMessage msg) {
    state = [...state, msg];
    _save();
  }

  void deleteMessage(int index) {
    final updated = [...state];
    if (index >= 0 && index < updated.length) {
      updated.removeAt(index);
      state = updated;
      _save();
    }
  }

  void clearAll() {
    state = [_welcomeMessage()];
    _save();
  }

  Future<void> setRetentionDays(int days) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_retentionKey, days);
    final cutoff = DateTime.now().subtract(Duration(days: days));
    state = state.where((m) => m.time.isAfter(cutoff)).toList();
    if (state.isEmpty) state = [_welcomeMessage()];
    _save();
  }

  Future<int> getRetentionDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_retentionKey) ?? 30;
  }

  Future<void> setTone(ChatTone tone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_toneKey, tone.name);
  }

  Future<ChatTone> getTone() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_toneKey) ?? 'polite';
    return ChatTone.values.firstWhere((t) => t.name == name, orElse: () => ChatTone.polite);
  }

  /// 날짜별 그룹핑된 대화 내역
  Map<String, List<ChatMessage>> getGroupedByDate() {
    final grouped = <String, List<ChatMessage>>{};
    for (final msg in state) {
      final key = '${msg.time.year}-${msg.time.month.toString().padLeft(2, '0')}-${msg.time.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(msg);
    }
    return grouped;
  }

  static ChatMessage _welcomeMessage() => ChatMessage(
    text: '안녕하세요! AI 음악 선생님입니다. 연습, 악기, 음악 이론 등 무엇이든 질문해주세요.',
    isUser: false,
  );
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>(
  (ref) => ChatNotifier(),
);
