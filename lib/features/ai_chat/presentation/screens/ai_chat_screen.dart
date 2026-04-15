import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/chat_provider.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isRecording = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();

    ref.read(chatProvider.notifier).addMessage(ChatMessage(text: text, isUser: true));
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      ref.read(chatProvider.notifier).addMessage(ChatMessage(text: _generateResponse(text), isUser: false));
      _scrollToBottom();
    });
  }

  void _attachMedia(String type) {
    final label = type == 'image' ? '사진' : type == 'video' ? '동영상' : '음성 메시지';
    ref.read(chatProvider.notifier).addMessage(ChatMessage(text: '[$label 첨부됨]', isUser: true, mediaType: type));
    _scrollToBottom();

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      final response = type == 'image'
          ? '사진을 확인했습니다. 손 모양이 잘 보이네요! 손가락을 좀 더 둥글게 세우면 더 좋은 소리가 날 거예요.'
          : type == 'video'
              ? '영상을 분석했습니다. 팔꿈치 위치가 좋습니다. 손목을 좀 더 자연스럽게 내려놓으면 연주가 편해질 거예요.'
              : '음성을 분석했습니다. 음정이 전반적으로 안정적이에요. A음 구간에서 살짝 플랫되는 경향이 있으니 참고하세요.';
      ref.read(chatProvider.notifier).addMessage(ChatMessage(text: response, isUser: false));
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSurface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _ChatSettingsSheet(ref: ref),
    );
  }

  void _confirmDeleteAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text('대화 내역 삭제'),
        content: const Text('모든 대화 내역을 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('취소', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(chatProvider.notifier).clearAll();
            },
            child: const Text('삭제', style: TextStyle(color: AppColors.scoreMiss)),
          ),
        ],
      ),
    );
  }

  String _generateResponse(String input) {
    final lower = input.toLowerCase();

    if (lower.contains('안녕') || lower.contains('하이') || lower.contains('hello') || lower.contains('hi')) {
      return '안녕하세요! 반갑습니다. 오늘은 어떤 연습을 해볼까요? 궁금한 점이 있으면 뭐든 물어보세요!';
    }
    if (lower.contains('고마워') || lower.contains('감사') || lower.contains('ㄱㅅ') || lower.contains('땡큐')) {
      return '별말씀을요! 도움이 되셨다면 기뻐요. 다른 궁금한 점이 있으면 언제든 물어보세요!';
    }
    if (lower.contains('잘가') || lower.contains('바이') || lower.contains('bye')) {
      return '오늘도 수고하셨어요! 꾸준히 연습하면 반드시 실력이 늘어요. 다음에 또 만나요!';
    }
    if (lower.contains('힘들') || lower.contains('어려') || lower.contains('못하') || lower.contains('안돼')) {
      return '누구나 처음엔 어렵게 느껴져요. 중요한 건 포기하지 않는 거예요! 어려운 부분을 알려주시면 더 구체적으로 도와드릴게요.';
    }
    if (lower.contains('재미') || lower.contains('좋아') || lower.contains('신나')) {
      return '음악이 재미있으시다니 정말 좋아요! 즐기면서 연습하는 게 실력 향상의 비결이에요.';
    }
    if (lower.contains('추천') || lower.contains('뭐 할') || lower.contains('뭐해') || lower.contains('시작')) {
      return '초보라면 "기본 스케일" 카테고리부터 시작하세요! 스케일로 기초를 다진 후 "동요"로 간단한 곡을 연주하고, 자신감이 붙으면 "클래식"에 도전해보세요.';
    }
    if (lower.contains('피아노') || lower.contains('건반')) {
      return '피아노는 손가락 독립성이 중요합니다. 매일 하논이나 체르니 연습곡으로 기초를 다지세요. 특히 4번, 5번 손가락 강화에 집중하면 좋습니다.';
    }
    if (lower.contains('기타') || lower.contains('코드')) {
      return '기타 초보라면 Am, C, G, D 4개 코드부터 시작하세요. 이 4개만으로도 수많은 곡을 연주할 수 있습니다.';
    }
    if (lower.contains('바이올린') || lower.contains('보잉')) {
      return '바이올린은 보잉이 가장 중요합니다. 활의 무게를 이용해 현을 누르세요. 거울 앞에서 활의 각도를 확인하며 연습해보세요.';
    }
    if (lower.contains('드럼') || lower.contains('리듬')) {
      return '드럼의 기본은 메트로놈과 함께 연습하는 것입니다. BPM 60부터 시작해서 싱글 스트로크를 정확하게 치는 연습을 하세요.';
    }
    if (lower.contains('음정') || lower.contains('튜닝')) {
      return '음정 연습의 핵심은 "듣기"입니다. 피아노나 튜너 앱으로 기준음을 틀어놓고 같은 음을 내는 연습을 하세요.';
    }
    if (lower.contains('악보') || lower.contains('읽')) {
      return '악보 읽기의 기초는 오선지(5선)와 음자리표를 아는 것입니다. 높은음자리표에서 선 위의 음은 아래부터 미-솔-시-레-파입니다.';
    }
    if (lower.contains('스케일') || lower.contains('음계')) {
      return '스케일은 모든 음악의 기초입니다. C장조부터 시작해서 G장조, D장조 순으로 연습하세요. 매일 5분씩만 해도 큰 차이가 나요!';
    }
    if (lower.contains('연습') || lower.contains('시간')) {
      return '하루 15-30분 꾸준한 연습이 가장 효과적입니다. 어려운 부분만 반복하는 "구간 연습"도 효과적입니다.';
    }
    return '궁금한 점이 있으시군요! 악기 이름(피아노, 기타 등)이나 연습 관련 키워드로 질문해주시면 더 구체적으로 도와드릴 수 있어요.';
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 20),
            SizedBox(width: 8),
            Text('AI 음악 선생님'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.textSecondary, size: 20),
            tooltip: '대화 설정',
            onPressed: _showSettings,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.textSecondary, size: 20),
            tooltip: '대화 내역 삭제',
            onPressed: _confirmDeleteAll,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: messages.length,
              itemBuilder: (context, i) => _MessageBubble(
                message: messages[i],
                onDelete: () => ref.read(chatProvider.notifier).deleteMessage(i),
              ),
            ),
          ),
          // 미디어 첨부 바
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                _AttachButton(icon: Icons.image_rounded, label: '사진', onTap: () => _attachMedia('image')),
                const SizedBox(width: 8),
                _AttachButton(icon: Icons.videocam_rounded, label: '동영상', onTap: () => _attachMedia('video')),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() => _isRecording = !_isRecording);
                    if (!_isRecording) _attachMedia('audio');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _isRecording ? AppColors.scoreMiss.withValues(alpha: 0.2) : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _isRecording ? AppColors.scoreMiss : AppColors.bgSurface),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                          size: 16,
                          color: _isRecording ? AppColors.scoreMiss : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isRecording ? '녹음 중' : '음성',
                          style: TextStyle(fontSize: 12, color: _isRecording ? AppColors.scoreMiss : AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 텍스트 입력
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
            decoration: const BoxDecoration(
              color: AppColors.bgSurface,
              border: Border(top: BorderSide(color: AppColors.bgCard)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        hintStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.bgCard,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 대화 설정 시트 ───
class _ChatSettingsSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _ChatSettingsSheet({required this.ref});

  @override
  ConsumerState<_ChatSettingsSheet> createState() => _ChatSettingsSheetState();
}

class _ChatSettingsSheetState extends ConsumerState<_ChatSettingsSheet> {
  int _selectedDays = 30;

  @override
  void initState() {
    super.initState();
    ref.read(chatProvider.notifier).getRetentionDays().then((d) {
      if (mounted) setState(() => _selectedDays = d);
    });
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      (7, '7일'),
      (14, '14일'),
      (30, '30일'),
      (90, '90일'),
      (365, '1년'),
      (36500, '무제한'),
    ];

    final msgCount = ref.watch(chatProvider).length;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '대화 설정',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '현재 저장된 대화: $msgCount개',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          const Text(
            '대화 저장 기간',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            '설정 기간이 지난 대화는 자동으로 삭제됩니다.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((opt) {
              final isSelected = _selectedDays == opt.$1;
              return ChoiceChip(
                label: Text(opt.$2, style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                )),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.bgCard,
                onSelected: (_) async {
                  setState(() => _selectedDays = opt.$1);
                  await ref.read(chatProvider.notifier).setRetentionDays(opt.$1);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('저장 기간이 ${opt.$2}로 변경되었습니다.'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── 위젯들 ───
class _AttachButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _AttachButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.bgSurface),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback onDelete;
  const _MessageBubble({required this.message, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onLongPress: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              backgroundColor: AppColors.bgCard,
              title: const Text('메시지 삭제'),
              content: const Text('이 메시지를 삭제하시겠습니까?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('취소', style: TextStyle(color: AppColors.textSecondary)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onDelete();
                  },
                  child: const Text('삭제', style: TextStyle(color: AppColors.scoreMiss)),
                ),
              ],
            ),
          );
        },
        child: Row(
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 16),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isUser ? AppColors.primary.withValues(alpha: 0.2) : AppColors.bgCard,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isUser ? 16 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 16),
                  ),
                  border: Border.all(color: isUser ? AppColors.primary.withValues(alpha: 0.3) : AppColors.bgSurface),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.mediaType != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          height: 80,
                          decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8)),
                          child: Center(
                            child: Icon(
                              message.mediaType == 'image' ? Icons.image_rounded
                                  : message.mediaType == 'video' ? Icons.play_circle_rounded
                                  : Icons.audio_file_rounded,
                              color: AppColors.textSecondary, size: 32,
                            ),
                          ),
                        ),
                      ),
                    Text(message.text, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.5)),
                    const SizedBox(height: 4),
                    Text(
                      '${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
            if (isUser) const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
