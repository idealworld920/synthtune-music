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

// 저장 기간 설정 (일 수)
final chatRetentionDaysProvider = StateProvider<int>((ref) => 30);

class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  static const _storageKey = 'chat_messages';
  static const _retentionKey = 'chat_retention_days';

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

      // 저장 기간 지난 메시지 필터링
      final cutoff = DateTime.now().subtract(Duration(days: retentionDays));
      final filtered = list.where((m) => m.time.isAfter(cutoff)).toList();

      if (filtered.isEmpty) {
        state = [_welcomeMessage()];
      } else {
        state = filtered;
      }
      // 필터링된 결과 저장
      if (filtered.length != list.length) await _save();
    } else {
      state = [_welcomeMessage()];
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(state.map((m) => m.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
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
    // 기존 메시지 중 기간 지난 것 정리
    final cutoff = DateTime.now().subtract(Duration(days: days));
    state = state.where((m) => m.time.isAfter(cutoff)).toList();
    if (state.isEmpty) state = [_welcomeMessage()];
    _save();
  }

  Future<int> getRetentionDays() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_retentionKey) ?? 30;
  }

  static ChatMessage _welcomeMessage() => ChatMessage(
    text: '안녕하세요! AI 음악 선생님입니다. 연습, 악기, 음악 이론 등 무엇이든 질문해주세요.',
    isUser: false,
  );
}

final chatProvider = StateNotifierProvider<ChatNotifier, List<ChatMessage>>(
  (ref) => ChatNotifier(),
);
