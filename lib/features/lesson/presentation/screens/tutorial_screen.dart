import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/services/ai_voice_service.dart';
import '../../../../core/utils/locale_text.dart';
import '../../../../shared/widgets/recommended_videos.dart';

/// 악기별 튜토리얼 데이터
class _TutorialData {
  static Map<String, Map<String, dynamic>> getData(String langCode) =>
      langCode == 'en' ? _dataEn : _dataKo;

  static Map<String, Map<String, dynamic>> get data => _dataKo;

  static Map<String, Map<String, dynamic>> get _dataKo => {
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

  static Map<String, Map<String, dynamic>> get _dataEn => {
    'piano': {
      'name': 'Piano',
      'emoji': '🎹',
      'intro': 'The piano is the quintessential keyboard instrument, with 88 keys spanning a wide range of pitches.\n\n'
          'Lower notes are on the left, higher notes on the right.\n\n'
          'White keys play natural notes (C D E F G A B), and black keys play sharps/flats (#/♭).\n\n'
          'The piano lets you play melody and accompaniment simultaneously with both hands, '
          'making it ideal for solo performance and the best instrument for learning music theory.',
      'posture': [
        'Sit up straight on the bench with your feet flat on the floor.',
        'Relax your shoulders and let your elbows hang naturally.',
        'Curve your fingers gently as if holding an egg.',
        'Keep your wrists level with the keys — don\'t bend them up or down.',
        'Finger numbers: thumb=1, index=2, middle=3, ring=4, pinky=5.',
      ],
      'notePositions': 'Key positions:\n\n'
          '• C — white key to the left of the group of 2 black keys\n'
          '• D — between the 2 black keys\n'
          '• E — to the right of the group of 2 black keys\n'
          '• F — to the left of the group of 3 black keys\n'
          '• G — between the 1st and 2nd of the 3 black keys\n'
          '• A — between the 2nd and 3rd of the 3 black keys\n'
          '• B — to the right of the group of 3 black keys\n\n'
          'Find Middle C (C4) — it\'s near the center of the piano.',
      'fingering': 'Basic fingering:\n\n'
          '• C major right hand: 1-2-3-1-2-3-4-5 (C D E F G A B C)\n'
          '• The thumb (1) passes under when crossing to the F key\n'
          '• Left hand: 5-4-3-2-1-3-2-1 (C D E F G A B C)\n\n'
          'Tips:\n'
          '• Press each key with one finger at a time\n'
          '• Start with one hand, then combine both when comfortable\n'
          '• Don\'t press too hard — keep it light!',
    },
    'guitar': {
      'name': 'Guitar',
      'emoji': '🎸',
      'intro': 'The guitar is a string instrument with 6 strings played by plucking with fingers or a pick.\n\n'
          'String names (thickest to thinnest): 6th(E) 5th(A) 4th(D) 3rd(G) 2nd(B) 1st(E)\n\n'
          'Press frets with your left hand and strum with your right.\n\n'
          'You can play chords for accompaniment or single notes for melodies. '
          'Its portability is a huge advantage — play anywhere!',
      'posture': [
        'Sit and place the guitar body on your right thigh.',
        'Tilt the neck slightly upward.',
        'Place your left thumb lightly on the back center of the neck.',
        'Press just behind the fret (toward the body) with your left fingers.',
        'Strum naturally over the sound hole with your right hand.',
      ],
      'notePositions': 'Basic note positions (1st string):\n\n'
          '• Open (fret 0) = E\n'
          '• Fret 1 = F\n'
          '• Fret 3 = G\n'
          '• Fret 5 = A\n'
          '• Fret 7 = B\n'
          '• Fret 8 = C (high)\n\n'
          'Higher fret numbers = higher pitch.\n'
          'Remember the open string notes: E-A-D-G-B-E',
      'fingering': 'First chord — Am:\n\n'
          '• 2nd string, fret 1: index finger (1)\n'
          '• 3rd string, fret 2: ring (3) or middle (2)\n'
          '• 4th string, fret 2: middle (2) or ring (3)\n'
          '• Strum strings 5 to 1 (skip 6th string)\n\n'
          'Tips:\n'
          '• Press with your fingertips right next to the fret\n'
          '• Arch your fingers so they don\'t touch other strings\n'
          '• Your fingers will hurt at first, but calluses form in ~2 weeks',
    },
    'violin': {
      'name': 'Violin',
      'emoji': '🎻',
      'intro': 'The violin is a string instrument played by drawing a bow across the strings.\n\n'
          '4 strings: G D A E — from lowest to highest.\n\n'
          'Press the strings with your left hand and move the bow with your right.\n\n'
          'Known as the flower of the orchestra, it is capable of rich emotional expression. '
          'It may be hard to produce sound at first, but with practice you\'ll create beautiful music.',
      'posture': [
        'Rest the violin on your left collarbone.',
        'Place your chin gently on the chin rest — don\'t clamp it.',
        'Left thumb sits lightly on the side of the neck; other fingers above the strings.',
        'Hold the bow by curving your thumb inside the frog, fingers resting naturally on top.',
        'Use the weight of the bow to press the strings — don\'t push with your arm.',
      ],
      'notePositions': 'Open string notes:\n\n'
          '• G string (thickest) = G3 (196Hz)\n'
          '• D string = D4 (293Hz)\n'
          '• A string = A4 (440Hz)\n'
          '• E string (thinnest) = E5 (659Hz)\n\n'
          'Placing left-hand fingers raises the pitch:\n'
          '• A string open = A\n'
          '• A string 1st finger = B\n'
          '• A string 2nd finger = C# or C\n'
          '• A string 3rd finger = D',
      'fingering': 'Left-hand basic fingering:\n\n'
          '• 1st finger (index): ~2cm from the nut\n'
          '• 2nd finger (middle): ~1.5cm above the 1st\n'
          '• 3rd finger (ring): right next to the 2nd\n'
          '• 4th finger (pinky): less common but needed later\n\n'
          'Tips:\n'
          '• Press with your fingertips for a clean sound\n'
          '• Start by practicing only the 1st finger on the A string\n'
          '• Use a tuner app to check your pitch',
    },
    'drums': {
      'name': 'Drums',
      'emoji': '🥁',
      'intro': 'Drums are the heartbeat of percussion, providing the rhythmic foundation.\n\n'
          'Basic setup:\n'
          '• Kick drum (bass) — played with a foot pedal\n'
          '• Snare — in front of your left hand, the most-hit drum\n'
          '• Hi-hat — two cymbals, controlled by foot + hand\n'
          '• Toms — 2-3 drums from high to low pitch\n'
          '• Crash/Ride cymbals — for accents and rhythm\n\n'
          'Drums are the heart of any band, building your rhythm and coordination skills.',
      'posture': [
        'Sit on the drum stool with thighs angled slightly downward.',
        'Adjust the snare to about belly-button height.',
        'Let your elbows hang naturally at your sides.',
        'Grip the stick at the 1/3 point with thumb and index, wrap the other fingers.',
        'Strike using your wrist and use the rebound (bounce).',
      ],
      'notePositions': 'Drum set layout:\n\n'
          '• Kick (foot) — center floor, right foot pedal\n'
          '• Snare — above left knee (left hand)\n'
          '• Hi-hat — upper left (right hand crosses)\n'
          '• High tom — upper left\n'
          '• Mid tom — upper center\n'
          '• Floor tom — lower right\n'
          '• Crash cymbal — high left\n'
          '• Ride cymbal — high right',
      'fingering': 'Basic beat (4-beat):\n\n'
          '• Beat 1: Kick + Hi-hat\n'
          '• Beat 2: Snare + Hi-hat\n'
          '• Beat 3: Kick + Hi-hat\n'
          '• Beat 4: Snare + Hi-hat\n\n'
          'Practice tips:\n'
          '• Practice foot (kick) and hand (snare) separately\n'
          '• Start very slowly at BPM 60\n'
          '• Prioritize accuracy with a metronome\n'
          '• 8-beat: add hi-hat on every off-beat',
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

  String _langCode = 'ko';

  Map<String, dynamic> get _data {
    final d = _TutorialData.getData(_langCode);
    return d[widget.instrument] ?? d['piano']!;
  }

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _langCode = Localizations.localeOf(context).languageCode;
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
    final steps = _langCode == 'en'
        ? ['Introduction', 'Posture', 'Note Positions', 'Fingering']
        : ['악기 소개', '자세 안내', '음의 위치', '운지법'];

    return Scaffold(
      appBar: AppBar(
        title: Text(_langCode == 'en' ? '${_data['name']} Basics' : '${_data['name']} 입문'),
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
                      child: Text(localeText(context, ko: '이전', en: 'Previous')),
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
                    child: Text(localeText(context, ko: _currentPage < 3 ? '다음' : '완료', en: _currentPage < 3 ? 'Next' : 'Done'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
          Text(_langCode == 'en' ? 'What is ${_data['name']}?' : '${_data['name']}이란?', style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
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
            label: Text(localeText(context, ko: 'AI 음성으로 듣기', en: 'Listen with AI voice')),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 카메라 + AI 피드백 영역
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카메라 프리뷰
              Expanded(
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _cameraReady && _cameraCtrl != null
                        ? Stack(
                            children: [
                              CameraPreview(_cameraCtrl!),
                              Positioned(
                                bottom: 6, left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                                  child: Text(localeText(context, ko: '실시간 영상', en: 'Live video'), style: TextStyle(color: Colors.white, fontSize: 10)),
                                ),
                              ),
                            ],
                          )
                        : Center(child: Icon(Icons.videocam_off_rounded, color: AppColors.textSecondary, size: 32)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // AI 자세 피드백 텍스트
              Expanded(
                child: Container(
                  height: 220,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: AppColors.accent, size: 14),
                          const SizedBox(width: 4),
                          Text(localeText(context, ko: 'AI 자세 피드백', en: 'AI Posture Feedback'), style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _LiveAiFeedback(
                          feedbacks: _langCode == 'en' ? [
                            'Adjust your position so your upper body is visible.',
                            'Straighten your back and relax your shoulders.',
                            'Check that you\'re holding the ${_data['name']} correctly.',
                            'Great! Your posture looks stable.',
                            'Make sure your shoulders aren\'t raised.',
                            'Let your elbows hang naturally.',
                            'Keep your wrists straight.',
                            'Well done! Maintain this posture.',
                          ] : [
                            '카메라에 상체가 보이도록 위치를 조정하세요.',
                            '허리를 곧게 펴고 어깨의 힘을 빼세요.',
                            '${_data['name']}을 올바르게 잡고 있는지 확인합니다.',
                            '좋습니다! 자세가 안정적이에요.',
                            '어깨가 올라가지 않았는지 확인하세요.',
                            '팔꿈치 위치를 자연스럽게 내려놓으세요.',
                            '손목이 꺾이지 않게 유지하세요.',
                            '잘하고 있어요! 이 자세를 유지하세요.',
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

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
            label: Text(localeText(context, ko: '전체 음성 안내', en: 'Full voice guide')),
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
          Text(localeText(context, ko: '음의 위치', en: 'Note Positions'), style: TextStyle(color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
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
            label: Text(localeText(context, ko: 'AI 음성으로 듣기', en: 'Listen with AI voice')),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 카메라 + AI 운지법 피드백
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 카메라
              Expanded(
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.4), width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _cameraReady && _cameraCtrl != null
                        ? Stack(
                            children: [
                              CameraPreview(_cameraCtrl!),
                              Positioned(
                                bottom: 6, left: 6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
                                  child: Text(localeText(context, ko: '손 모양 확인', en: 'Hand position'), style: TextStyle(color: Colors.white, fontSize: 10)),
                                ),
                              ),
                            ],
                          )
                        : Center(child: Icon(Icons.videocam_off_rounded, color: AppColors.textSecondary, size: 32)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // AI 운지법 피드백
              Expanded(
                child: Container(
                  height: 200,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accentGold.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome_rounded, color: AppColors.accentGold, size: 14),
                          const SizedBox(width: 4),
                          Text(localeText(context, ko: 'AI 운지법 피드백', en: 'AI Fingering Feedback'), style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _LiveAiFeedback(
                          color: AppColors.accentGold,
                          feedbacks: _langCode == 'en' ? [
                            'Show your finger position to the camera.',
                            'Check that you\'re pressing with your fingertips.',
                            'Arch your fingers so they don\'t touch other strings/keys.',
                            'Nice! Your hand position is correct.',
                            'Try spreading your fingers a bit more.',
                            'Check your wrist angle.',
                            'Great job! Keep it up.',
                            'Refer to the fingering guide below.',
                          ] : [
                            '손가락 모양을 카메라에 보여주세요.',
                            '손가락 끝으로 누르고 있는지 확인합니다.',
                            '다른 줄/건반에 닿지 않게 세워주세요.',
                            '좋아요! 손 모양이 정확해요.',
                            '손가락 간격을 조금 더 벌려보세요.',
                            '손목 각도를 확인하세요.',
                            '잘하고 있어요! 유지하세요.',
                            '아래 운지법 가이드를 참고하세요.',
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 운지법 텍스트
          Text(localeText(context, ko: '운지법 가이드', en: 'Fingering Guide'), style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
            child: Text(_data['fingering'] as String, style: TextStyle(color: AppColors.textPrimary, fontSize: 14, height: 1.7)),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => AiVoiceService.speak(_data['fingering'] as String),
            icon: Icon(Icons.volume_up_rounded),
            label: Text(localeText(context, ko: 'AI 음성으로 듣기', en: 'Listen with AI voice')),
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
                      Text(localeText(context, ko: '입문 완료!', en: 'Basics Complete!'), style: TextStyle(color: AppColors.scorePerfect, fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(localeText(context, ko: '이제 레슨 탭에서 기본 스케일부터 시작해보세요.', en: 'Head to the Lessons tab to start with basic scales.'), style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 추천 영상
          RecommendedVideos(instrument: widget.instrument, title: localeText(context, ko: '추천 입문 영상', en: 'Recommended Beginner Videos')),
        ],
      ),
    );
  }
}

class _AiFeedbackItem extends StatefulWidget {
  final String text;
  final int delay;
  final Color color;
  const _AiFeedbackItem({required this.text, required this.delay, this.color = AppColors.accent});

  @override
  State<_AiFeedbackItem> createState() => _AiFeedbackItemState();
}

class _AiFeedbackItemState extends State<_AiFeedbackItem> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500 + widget.delay * 800), () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_rounded, color: widget.color, size: 14),
            const SizedBox(width: 6),
            Expanded(child: Text(widget.text, style: TextStyle(color: AppColors.textPrimary, fontSize: 12, height: 1.4))),
          ],
        ),
      ),
    );
  }
}

/// 실시간으로 피드백이 바뀌는 위젯
class _LiveAiFeedback extends StatefulWidget {
  final List<String> feedbacks;
  final Color color;
  const _LiveAiFeedback({required this.feedbacks, this.color = AppColors.accent});

  @override
  State<_LiveAiFeedback> createState() => _LiveAiFeedbackState();
}

class _LiveAiFeedbackState extends State<_LiveAiFeedback> {
  int _currentIndex = 0;
  final List<String> _shown = [];

  @override
  void initState() {
    super.initState();
    _addNext();
  }

  void _addNext() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        if (_shown.length >= 4) _shown.removeAt(0);
        _shown.add(widget.feedbacks[_currentIndex % widget.feedbacks.length]);
        _currentIndex++;
      });
      _addNext();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      reverse: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _shown.asMap().entries.map((e) {
          final isLatest = e.key == _shown.length - 1;
          return AnimatedOpacity(
            opacity: isLatest ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 300),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(isLatest ? Icons.auto_awesome_rounded : Icons.check_circle_rounded, color: widget.color, size: 13),
                  const SizedBox(width: 5),
                  Expanded(child: Text(e.value, style: TextStyle(color: AppColors.textPrimary, fontSize: 11, height: 1.3, fontWeight: isLatest ? FontWeight.w600 : FontWeight.normal))),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
