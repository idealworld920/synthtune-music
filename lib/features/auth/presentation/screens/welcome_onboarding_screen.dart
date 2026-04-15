import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared/widgets/app_logo.dart';
import '../../../../shared/services/ai_voice_service.dart';
import '../../../../core/utils/locale_text.dart';
import '../../../settings/presentation/screens/language_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/user_profile_provider.dart';

class WelcomeOnboardingScreen extends ConsumerStatefulWidget {
  const WelcomeOnboardingScreen({super.key});

  @override
  ConsumerState<WelcomeOnboardingScreen> createState() => _WelcomeOnboardingState();
}

class _WelcomeOnboardingState extends ConsumerState<WelcomeOnboardingScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  final _totalPages = 11;

  // 데이터
  String _selectedLanguage = 'ko';
  String _selectedInstrument = 'piano';
  String _selectedLevel = 'beginner';
  String _purpose = '';
  String _nickname = '';
  File? _profileImage;
  bool _subscribeInterest = false;
  bool _isSignedIn = false;
  bool _isSigningIn = false;

  // 축하 애니메이션
  late AnimationController _celebrateCtrl;
  late Animation<double> _celebrateScale;

  List<(String, String, String)> _instrumentList(BuildContext context) => [
    ('piano', localeText(context, ko: '피아노', en: 'Piano'), '🎹'),
    ('guitar', localeText(context, ko: '기타', en: 'Guitar'), '🎸'),
    ('drums', localeText(context, ko: '드럼', en: 'Drums'), '🥁'),
    ('violin', localeText(context, ko: '바이올린', en: 'Violin'), '🎻'),
  ];

  @override
  void initState() {
    super.initState();
    _celebrateCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _celebrateScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrateCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _celebrateCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    // 회원가입 페이지(3)에서 로그인 안 했으면 막기
    if (_currentPage == 3 && !_isSignedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localeText(context, ko: '계정을 연동해주세요', en: 'Please link your account')), backgroundColor: AppColors.scoreMiss),
      );
      return;
    }
    if (_currentPage < _totalPages - 1) {
      _pageCtrl.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      setState(() => _currentPage++);
      if (_currentPage == _totalPages - 1) _celebrateCtrl.forward();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageCtrl.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      setState(() => _currentPage--);
    }
  }

  Future<void> _complete() async {
    // 언어 + AI 음성 언어 동기화
    ref.read(appLanguageProvider.notifier).state = _selectedLanguage;
    final langMap = {'ko': 'ko-KR', 'en': 'en-US', 'ja': 'ja-JP', 'zh': 'zh-CN', 'fr': 'fr-FR', 'pt': 'pt-BR', 'es': 'es-ES', 'de': 'de-DE', 'it': 'it-IT', 'ru': 'ru-RU', 'vi': 'vi-VN', 'th': 'th-TH', 'ar': 'ar-SA', 'hi': 'hi-IN', 'id': 'id-ID'};
    await AiVoiceService.setLanguage(langMap[_selectedLanguage] ?? 'ko-KR');
    await ref.read(userProfileProvider.notifier).saveOnboarding(_selectedInstrument, _selectedLevel);
    if (mounted) context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // 진행 바
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: List.generate(_totalPages, (i) => Expanded(
                  child: Container(
                    height: 3,
                    margin: EdgeInsets.only(right: i < _totalPages - 1 ? 4 : 0),
                    decoration: BoxDecoration(
                      color: i <= _currentPage ? AppColors.primary : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                )),
              ),
            ),

            // 페이지
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _LanguagePage(),
                  _IntroPage(),
                  _HowToUsePage(),
                  _SignUpPage(),
                  _InstrumentPage(),
                  _PurposePage(),
                  _NicknamePage(),
                  _ProfilePhotoPage(),
                  _PermissionPage(),
                  _SubscriptionPage(),
                  _CelebratePage(),
                ],
              ),
            ),

            // 하단 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  if (_currentPage > 0 && _currentPage < _totalPages - 1)
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
                  if (_currentPage > 0 && _currentPage < _totalPages - 1)
                    const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _currentPage == _totalPages - 1 ? _complete : _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentPage == _totalPages - 1 ? AppColors.accent : AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        _currentPage == 0 ? localeText(context, ko: '시작하기', en: 'Get Started') :
                        _currentPage == _totalPages - 1 ? localeText(context, ko: '입장하기', en: 'Enter') : localeText(context, ko: '다음', en: 'Next'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 0. 언어 선택 ───
  Widget _LanguagePage() {
    const langs = [
      ('ko', '한국어', '🇰🇷'),
      ('en', 'English', '🇺🇸'),
    ];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.language_rounded, color: AppColors.primary, size: 48),
          const SizedBox(height: 16),
          Text(localeText(context, ko: '언어를 선택하세요', en: 'Select your language'), style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(localeText(context, ko: 'Select your language', en: '언어를 선택하세요'), style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.6),
              itemCount: langs.length,
              itemBuilder: (context, i) {
                final l = langs[i];
                final isSel = _selectedLanguage == l.$1;
                return GestureDetector(
                  onTap: () async {
                    setState(() => _selectedLanguage = l.$1);
                    // 즉시 앱 언어 변경
                    ref.read(appLanguageProvider.notifier).state = l.$1;
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('app_language', l.$1);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primary.withValues(alpha: 0.2) : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSel ? AppColors.primary : Colors.transparent, width: 2),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(l.$3, style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 4),
                        Text(l.$2, style: TextStyle(color: isSel ? AppColors.primary : AppColors.textSecondary, fontSize: 10, fontWeight: isSel ? FontWeight.bold : FontWeight.normal), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── 1. 앱 소개 ───
  Widget _IntroPage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 100),
            const SizedBox(height: 28),
            Text('SynthTune Music', style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(localeText(context, ko: 'AI 기반 음악 교육 앱', en: 'AI-powered Music Education'), style: TextStyle(color: AppColors.accent, fontSize: 16)),
            const SizedBox(height: 24),
            _FeatureChip(icon: Icons.music_note_rounded, text: localeText(context, ko: '4가지 악기 (피아노·기타·바이올린·드럼)', en: '4 instruments (Piano, Guitar, Violin, Drums)')),
            _FeatureChip(icon: Icons.auto_awesome_rounded, text: localeText(context, ko: 'AI가 실시간 연주 분석 및 피드백', en: 'Real-time AI performance analysis & feedback')),
            _FeatureChip(icon: Icons.library_music_rounded, text: localeText(context, ko: '120+ 레슨 (스케일·동요·클래식·스킬)', en: '120+ lessons (Scales, Songs, Classics, Skills)')),
            _FeatureChip(icon: Icons.people_rounded, text: localeText(context, ko: '커뮤니티에서 함께 성장', en: 'Grow together in the community')),
          ],
        ),
      ),
    );
  }

  // ─── 2. 앱 사용법 ───
  Widget _HowToUsePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.school_rounded, color: AppColors.primary, size: 48),
          const SizedBox(height: 20),
          Text(localeText(context, ko: '이렇게 사용해요', en: 'How to use'), style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 28),
          _StepCard(step: '1', title: localeText(context, ko: '레슨 선택', en: 'Choose a lesson'), desc: localeText(context, ko: '원하는 곡의 악보를 선택하세요', en: 'Select the sheet music you want'), icon: Icons.music_note_rounded),
          _StepCard(step: '2', title: localeText(context, ko: '연습 시작', en: 'Start practicing'), desc: localeText(context, ko: '악보를 보며 연주하면 AI가 듣고 분석해요', en: 'Play along and AI listens & analyzes'), icon: Icons.mic_rounded),
          _StepCard(step: '3', title: localeText(context, ko: 'AI 피드백', en: 'AI Feedback'), desc: localeText(context, ko: '음정 정확도와 개선점을 확인하세요', en: 'Check pitch accuracy & improvements'), icon: Icons.auto_awesome_rounded),
          _StepCard(step: '4', title: localeText(context, ko: '성장 확인', en: 'Track progress'), desc: localeText(context, ko: '진도와 XP로 실력 향상을 추적하세요', en: 'Track your growth with XP & progress'), icon: Icons.trending_up_rounded),
        ],
      ),
    );
  }

  // ─── 3. 회원가입 (Google / 이메일) ───
  Widget _SignUpPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_circle_rounded, color: AppColors.primary, size: 56),
          const SizedBox(height: 20),
          Text(localeText(context, ko: '계정 만들기', en: 'Create Account'), style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(localeText(context, ko: '학습 기록을 저장하고\n다양한 기기에서 이어서 학습하세요', en: 'Save your progress and\ncontinue learning on any device'), textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
          const SizedBox(height: 32),

          if (_isSignedIn) ...[
            // 로그인 완료 상태
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.scorePerfect.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.scorePerfect.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.scorePerfect, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(localeText(context, ko: '계정 연동 완료!', en: 'Account linked!'), style: TextStyle(color: AppColors.scorePerfect, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(localeText(context, ko: '다음 단계로 진행하세요', en: 'Proceed to the next step'), style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Google 로그인 버튼
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: _isSigningIn ? null : () async {
                  setState(() => _isSigningIn = true);
                  try {
                    await ref.read(authNotifierProvider.notifier).signInWithGoogle();
                    final state = ref.read(authNotifierProvider);
                    if (state is! AsyncError) {
                      setState(() { _isSignedIn = true; _isSigningIn = false; });
                    } else {
                      setState(() => _isSigningIn = false);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(localeText(context, ko: '로그인 실패. 다시 시도해주세요.', en: 'Login failed. Please try again.')), backgroundColor: AppColors.scoreMiss),
                        );
                      }
                    }
                  } catch (_) {
                    setState(() => _isSigningIn = false);
                  }
                },
                icon: _isSigningIn
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.textPrimary))
                    : Icon(Icons.g_mobiledata_rounded, size: 28),
                label: Text(localeText(context, ko: 'Google로 계속하기', en: 'Continue with Google'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.bgCard)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(localeText(context, ko: '또는', en: 'or'), style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ),
                Expanded(child: Divider(color: AppColors.bgCard)),
              ],
            ),
            const SizedBox(height: 16),
            // 이메일 가입 버튼
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () {
                  // 기존 회원가입 화면으로
                  context.push(RouteNames.register);
                },
                icon: Icon(Icons.email_outlined),
                label: Text(localeText(context, ko: '이메일로 가입하기', en: 'Sign up with Email'), style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(color: AppColors.bgCard),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 이미 계정이 있는 경우
            GestureDetector(
              onTap: () => context.push(RouteNames.login),
              child: Text(localeText(context, ko: '이미 계정이 있으신가요? 로그인', en: 'Already have an account? Log in'), style: TextStyle(color: AppColors.primary, fontSize: 14)),
            ),
          ],
        ],
      ),
    );
  }

  // ─── 4. 악기 고르기 ───
  Widget _InstrumentPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(localeText(context, ko: '어떤 악기를\n배우고 싶으신가요?', en: 'Which instrument would\nyou like to learn?'), textAlign: TextAlign.center, style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(localeText(context, ko: '나중에 변경할 수 있어요', en: 'You can change this anytime'), style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 32),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: _instrumentList(context).map((inst) {
              final isSelected = _selectedInstrument == inst.$1;
              return GestureDetector(
                onTap: () => setState(() => _selectedInstrument = inst.$1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.2) : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(inst.$3, style: const TextStyle(fontSize: 36)),
                      const SizedBox(height: 8),
                      Text(inst.$2, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── 4. 배우는 목적 ───
  Widget _PurposePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note_rounded, color: AppColors.accent, size: 48),
          const SizedBox(height: 20),
          Text(localeText(context, ko: '음악을 배우려는\n이유가 있나요?', en: 'Why do you want\nto learn music?'), textAlign: TextAlign.center, style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(localeText(context, ko: '선택 사항이에요', en: 'This is optional'), style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),
          TextField(
            maxLines: 3,
            onChanged: (v) => _purpose = v,
            style: TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: localeText(context, ko: '예: 좋아하는 곡을 직접 연주하고 싶어요', en: 'e.g. I want to play my favorite songs'),
              hintStyle: TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.bgCard,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: {
              '취미로': 'Hobby',
              '전공/진로': 'Major/Career',
              '스트레스 해소': 'Stress Relief',
              '자녀 교육': 'Child Education',
              '재능 개발': 'Talent Development',
            }.entries.map((e) {
              final label = localeText(context, ko: e.key, en: e.value);
              final isSelected = _purpose == e.key;
              return GestureDetector(
                onTap: () => setState(() => _purpose = e.key),
                child: Chip(
                  label: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 13)),
                  backgroundColor: isSelected ? AppColors.primary : AppColors.bgCard,
                  side: BorderSide.none,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─── 5. 닉네임 설정 ───
  Widget _NicknamePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.badge_rounded, color: AppColors.primary, size: 48),
          const SizedBox(height: 20),
          Text(localeText(context, ko: '닉네임을 정해주세요', en: 'Choose your nickname'), style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(localeText(context, ko: '커뮤니티에서 사용될 이름이에요', en: 'This name will be used in the community'), style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 32),
          TextField(
            onChanged: (v) => setState(() => _nickname = v),
            style: TextStyle(color: AppColors.textPrimary, fontSize: 18),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: localeText(context, ko: '닉네임 입력', en: 'Enter nickname'),
              hintStyle: TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.bgCard,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 6. 프로필 사진 ───
  Widget _ProfilePhotoPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(localeText(context, ko: '프로필 사진', en: 'Profile Photo'), style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(localeText(context, ko: '선택 사항이에요', en: 'This is optional'), style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () async {
              final picker = ImagePicker();
              final img = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
              if (img != null) setState(() => _profileImage = File(img.path));
            },
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgCard,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 2),
                image: _profileImage != null ? DecorationImage(image: FileImage(_profileImage!), fit: BoxFit.cover) : null,
              ),
              child: _profileImage == null ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_rounded, color: AppColors.primary, size: 32),
                  const SizedBox(height: 4),
                  Text(localeText(context, ko: '사진 선택', en: 'Select Photo'), style: TextStyle(color: AppColors.primary, fontSize: 12)),
                ],
              ) : null,
            ),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: _nextPage,
            child: Text(localeText(context, ko: '건너뛰기', en: 'Skip'), style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  // ─── 7. 권한 허용 ───
  Widget _PermissionPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.security_rounded, color: AppColors.accent, size: 48),
          const SizedBox(height: 20),
          Text(localeText(context, ko: '앱 권한 안내', en: 'App Permissions'), style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _PermissionTile(
            icon: Icons.mic_rounded,
            title: localeText(context, ko: '마이크', en: 'Microphone'),
            desc: localeText(context, ko: '연주 녹음 + AI 음정 분석', en: 'Record performance + AI pitch analysis'),
            color: AppColors.scorePerfect,
            onTap: () async { await Permission.microphone.request(); },
          ),
          const SizedBox(height: 12),
          _PermissionTile(
            icon: Icons.videocam_rounded,
            title: localeText(context, ko: '카메라', en: 'Camera'),
            desc: localeText(context, ko: '연주 자세 촬영 + AI 피드백', en: 'Capture posture + AI feedback'),
            color: AppColors.primary,
            onTap: () async { await Permission.camera.request(); },
          ),
          const SizedBox(height: 20),
          Text(localeText(context, ko: '나중에 설정에서도 변경할 수 있어요', en: 'You can change this in settings anytime'), style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  // ─── 8. 구독 안내 ───
  Widget _SubscriptionPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.workspace_premium_rounded, color: AppColors.accentGold, size: 48),
          const SizedBox(height: 20),
          Text(localeText(context, ko: '프리미엄으로\n더 많은 기능을!', en: 'Unlock more\nwith Premium!'), textAlign: TextAlign.center, style: TextStyle(color: AppColors.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _FeatureChip(icon: Icons.music_note_rounded, text: localeText(context, ko: '전체 악기 + 전체 레슨', en: 'All instruments + all lessons')),
          _FeatureChip(icon: Icons.auto_awesome_rounded, text: localeText(context, ko: '고급 AI 리포트 + 연습 루틴', en: 'Advanced AI reports + practice routines')),
          _FeatureChip(icon: Icons.create_rounded, text: localeText(context, ko: '나만의 음악 창작', en: 'Create your own music')),
          _FeatureChip(icon: Icons.block_rounded, text: localeText(context, ko: '광고 제거', en: 'Remove ads')),
          const SizedBox(height: 24),
          Text(localeText(context, ko: '관심 있으신가요?', en: 'Interested?'), style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _subscribeInterest = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _subscribeInterest ? AppColors.primary.withValues(alpha: 0.2) : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _subscribeInterest ? AppColors.primary : AppColors.bgSurface, width: 2),
                    ),
                    child: Center(child: Text(localeText(context, ko: '네, 관심 있어요', en: 'Yes, I\'m interested'), style: TextStyle(color: _subscribeInterest ? AppColors.primary : AppColors.textPrimary, fontWeight: FontWeight.w600))),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _subscribeInterest = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: !_subscribeInterest ? AppColors.bgCard : AppColors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: !_subscribeInterest ? AppColors.textSecondary : AppColors.bgSurface, width: 2),
                    ),
                    child: Center(child: Text(localeText(context, ko: '나중에요', en: 'Maybe later'), style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── 9. 축하 ───
  Widget _CelebratePage() {
    return Center(
      child: ScaleTransition(
        scale: _celebrateScale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 24),
            Text(localeText(context, ko: '환영합니다!', en: 'Welcome!'), style: TextStyle(color: AppColors.accent, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              _nickname.isNotEmpty
                  ? localeText(context, ko: '$_nickname님의\n음악 여정이 시작됩니다!', en: '$_nickname\'s\nmusical journey begins!')
                  : localeText(context, ko: '당신의\n음악 여정이 시작됩니다!', en: 'Your\nmusical journey begins!'),
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textPrimary, fontSize: 20, height: 1.5),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(7, (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _TwinkleStar(delay: i * 150),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 헬퍼 위젯들 ───

class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(color: AppColors.textPrimary, fontSize: 14))),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String step, title, desc;
  final IconData icon;
  const _StepCard({required this.step, required this.title, required this.desc, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Center(child: Text(step, style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                Text(desc, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Icon(icon, color: AppColors.primary, size: 22),
        ],
      ),
    );
  }
}

class _PermissionTile extends StatelessWidget {
  final IconData icon;
  final String title, desc;
  final Color color;
  final VoidCallback onTap;
  const _PermissionTile({required this.icon, required this.title, required this.desc, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  Text(desc, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Text(Localizations.localeOf(context).languageCode == 'en' ? 'Allow' : '허용', style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _TwinkleStar extends StatefulWidget {
  final int delay;
  const _TwinkleStar({required this.delay});

  @override
  State<_TwinkleStar> createState() => _TwinkleStarState();
}

class _TwinkleStarState extends State<_TwinkleStar> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Icon(
        Icons.star_rounded,
        size: 12 + _ctrl.value * 10,
        color: AppColors.accentGold.withValues(alpha: 0.3 + _ctrl.value * 0.7),
      ),
    );
  }
}
