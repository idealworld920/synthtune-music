import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';

class ChatHistoryScreen extends ConsumerWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped = ref.watch(chatProvider.notifier).getGroupedByDate();
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a)); // 최신 순

    return Scaffold(
      appBar: AppBar(title: const Text('대화 내역')),
      body: dates.isEmpty
          ? Center(child: Text('저장된 대화가 없습니다.', style: TextStyle(color: AppColors.textSecondary)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dates.length,
              itemBuilder: (context, i) {
                final date = dates[i];
                final msgs = grouped[date]!;
                final userMsgs = msgs.where((m) => m.isUser).length;
                final aiMsgs = msgs.length - userMsgs;

                return Card(
                  color: AppColors.bgCard,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => _DayDetailScreen(date: date, messages: msgs)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 44, height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.chat_rounded, color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_formatDate(date), style: TextStyle(
                                  color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15,
                                )),
                                const SizedBox(height: 4),
                                Text(
                                  '내 메시지 $userMsgs개 · AI 답변 $aiMsgs개',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                ),
                                // 첫 사용자 메시지 미리보기
                                if (msgs.any((m) => m.isUser)) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    msgs.firstWhere((m) => m.isUser).text,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7), fontSize: 12),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _formatDate(String dateStr) {
    final parts = dateStr.split('-');
    final now = DateTime.now();
    final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    final diff = now.difference(date).inDays;
    if (diff == 0) return '오늘';
    if (diff == 1) return '어제';
    if (diff < 7) return '$diff일 전';
    return '${parts[1]}월 ${parts[2]}일';
  }
}

class _DayDetailScreen extends StatelessWidget {
  final String date;
  final List<ChatMessage> messages;
  const _DayDetailScreen({required this.date, required this.messages});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(date)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: messages.length,
        itemBuilder: (context, i) {
          final msg = messages[i];
          final isUser = msg.isUser;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isUser) ...[
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2), shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 14),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isUser ? AppColors.primary.withValues(alpha: 0.15) : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg.mediaType != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  msg.mediaType == 'image' ? Icons.image_rounded
                                      : msg.mediaType == 'video' ? Icons.videocam_rounded
                                      : Icons.mic_rounded,
                                  size: 14, color: AppColors.accent,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  msg.mediaType == 'image' ? '사진' : msg.mediaType == 'video' ? '동영상' : '음성',
                                  style: const TextStyle(color: AppColors.accent, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        Text(msg.text, style: TextStyle(color: AppColors.textPrimary, fontSize: 13, height: 1.4)),
                        const SizedBox(height: 3),
                        Text(
                          '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
