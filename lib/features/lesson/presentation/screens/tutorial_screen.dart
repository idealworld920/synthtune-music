import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/services/ai_voice_service.dart';

/// 악기별 튜토리얼 데이터
class _TutorialData {
  static Map<String, Map<String, dynamic>> get data => {
    'piano': {
      'name': '피아노',
      'emoji': '🎹',
      'intro': '피아노는 건반 악기의 대표로, 88개의 건반으로 넓은 음역을 연주할 수 있습니다.\n\n'
          '왼쪽으로 갈수록 낮은 음, 오른쪽으로 갈수록 높은 음이 나옵니다.\n\n'
          '흰 건반은 도레미파솔라시(C D E F G A B), 검은 건반은 반음(#/♭)입니다.\n\n'
          '피아노는 양손으로 멜로디와 반주를 동시에 연주할 수 있어 독주에 적합하며, '
          '음악 이론을 배우기에 가장 좋은 악기입니다.',
      'posture': [
        '의자에 앉을 때 허리를 펴고, 발은 바닥에 편안하게 놓으세요.',
        '어깨의 힘을 빼고 팔꿈치를 자연스럽게 내려놓으세요.',
        '손가락을 둥글게 세우고, 달걀을 쥐듯 부드럽게 모양을 만드세요.',
        '손목은 건반 높이와 수평으로, 위아래로 꺾이지 않게 유지하세요.',
        '손가락 번호: 엄지=1, 검지=2, 중지=3, 약지=4, 새끼=5번입니다.',
      ],
      'notePositions': '건반 위치:\n\n'
          '• 도(C) — 두 개의 검은 건반 그룹 왼쪽 흰 건반\n'
          '• 레(D) — 두 개의 검은 건반 사이\n'
          '• 미(E) — 두 개의 검은 건반 그룹 오른쪽\n'
          '• 파(F) — 세 개의 검은 건반 그룹 왼쪽\n'
          '• 솔(G) — 세 개의 검은 건반 중 첫째와 둘째 사이\n'
          '• 라(A) — 세 개의 검은 건반 중 둘째와 셋째 사이\n'
          '• 시(B) — 세 개의 검은 건반 그룹 오른쪽\n\n'
          '가운데 도(C4)를 찾으세요 — 피아노 정중앙 근처입니다.',
      'fingering': '기본 운지법:\n\n'
          '• C장조 오른손: 1-2-3-1-2-3-4-5 (도레미파솔라시도)\n'
          '• 엄지(1번)가 파(F) 건반 아래를 지나갈 때 "넘기기"를 합니다\n'
          '• 왼손: 5-4-3-2-1-3-2-1 (도레미파솔라시도)\n\n'
          '팁:\n'
          '• 각 손가락으로 건반을 하나씩 눌러보세요\n'
          '• 처음엔 한 손씩, 익숙해지면 양손을 합쳐보세요\n'
          '• 손가락에 힘을 너무 주지 마세요 — 가볍게!',
    },
    'guitar': {
      'name': '기타',
      'emoji': '🎸',
      'intro': '기타는 6개의 줄을 손가락이나 피크로 튕겨 소리를 내는 현악기입니다.\n\n'
          '줄 이름 (가장 두꺼운 → 가장 가는): 6번(E) 5번(A) 4번(D) 3번(G) 2번(B) 1번(E)\n\n'
          '왼손으로 프렛을 누르고 오른손으로 줄을 튕깁니다.\n\n'
          '코드(화음)를 잡아 반주하거나, 단음으로 멜로디를 연주할 수 있습니다. '
          '휴대성이 좋아 어디서든 연주할 수 있는 것이 큰 장점입니다.',
      'posture': [
        '의자에 앉아 오른쪽 허벅지에 기타 바디를 올려놓으세요.',
        '기타 넥이 약간 위쪽을 향하도록 기울이세요.',
        '왼손 엄지는 넥 뒤쪽 중앙에 가볍게 대세요.',
        '왼손 손가락은 프렛 바로 뒤(몸쪽)를 누르세요.',
        '오른손은 사운드홀 위에서 자연스럽게 스트로크하세요.',
      ],
      'notePositions': '기본 음 위치 (1번줄 기준):\n\n'
          '• 개방현(0프렛) = E\n'
          '• 1프렛 = F\n'
          '• 3프렛 = G\n'
          '• 5프렛 = A\n'
          '• 7프렛 = B\n'
          '• 8프렛 = C(높은 도)\n\n'
          '프렛 번호가 올라갈수록 음이 높아집니다.\n'
          '각 줄의 개방현 음을 기억하세요: E-A-D-G-B-E',
      'fingering': '첫 코드 — Am:\n\n'
          '• 2번줄 1프렛: 검지(1번)\n'
          '• 3번줄 2프렛: 약지(3번) 또는 중지(2번)\n'
          '• 4번줄 2프렛: 중지(2번) 또는 약지(3번)\n'
          '• 5~1번줄 스트로크 (6번줄은 안 침)\n\n'
          '팁:\n'
          '• 손끝으로 프렛 바로 옆을 누르세요\n'
          '• 다른 줄에 손가락이 닿지 않게 세워서 누르세요\n'
          '• 처음엔 손가락이 아프지만 2주면 굳은살이 생겨요',
    },
    'violin': {
      'name': '바이올린',
      'emoji': '🎻',
      'intro': '바이올린은 활(보우)로 현을 문질러 소리를 내는 현악기입니다.\n\n'
          '4개의 줄: G(솔) D(레) A(라) E(미) — 낮은 음부터 높은 음 순서입니다.\n\n'
          '왼손으로 현을 누르고 오른손으로 활을 움직여 연주합니다.\n\n'
          '오케스트라의 꽃이라 불리며, 풍부한 감정 표현이 가능한 악기입니다. '
          '처음에는 소리 내기가 어렵지만, 꾸준히 연습하면 아름다운 소리를 만들 수 있어요.',
      'posture': [
        '바이올린을 왼쪽 쇄골 위에 올려놓으세요.',
        '턱받이에 턱을 가볍게 올려놓으세요 — 꽉 물지 마세요.',
        '왼손 엄지는 넥 옆면에 가볍게, 나머지 손가락은 현 위에.',
        '활은 엄지를 구부려 프로그 안쪽에 대고, 나머지 손가락을 자연스럽게 얹으세요.',
        '활의 무게를 이용해 현을 눌러 소리를 내세요 — 팔 힘으로 누르지 마세요.',
      ],
      'notePositions': '개방현 음:\n\n'
          '• G현 (가장 두꺼움) = 솔3 (196Hz)\n'
          '• D현 = 레4 (293Hz)\n'
          '• A현 = 라4 (440Hz)\n'
          '• E현 (가장 가는) = 미5 (659Hz)\n\n'
          '왼손 손가락을 놓으면 음이 높아집니다:\n'
          '• A현 개방 = 라(A)\n'
          '• A현 1번 손가락 = 시(B)\n'
          '• A현 2번 손가락 = 도#(C#) 또는 도(C)\n'
          '• A현 3번 손가락 = 레(D)',
      'fingering': '왼손 기본 운지:\n\n'
          '• 1번 손가락(검지): 현에서 약 2cm 위치\n'
          '• 2번 손가락(중지): 1번에서 약 1.5cm 위\n'
          '• 3번 손가락(약지): 2번 바로 옆\n'
          '• 4번 손가락(새끼): 잘 안 쓰지만 나중에 필요\n\n'
          '팁:\n'
          '• 손가락 끝으로 현을 눌러야 깨끗한 소리\n'
          '• 처음엔 A현에서 1번 손가락만 연습하세요\n'
          '• 튜너 앱으로 음정 확인하며 연습하세요',
    },
    'drums': {
      'name': '드럼',
      'emoji': '🥁',
      'intro': '드럼은 타악기의 꽃으로, 리듬의 기초를 담당하는 악기입니다.\n\n'
          '기본 구성:\n'
          '• 킥 드럼(베이스) — 발로 페달을 밟아 연주\n'
          '• 스네어 — 왼손 앞에 위치, 가장 많이 치는 드럼\n'
          '• 하이햇 — 두 장의 심벌, 발+손으로 조절\n'
          '• 탐탐 — 높은 음에서 낮은 음으로 2~3개\n'
          '• 크래시/라이드 심벌 — 악센트와 리듬용\n\n'
          '드럼은 밴드의 심장이며, 리듬감과 신체 협응력을 기를 수 있습니다.',
      'posture': [
        '의자(드럼 스툴)에 앉을 때 허벅지가 약간 아래를 향하게.',
        '스네어 드럼이 배꼽 높이 정도에 오도록 조절하세요.',
        '팔꿈치를 옆구리에서 자연스럽게 떨어뜨리세요.',
        '스틱은 1/3 지점을 엄지와 검지로 잡고, 나머지 손가락은 감싸세요.',
        '손목을 이용해 치고, 리바운드(튕김)를 활용하세요.',
      ],
      'notePositions': '드럼 세트 위치:\n\n'
          '• 킥 (발) — 바닥 중앙, 오른발 페달\n'
          '• 스네어 — 왼쪽 무릎 위 (왼손)\n'
          '• 하이햇 — 왼쪽 위 (오른손 크로스)\n'
          '• 하이탐 — 왼쪽 위\n'
          '• 미들탐 — 중앙 위\n'
          '• 플로어탐 — 오른쪽 아래\n'
          '• 크래시 심벌 — 왼쪽 높이\n'
          '• 라이드 심벌 — 오른쪽 높이',
      'fingering': '기본 비트 (4비트):\n\n'
          '• 1박: 킥 + 하이햇\n'
          '• 2박: 스네어 + 하이햇\n'
          '• 3박: 킥 + 하이햇\n'
          '• 4박: 스네어 + 하이햇\n\n'
          '연습법:\n'
          '• 발(킥)과 손(스네어)을 따로 연습하세요\n'
          '• BPM 60부터 아주 천천히 시작\n'
          '• 메트로놈에 맞춰 정확도 우선\n'
          '• 8비트: 하이햇을 매 반박마다 추가',
    },
  };
}

