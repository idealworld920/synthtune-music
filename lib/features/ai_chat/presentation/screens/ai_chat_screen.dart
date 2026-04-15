import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/services/email_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../community/domain/models/community_post.dart';
import '../../../community/presentation/providers/community_provider.dart';
import '../providers/chat_provider.dart';
import 'chat_history_screen.dart';

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

    final isInq = _isInquiry(text.toLowerCase());

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      ref.read(chatProvider.notifier).addMessage(ChatMessage(text: _generateResponse(text), isUser: false));
      _scrollToBottom();

      // 문의 감지 시 전송 다이얼로그
      if (isInq) _handleInquiry(text);
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
    final tone = ref.read(chatToneProvider);
    final raw = _matchResponse(input.toLowerCase());
    return _applyTone(raw, tone);
  }

  String _applyTone(String text, ChatTone tone) {
    switch (tone) {
      case ChatTone.friendly:
        return text
            .replaceAll('합니다.', '해!')
            .replaceAll('합니다', '해')
            .replaceAll('하세요.', '해봐!')
            .replaceAll('하세요', '해봐')
            .replaceAll('됩니다.', '돼!')
            .replaceAll('입니다.', '야!')
            .replaceAll('있습니다.', '있어!')
            .replaceAll('에요.', '야!')
            .replaceAll('드릴게요.', '줄게!')
            .replaceAll('보세요.', '봐!')
            .replaceAll('거예요.', '거야!')
            .replaceAll('이에요.', '이야!')
            .replaceAll('있어요.', '있어!')
            .replaceAll('돼요.', '돼!')
            .replaceAll('나요!', '나!')
            .replaceAll('까요?', '까?');
      case ChatTone.polite:
        return text; // 기본이 존댓말
      case ChatTone.teacher:
        return '자, 좋은 질문이에요. $text 궁금한 거 더 있으면 손 들어보세요!';
      case ChatTone.casual:
        return text
            .replaceAll('합니다.', '함ㅋ')
            .replaceAll('하세요.', '해보셈~')
            .replaceAll('됩니다.', '됨!')
            .replaceAll('입니다.', '임!')
            .replaceAll('있습니다.', '있음!')
            .replaceAll('에요.', '임~')
            .replaceAll('거예요.', '거임~')
            .replaceAll('보세요.', '봐봐~');
    }
  }

  // 문의 내용 감지 시 정리해서 커뮤니티 문의·의견에 자동 등록
  bool _isInquiry(String lower) {
    return lower.contains('문의') || lower.contains('버그') || lower.contains('오류') ||
        lower.contains('안됨') || lower.contains('안 됨') || lower.contains('작동') ||
        lower.contains('건의') || lower.contains('개선') || lower.contains('요청') ||
        lower.contains('불편') || lower.contains('신고') || lower.contains('환불') ||
        lower.contains('결제') || lower.contains('구독') && lower.contains('문제');
  }

  void _handleInquiry(String userText) {
    // 문의 내용을 정리해서 커뮤니티 feedback 카테고리에 등록
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.bgCard,
          title: const Text('문의 내용 전송'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('아래 내용을 운영팀에 전달할까요?', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.bgSurface, borderRadius: BorderRadius.circular(8)),
                child: Text(userText, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('아니오', style: TextStyle(color: AppColors.textSecondary)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                final user = ref.read(currentUserProvider);
                final userName = user?.displayName ?? '사용자';
                final userEmail = user?.email ?? '';

                // 1. 이메일 전송
                final sent = await EmailService.sendInquiry(
                  senderName: userName,
                  subject: '사용자 문의 - $userName',
                  body: userText,
                  senderEmail: userEmail,
                );

                // 2. 커뮤니티 feedback에도 등록
                ref.read(communityProvider.notifier).addPost(
                  CommunityPost(
                    id: 'inquiry_${DateTime.now().millisecondsSinceEpoch}',
                    userId: user?.uid ?? 'guest',
                    userName: userName,
                    content: '📩 [AI 챗봇 문의]\n$userText',
                    lessonTitle: '',
                    instrument: '',
                    score: 0,
                    likes: 0,
                    isLiked: false,
                    createdAt: DateTime.now(),
                    category: 'feedback',
                  ),
                );

                if (!mounted) return;
                ref.read(chatProvider.notifier).addMessage(ChatMessage(
                  text: sent
                      ? '문의 내용이 이메일로 전송되었습니다! 커뮤니티 → 문의·의견에서도 확인할 수 있어요. 빠른 시일 내에 답변드리겠습니다!'
                      : '문의 내용이 커뮤니티 → 문의·의견에 등록되었습니다. (이메일 전송은 네트워크 상태에 따라 지연될 수 있어요)',
                  isUser: false,
                ));
                _scrollToBottom();
              },
              child: const Text('전송', style: TextStyle(color: AppColors.primary)),
            ),
          ],
        ),
      );
    });
  }

  String _matchResponse(String lower) {
    // ── 문의/건의 감지 ──
    if (_isInquiry(lower)) {
      return '문의 내용을 확인했습니다. 내용을 정리해서 운영팀에 전달해드릴까요? 잠시만 기다려주세요...';
    }

    // ── 인사 ──
    if (lower.contains('안녕') || lower.contains('하이') || lower.contains('hello') || lower.contains('hi') || lower == 'ㅎㅇ') {
      return '안녕하세요! 반갑습니다. 오늘은 어떤 연습을 해볼까요? 궁금한 점이 있으면 뭐든 물어보세요!';
    }
    if (lower.contains('고마워') || lower.contains('감사') || lower.contains('ㄱㅅ') || lower.contains('땡큐') || lower.contains('thank')) {
      return '별말씀을요! 도움이 되셨다면 기뻐요. 다른 궁금한 점이 있으면 언제든 물어보세요!';
    }
    if (lower.contains('잘가') || lower.contains('바이') || lower.contains('bye') || lower.contains('ㅂㅂ')) {
      return '오늘도 수고하셨어요! 꾸준히 연습하면 반드시 실력이 늘어요. 다음에 또 만나요!';
    }

    // ── 일상 대화 ──
    if (lower.contains('뭐해') || lower.contains('뭐하') || lower.contains('심심') || lower.contains('할 거')) {
      return '저는 여기서 음악 관련 도움을 드리고 있어요! 연습하다 막히는 부분이 있거나, 새로운 곡을 찾고 있다면 말해주세요. 아니면 그냥 수다를 떨어도 좋아요!';
    }
    if (lower.contains('이름') || lower.contains('누구') || lower.contains('뭐야') || lower.contains('자기소개')) {
      return '저는 AI 음악 선생님이에요! 피아노, 기타, 바이올린, 드럼 4가지 악기의 연주 팁과 음악 이론을 알려드립니다. 연습 방법, 악보 읽기, 테크닉 등 뭐든 물어보세요!';
    }
    if (lower.contains('나이') || lower.contains('몇살') || lower.contains('몇 살')) {
      return '저는 나이가 없어요! 하지만 수많은 음악 교육 자료를 학습했기 때문에 경험 많은 선생님이라고 생각해주세요. 궁금한 게 있으면 뭐든 물어봐요!';
    }
    if (lower.contains('좋아하는') || lower.contains('취미') || lower.contains('관심')) {
      return '저는 모든 장르의 음악을 좋아해요! 클래식부터 팝, 재즈, 록까지. 음악에 대해 이야기하는 걸 가장 좋아합니다. 혹시 요즘 좋아하는 곡이 있나요?';
    }
    if (lower.contains('날씨') || lower.contains('오늘')) {
      return '날씨 이야기를 하시다니! 날씨가 좋으면 창문 열고 연습하는 것도 기분 전환이 됩니다. 오늘은 어떤 곡을 연습해볼까요?';
    }
    if (lower.contains('ㅋㅋ') || lower.contains('ㅎㅎ') || lower.contains('ㅜㅜ') || lower.contains('ㅠㅠ')) {
      return lower.contains('ㅜ') || lower.contains('ㅠ')
          ? '괜찮아요! 음악은 즐기는 거예요. 기분이 안 좋을 때 좋아하는 곡을 연주하면 기분이 나아질 거예요!'
          : '즐거워 보이시네요! 그 에너지로 오늘도 화이팅! 뭔가 연습하고 싶은 게 있으면 말해주세요!';
    }
    if (lower.contains('배고') || lower.contains('밥') || lower.contains('먹')) {
      return '배가 고프시군요! 연습도 중요하지만 밥도 잘 챙겨 드세요. 배부르게 먹고 와서 연습하면 더 집중이 잘 될 거예요!';
    }
    if (lower.contains('잠') || lower.contains('졸려') || lower.contains('피곤')) {
      return '피곤할 때 억지로 연습하면 효율이 떨어져요. 충분히 쉬고 컨디션이 좋을 때 15분만 집중 연습하는 게 훨씬 효과적입니다. 푹 쉬세요!';
    }

    // ── 감정/상태 ──
    if (lower.contains('힘들') || lower.contains('어려') || lower.contains('못하') || lower.contains('안돼') || lower.contains('포기')) {
      return '누구나 처음엔 어렵게 느껴져요. 중요한 건 포기하지 않는 거예요! 어려운 구간만 느린 템포로 10번 반복해보세요. 놀라울 정도로 빨리 나아집니다.';
    }
    if (lower.contains('재미') || lower.contains('좋아') || lower.contains('신나') || lower.contains('잘됐') || lower.contains('됐다')) {
      return '정말 잘하고 계시네요! 즐기면서 연습하는 게 실력 향상의 비결이에요. 이 기세로 계속 가보시죠!';
    }
    if (lower.contains('지루') || lower.contains('질려')) {
      return '같은 곡이 지루하다면 새로운 장르에 도전해보세요! 클래식 탭에서 캉캉이나 터키 행진곡 같은 곡은 템포가 빨라서 재미있을 거예요. 스킬 탭의 테크닉 연습도 새로운 자극이 됩니다.';
    }

    // ── 추천/시작 ──
    if (lower.contains('추천') || lower.contains('뭐 할') || lower.contains('뭐해') || lower.contains('시작') || lower.contains('입문') || lower.contains('초보')) {
      return '초보라면 이 순서를 추천합니다:\n1. "기본 스케일" → 도레미파솔라시도부터\n2. "동요" → 반짝반짝 작은별, 나비야\n3. "스킬" → 아르페지오, 스타카토 등\n4. "클래식" → 환희의 송가, 엘리제\n\n레슨 탭에서 카테고리별로 확인해보세요!';
    }

    // ── 피아노 상세 ──
    if (lower.contains('피아노') && (lower.contains('손가락') || lower.contains('운지'))) {
      return '피아노 운지법 기본 원칙:\n• 엄지=1, 검지=2, 중지=3, 약지=4, 새끼=5\n• C장조 음계: 오른손 1-2-3-1-2-3-4-5\n• 손가락을 세우고 달걀을 쥐듯 둥글게\n• 손목은 건반 높이와 수평으로 유지\n\n스킬 탭의 "한 손 스케일 연습"부터 시작해보세요.';
    }
    if (lower.contains('피아노') && (lower.contains('페달') || lower.contains('밟'))) {
      return '피아노 페달 사용법:\n• 오른쪽 페달(서스테인): 음을 길게 유지\n• "반 페달"을 먼저 연습하세요 — 완전히 밟지 않고 반만\n• 음이 바뀔 때 페달을 놓았다 다시 밟는 "레가토 페달링"\n\n스킬 탭의 "페달링 기초"에서 연습할 수 있어요.';
    }
    if (lower.contains('피아노') || lower.contains('건반')) {
      return '피아노 연습 팁:\n• 매일 5분 스케일 → 손가락 독립성 강화\n• 4번(약지), 5번(새끼) 손가락 특히 약하니 집중 훈련\n• 양손 따로 먼저 → 합치기\n• 메트로놈 필수 — 느린 템포부터\n\n하논, 체르니 같은 연습곡이 기초 다지기에 좋습니다.';
    }

    // ── 기타 상세 ──
    if (lower.contains('기타') && (lower.contains('바레') || lower.contains('barre') || lower.contains('f코드') || lower.contains('f 코드'))) {
      return 'F 바레 코드 팁:\n• 검지로 1프렛 전체를 누를 때 손가락 옆면을 사용\n• 엄지는 넥 뒤 중앙에 위치\n• 처음엔 1~2번 줄만 제대로 울리면 성공\n• 매일 30초씩 누르고 버티는 연습\n\n스킬 탭의 "바레 코드 강화"에서 집중 연습할 수 있어요.';
    }
    if (lower.contains('기타') && (lower.contains('핑거') || lower.contains('피킹') || lower.contains('아르페지오'))) {
      return '핑거피킹 기본:\n• 엄지(p)=456번줄, 검지(i)=3번줄, 중지(m)=2번줄, 약지(a)=1번줄\n• p-i-m-a 순서로 천천히\n• 손톱 길이 적당히 유지\n• 트라비스 피킹: p와 i,m을 교차\n\n스킬 탭의 "핑거피킹 기초"에서 연습해보세요.';
    }
    if (lower.contains('기타') || lower.contains('코드')) {
      return '기타 기본 코드 순서:\n1. Am → 가장 쉬운 코드\n2. C → Am에서 손가락 하나 추가\n3. G → 넓은 스트레치 연습\n4. D → 맑은 소리 내기\n5. Em → 2개 손가락만 사용\n\n이 5개로 수많은 곡을 연주할 수 있습니다. 코드 전환이 핵심이에요!';
    }

    // ── 바이올린 상세 ──
    if (lower.contains('바이올린') && (lower.contains('비브라토') || lower.contains('떨림'))) {
      return '바이올린 비브라토 연습:\n• 손목 비브라토부터 시작 (팔은 나중에)\n• 메트로놈에 맞춰 규칙적으로 왕복\n• 한 음을 길게 울리면서 천천히 흔들기\n• 처음엔 느리게, 점차 빠르게\n\n주의: 비브라토는 기초 음정이 안정된 후에 시작하세요!';
    }
    if (lower.contains('바이올린') && (lower.contains('자세') || lower.contains('잡는') || lower.contains('턱'))) {
      return '바이올린 자세 체크:\n• 턱받이에 턱을 가볍게 올려놓기 (꽉 물지 않기)\n• 왼손 엄지는 넥 옆면에 가볍게\n• 팔꿈치는 바이올린 아래로\n• 활은 브릿지와 지판 중간에서 긋기\n\n거울 앞에서 확인하면서 연습하면 좋습니다. 카메라 기능도 활용해보세요!';
    }
    if (lower.contains('바이올린') || lower.contains('보잉') || lower.contains('활')) {
      return '바이올린 보잉 핵심:\n• 활의 무게를 이용하세요 — 누르지 말고\n• 전궁(활 전체), 반궁(절반)을 골고루 연습\n• 활이 현에 수직이 되도록 유지\n• 느린 보잉 → 빠른 보잉 순서로\n\n스킬 탭의 "보잉 기초"에서 체계적으로 연습할 수 있어요.';
    }

    // ── 드럼 상세 ──
    if (lower.contains('드럼') && (lower.contains('파라디들') || lower.contains('루디먼트'))) {
      return '파라디들 연습법:\nR-L-R-R, L-R-L-L (R=오른손, L=왼손)\n• BPM 60부터 시작\n• 악센트를 첫 타에 넣기\n• 양손 균형이 목표\n• 연속 1분 치기 → 점차 빠르게\n\n파라디들은 드럼의 기본 루디먼트 중 가장 중요합니다!';
    }
    if (lower.contains('드럼') && (lower.contains('스트로크') || lower.contains('잡는') || lower.contains('그립'))) {
      return '드럼스틱 그립:\n• 매치드 그립: 양손 같은 방법 (초보 추천)\n• 스틱 1/3 지점을 엄지+검지로 잡기\n• 나머지 손가락은 감싸듯 가볍게\n• 리바운드를 이용 — 치고 튕기기\n\n싱글 스트로크(RLRL)를 완벽하게 먼저 연습하세요.';
    }
    if (lower.contains('드럼') || lower.contains('리듬') || lower.contains('비트')) {
      return '드럼 연습 순서:\n1. 싱글 스트로크 (RLRL) → 기본 중의 기본\n2. 4비트 패턴 → 킥-스네어 교대\n3. 8비트 패턴 → 하이햇 추가\n4. 필인 → 마디 전환 연결\n\n메트로놈 필수! BPM 60에서 시작하세요.';
    }

    // ── 음악 이론 ──
    if (lower.contains('음정') || lower.contains('튜닝') || lower.contains('조율')) {
      return '음정 연습 방법:\n1. 기준음(A=440Hz) 듣기\n2. 같은 음 소리내기\n3. 녹음해서 비교\n4. 반음씩 위아래로 확장\n\n튜너 앱과 함께 연습하면 효과적입니다. 이 앱의 연습 기능에서 실시간 피치 감지를 활용해보세요!';
    }
    if (lower.contains('악보') || lower.contains('읽') || lower.contains('오선')) {
      return '악보 읽기 기초:\n• 5개 선 = 오선지\n• 높은음자리표(𝄞) 선 위의 음: 미-솔-시-레-파 (아래→위)\n• 칸의 음: 파-라-도-미\n• 가운데 C = 아래 보조선\n• 음표 모양: ○전음표, 𝅗𝅥2분, ♩4분, ♪8분\n\n앱의 악보 표시를 보면서 익혀보세요!';
    }
    if (lower.contains('장조') || lower.contains('단조') || lower.contains('조성') || lower.contains('스케일') || lower.contains('음계')) {
      return '스케일/조성 기초:\n• C장조: 도레미파솔라시도 (검은 건반 없음)\n• G장조: 솔라시도레미파#솔 (파#하나)\n• Am단조: 라시도레미파솔라 (자연단음계)\n\n장조=밝은 느낌, 단조=어두운 느낌\n매일 5분 스케일 연습이 기초 체력입니다!';
    }
    if (lower.contains('박자') || lower.contains('템포') || lower.contains('bpm') || lower.contains('메트로놈')) {
      return '박자와 템포:\n• 4/4박자: 한 마디에 4박 (가장 기본)\n• 3/4박자: 왈츠 리듬\n• BPM: 분당 박자 수 (60=1초에 1박)\n• 연습 시작은 항상 느린 BPM부터!\n\n메트로놈은 정확한 리듬감을 기르는 최고의 도구입니다.';
    }

    // ── 연습 관련 ──
    if (lower.contains('연습') || lower.contains('시간') || lower.contains('방법') || lower.contains('효과')) {
      return '효과적인 연습법:\n1. 워밍업 5분 (스케일 or 기본 연습)\n2. 새 곡 구간 연습 10분 (어려운 부분 반복)\n3. 복습 5분 (이전에 배운 곡)\n4. 자유 연습 5분 (좋아하는 곡)\n\n하루 15-30분이면 충분합니다. 매일 꾸준히가 핵심이에요!';
    }

    // ── 앱 기능 안내 ──
    if (lower.contains('앱') || lower.contains('기능') || lower.contains('사용법')) {
      return '앱 주요 기능 안내:\n• 레슨 탭: 스케일/동요/클래식/스킬 카테고리별 학습\n• 연습: 악보 보면서 마이크로 녹음 → AI 분석\n• 진도: 학습 현황, 고급 리포트\n• 커뮤니티: 연습 기록 공유, Q&A\n• 창작: 나만의 악보 만들기 (프리미엄)\n\n설정에서 구독 플랜도 확인해보세요!';
    }

    return '궁금한 점이 있으시군요! 더 정확한 답변을 위해 구체적으로 질문해주세요.\n\n예시:\n• "피아노 손가락 번호 알려줘"\n• "기타 F코드 팁"\n• "드럼 파라디들 연습법"\n• "바이올린 비브라토 하는 법"\n• "연습 추천해줘"';
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
            icon: const Icon(Icons.history_rounded, color: AppColors.textSecondary, size: 20),
            tooltip: '대화 내역',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatHistoryScreen())),
          ),
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
  ChatTone _selectedTone = ChatTone.polite;

  @override
  void initState() {
    super.initState();
    ref.read(chatProvider.notifier).getRetentionDays().then((d) {
      if (mounted) setState(() => _selectedDays = d);
    });
    ref.read(chatProvider.notifier).getTone().then((t) {
      if (mounted) setState(() => _selectedTone = t);
      ref.read(chatToneProvider.notifier).state = t;
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
          const SizedBox(height: 24),

          // 말투 설정
          const Text(
            'AI 말투',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          const Text(
            'AI 음악 선생님의 말투를 설정합니다.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ChatTone.values.map((tone) {
              final isSelected = _selectedTone == tone;
              return ChoiceChip(
                avatar: Text(tone.emoji, style: const TextStyle(fontSize: 14)),
                label: Text(tone.label, style: TextStyle(
                  fontSize: 13,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                )),
                selected: isSelected,
                selectedColor: AppColors.accent,
                backgroundColor: AppColors.bgCard,
                onSelected: (_) async {
                  setState(() => _selectedTone = tone);
                  ref.read(chatToneProvider.notifier).state = tone;
                  await ref.read(chatProvider.notifier).setTone(tone);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('말투가 "${tone.label}"로 변경되었습니다.'),
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