class TutorialScreen extends StatefulWidget {
  final String instrument;
  const TutorialScreen({super.key, required this.instrument});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  CameraController? _cameraCtrl;
  bool _cameraReady = false;

  Map<String, dynamic> get _data =>
      _TutorialData.data[widget.instrument] ?? _TutorialData.data['piano']!;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;
      final front = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _cameraCtrl = CameraController(front, ResolutionPreset.medium, enableAudio: false);
      await _cameraCtrl!.initialize();
      if (mounted) setState(() => _cameraReady = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _cameraCtrl?.dispose();
    AiVoiceService.stop();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      setState(() => _currentPage++);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageCtrl.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = ['악기 소개', '자세 안내', '음의 위치', '운지법'];

    return Scaffold(
      appBar: AppBar(
        title: Text('${_data['name']} 입문'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('${_currentPage + 1}/4', style: TextStyle(color: AppColors.textSecondary))),
          ),
        ],
      ),
      body: Column(
        children: [
          // 진행 바
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: List.generate(4, (i) => Expanded(
                child: Container(
                  height: 3,
                  margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: i <= _currentPage ? AppColors.primary : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              )),
            ),
          ),
          // 단계 이름
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(steps[_currentPage], style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 14)),
          ),

          // 페이지
          Expanded(
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _IntroPage(),
                _PosturePage(),
                _NotePositionPage(),
                _FingeringPage(),
              ],
            ),
          ),

          // 하단 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _prevPage,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(color: AppColors.bgCard),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('이전'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _currentPage < 3 ? _nextPage : () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _currentPage < 3 ? AppColors.primary : AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(_currentPage < 3 ? '다음' : '완료', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 1. 악기 소개 ───
  Widget _IntroPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(_data['emoji'] as String, style: const TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text('${_data['name']}이란?', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16)),
            child: Text(
              _data['intro'] as String,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 15, height: 1.7),
            ),
          ),
          const SizedBox(height: 16),
          // AI 음성으로 듣기
          OutlinedButton.icon(
            onPressed: () => AiVoiceService.speak(_data['intro'] as String),
            icon: Icon(Icons.volume_up_rounded),
            label: const Text('AI 음성으로 듣기'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: BorderSide(color: AppColors.accent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 2. 자세 안내 (카메라 + AI 음성) ───
  Widget _PosturePage() {
    final postures = _data['posture'] as List<String>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // 카메라 프리뷰
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: _cameraReady && _cameraCtrl != null
                  ? Stack(
                      children: [
                        CameraPreview(_cameraCtrl!),
                        Positioned(
                          bottom: 8, left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                            child: Text('자세를 확인하세요', style: TextStyle(color: Colors.white, fontSize: 11)),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.videocam_off_rounded, color: AppColors.textSecondary, size: 32),
                          const SizedBox(height: 8),
                          Text('카메라 사용 불가', style: TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),

          // 자세 가이드
          ...postures.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => AiVoiceService.speak(e.value),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.2)),
                      child: Center(child: Text('${e.key + 1}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(e.value, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.4))),
                    Icon(Icons.volume_up_rounded, color: AppColors.accent, size: 18),
                  ],
                ),
              ),
            ),
          )),

          // 전체 듣기
          OutlinedButton.icon(
            onPressed: () {
              final all = postures.join('. ');
              AiVoiceService.speak(all);
            },
            icon: Icon(Icons.play_circle_rounded),
            label: const Text('전체 음성 안내'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: BorderSide(color: AppColors.accent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 3. 음의 위치 ───
  Widget _NotePositionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.piano_rounded, color: AppColors.primary, size: 48),
          const SizedBox(height: 16),
          Text('음의 위치', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16)),
            child: Text(_data['notePositions'] as String, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.7)),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => AiVoiceService.speak(_data['notePositions'] as String),
            icon: Icon(Icons.volume_up_rounded),
            label: const Text('AI 음성으로 듣기'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: BorderSide(color: AppColors.accent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 4. 운지법 ───
  Widget _FingeringPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.back_hand_rounded, color: AppColors.accentGold, size: 48),
          const SizedBox(height: 16),
          Text('운지법', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16)),
            child: Text(_data['fingering'] as String, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.7)),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => AiVoiceService.speak(_data['fingering'] as String),
            icon: Icon(Icons.volume_up_rounded),
            label: const Text('AI 음성으로 듣기'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: BorderSide(color: AppColors.accent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.scorePerfect.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.scorePerfect.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('입문 완료!', style: TextStyle(color: AppColors.scorePerfect, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('이제 레슨 탭에서 기본 스케일부터 시작해보세요.', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
