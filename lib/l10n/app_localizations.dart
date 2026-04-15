import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'SynthTune Music'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get home;

  /// No description provided for @lessons.
  ///
  /// In ko, this message translates to:
  /// **'레슨'**
  String get lessons;

  /// No description provided for @progress.
  ///
  /// In ko, this message translates to:
  /// **'진도'**
  String get progress;

  /// No description provided for @community.
  ///
  /// In ko, this message translates to:
  /// **'커뮤니티'**
  String get community;

  /// No description provided for @ai.
  ///
  /// In ko, this message translates to:
  /// **'AI'**
  String get ai;

  /// No description provided for @settings.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settings;

  /// No description provided for @login.
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get login;

  /// No description provided for @register.
  ///
  /// In ko, this message translates to:
  /// **'회원가입'**
  String get register;

  /// No description provided for @loginWithGoogle.
  ///
  /// In ko, this message translates to:
  /// **'Google로 계속하기'**
  String get loginWithGoogle;

  /// No description provided for @loginWithEmail.
  ///
  /// In ko, this message translates to:
  /// **'이메일로 로그인'**
  String get loginWithEmail;

  /// No description provided for @email.
  ///
  /// In ko, this message translates to:
  /// **'이메일'**
  String get email;

  /// No description provided for @password.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호 확인'**
  String get confirmPassword;

  /// No description provided for @name.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get name;

  /// No description provided for @createAccount.
  ///
  /// In ko, this message translates to:
  /// **'계정 만들기'**
  String get createAccount;

  /// No description provided for @startAiMusic.
  ///
  /// In ko, this message translates to:
  /// **'AI 음악 교육을 시작해보세요'**
  String get startAiMusic;

  /// No description provided for @welcomeBack.
  ///
  /// In ko, this message translates to:
  /// **'다시 오셨군요!'**
  String get welcomeBack;

  /// No description provided for @continueToLesson.
  ///
  /// In ko, this message translates to:
  /// **'계속 연습하러 들어오세요'**
  String get continueToLesson;

  /// No description provided for @noAccount.
  ///
  /// In ko, this message translates to:
  /// **'계정이 없으신가요?'**
  String get noAccount;

  /// No description provided for @hasAccount.
  ///
  /// In ko, this message translates to:
  /// **'이미 계정이 있으신가요?'**
  String get hasAccount;

  /// No description provided for @signUp.
  ///
  /// In ko, this message translates to:
  /// **'가입하기'**
  String get signUp;

  /// No description provided for @logout.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get logout;

  /// No description provided for @deleteAccount.
  ///
  /// In ko, this message translates to:
  /// **'회원탈퇴'**
  String get deleteAccount;

  /// No description provided for @logoutConfirm.
  ///
  /// In ko, this message translates to:
  /// **'정말 로그아웃 하시겠습니까?'**
  String get logoutConfirm;

  /// No description provided for @deleteConfirm.
  ///
  /// In ko, this message translates to:
  /// **'탈퇴하면 모든 학습 기록과 데이터가 영구적으로 삭제됩니다.\n정말 탈퇴하시겠습니까?'**
  String get deleteConfirm;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @chooseInstrument.
  ///
  /// In ko, this message translates to:
  /// **'어떤 악기를\n배우고 싶으신가요?'**
  String get chooseInstrument;

  /// No description provided for @changeAnytime.
  ///
  /// In ko, this message translates to:
  /// **'나중에 언제든지 변경할 수 있어요'**
  String get changeAnytime;

  /// No description provided for @currentLevel.
  ///
  /// In ko, this message translates to:
  /// **'현재 실력은\n어느 정도인가요?'**
  String get currentLevel;

  /// No description provided for @piano.
  ///
  /// In ko, this message translates to:
  /// **'피아노'**
  String get piano;

  /// No description provided for @guitar.
  ///
  /// In ko, this message translates to:
  /// **'기타'**
  String get guitar;

  /// No description provided for @drums.
  ///
  /// In ko, this message translates to:
  /// **'드럼'**
  String get drums;

  /// No description provided for @violin.
  ///
  /// In ko, this message translates to:
  /// **'바이올린'**
  String get violin;

  /// No description provided for @beginner.
  ///
  /// In ko, this message translates to:
  /// **'입문자'**
  String get beginner;

  /// No description provided for @intermediate.
  ///
  /// In ko, this message translates to:
  /// **'중급자'**
  String get intermediate;

  /// No description provided for @advanced.
  ///
  /// In ko, this message translates to:
  /// **'고급자'**
  String get advanced;

  /// No description provided for @beginnerDesc.
  ///
  /// In ko, this message translates to:
  /// **'악기를 처음 시작해요'**
  String get beginnerDesc;

  /// No description provided for @intermediateDesc.
  ///
  /// In ko, this message translates to:
  /// **'기초는 알고 있어요'**
  String get intermediateDesc;

  /// No description provided for @advancedDesc.
  ///
  /// In ko, this message translates to:
  /// **'어느 정도 실력이 있어요'**
  String get advancedDesc;

  /// No description provided for @start.
  ///
  /// In ko, this message translates to:
  /// **'시작하기'**
  String get start;

  /// No description provided for @allCategory.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get allCategory;

  /// No description provided for @scaleCategory.
  ///
  /// In ko, this message translates to:
  /// **'기본 스케일'**
  String get scaleCategory;

  /// No description provided for @nurseryCategory.
  ///
  /// In ko, this message translates to:
  /// **'동요'**
  String get nurseryCategory;

  /// No description provided for @classicCategory.
  ///
  /// In ko, this message translates to:
  /// **'클래식'**
  String get classicCategory;

  /// No description provided for @skillCategory.
  ///
  /// In ko, this message translates to:
  /// **'스킬'**
  String get skillCategory;

  /// No description provided for @myMusicCategory.
  ///
  /// In ko, this message translates to:
  /// **'나만의 음악'**
  String get myMusicCategory;

  /// No description provided for @practiceStart.
  ///
  /// In ko, this message translates to:
  /// **'연습 시작'**
  String get practiceStart;

  /// No description provided for @recording.
  ///
  /// In ko, this message translates to:
  /// **'녹음 중'**
  String get recording;

  /// No description provided for @analyzing.
  ///
  /// In ko, this message translates to:
  /// **'AI가 연주를 분석하고 있습니다...'**
  String get analyzing;

  /// No description provided for @readyToRecord.
  ///
  /// In ko, this message translates to:
  /// **'준비가 되면\n녹음 버튼을 누르세요'**
  String get readyToRecord;

  /// No description provided for @micReady.
  ///
  /// In ko, this message translates to:
  /// **'마이크 준비됨'**
  String get micReady;

  /// No description provided for @getReady.
  ///
  /// In ko, this message translates to:
  /// **'준비하세요!'**
  String get getReady;

  /// No description provided for @startRecording.
  ///
  /// In ko, this message translates to:
  /// **'녹음 시작'**
  String get startRecording;

  /// No description provided for @stopRecording.
  ///
  /// In ko, this message translates to:
  /// **'녹음 중지'**
  String get stopRecording;

  /// No description provided for @aiAnalyzing.
  ///
  /// In ko, this message translates to:
  /// **'AI 분석 중...'**
  String get aiAnalyzing;

  /// No description provided for @retry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get retry;

  /// No description provided for @backToLesson.
  ///
  /// In ko, this message translates to:
  /// **'레슨으로 돌아가기'**
  String get backToLesson;

  /// No description provided for @practiceResult.
  ///
  /// In ko, this message translates to:
  /// **'연습 결과'**
  String get practiceResult;

  /// No description provided for @noteAccuracy.
  ///
  /// In ko, this message translates to:
  /// **'음정 적중'**
  String get noteAccuracy;

  /// No description provided for @avgAccuracy.
  ///
  /// In ko, this message translates to:
  /// **'평균 정확도'**
  String get avgAccuracy;

  /// No description provided for @xpEarned.
  ///
  /// In ko, this message translates to:
  /// **'획득 XP'**
  String get xpEarned;

  /// No description provided for @noteByNote.
  ///
  /// In ko, this message translates to:
  /// **'음표별 결과'**
  String get noteByNote;

  /// No description provided for @tryAgain.
  ///
  /// In ko, this message translates to:
  /// **'다시 연습'**
  String get tryAgain;

  /// No description provided for @subscription.
  ///
  /// In ko, this message translates to:
  /// **'구독 플랜'**
  String get subscription;

  /// No description provided for @currentPlan.
  ///
  /// In ko, this message translates to:
  /// **'현재 플랜'**
  String get currentPlan;

  /// No description provided for @free.
  ///
  /// In ko, this message translates to:
  /// **'무료'**
  String get free;

  /// No description provided for @standard.
  ///
  /// In ko, this message translates to:
  /// **'스탠다드'**
  String get standard;

  /// No description provided for @premium.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄'**
  String get premium;

  /// No description provided for @studentDiscount.
  ///
  /// In ko, this message translates to:
  /// **'학생 할인'**
  String get studentDiscount;

  /// No description provided for @upgrade.
  ///
  /// In ko, this message translates to:
  /// **'업그레이드'**
  String get upgrade;

  /// No description provided for @premiumFeature.
  ///
  /// In ko, this message translates to:
  /// **'프리미엄 기능'**
  String get premiumFeature;

  /// No description provided for @communityPractice.
  ///
  /// In ko, this message translates to:
  /// **'연습 기록'**
  String get communityPractice;

  /// No description provided for @communityQna.
  ///
  /// In ko, this message translates to:
  /// **'Q&A'**
  String get communityQna;

  /// No description provided for @communityNotice.
  ///
  /// In ko, this message translates to:
  /// **'공지사항'**
  String get communityNotice;

  /// No description provided for @communityFeedback.
  ///
  /// In ko, this message translates to:
  /// **'문의·의견'**
  String get communityFeedback;

  /// No description provided for @newPost.
  ///
  /// In ko, this message translates to:
  /// **'새 게시글'**
  String get newPost;

  /// No description provided for @comment.
  ///
  /// In ko, this message translates to:
  /// **'댓글'**
  String get comment;

  /// No description provided for @share.
  ///
  /// In ko, this message translates to:
  /// **'공유'**
  String get share;

  /// No description provided for @photo.
  ///
  /// In ko, this message translates to:
  /// **'사진'**
  String get photo;

  /// No description provided for @video.
  ///
  /// In ko, this message translates to:
  /// **'동영상'**
  String get video;

  /// No description provided for @audio.
  ///
  /// In ko, this message translates to:
  /// **'음성'**
  String get audio;

  /// No description provided for @aiTeacher.
  ///
  /// In ko, this message translates to:
  /// **'AI 음악 선생님'**
  String get aiTeacher;

  /// No description provided for @typeMessage.
  ///
  /// In ko, this message translates to:
  /// **'메시지를 입력하세요...'**
  String get typeMessage;

  /// No description provided for @chatSettings.
  ///
  /// In ko, this message translates to:
  /// **'대화 설정'**
  String get chatSettings;

  /// No description provided for @chatHistory.
  ///
  /// In ko, this message translates to:
  /// **'대화 내역'**
  String get chatHistory;

  /// No description provided for @deleteChatHistory.
  ///
  /// In ko, this message translates to:
  /// **'대화 내역 삭제'**
  String get deleteChatHistory;

  /// No description provided for @retentionPeriod.
  ///
  /// In ko, this message translates to:
  /// **'대화 저장 기간'**
  String get retentionPeriod;

  /// No description provided for @aiTone.
  ///
  /// In ko, this message translates to:
  /// **'AI 말투'**
  String get aiTone;

  /// No description provided for @toneFriendly.
  ///
  /// In ko, this message translates to:
  /// **'친근한 반말'**
  String get toneFriendly;

  /// No description provided for @tonePolite.
  ///
  /// In ko, this message translates to:
  /// **'존댓말'**
  String get tonePolite;

  /// No description provided for @toneTeacher.
  ///
  /// In ko, this message translates to:
  /// **'선생님'**
  String get toneTeacher;

  /// No description provided for @toneCasual.
  ///
  /// In ko, this message translates to:
  /// **'캐주얼'**
  String get toneCasual;

  /// No description provided for @themeAndStyle.
  ///
  /// In ko, this message translates to:
  /// **'테마 및 스타일'**
  String get themeAndStyle;

  /// No description provided for @appTheme.
  ///
  /// In ko, this message translates to:
  /// **'앱 테마'**
  String get appTheme;

  /// No description provided for @fontSetting.
  ///
  /// In ko, this message translates to:
  /// **'글꼴'**
  String get fontSetting;

  /// No description provided for @sheetStyle.
  ///
  /// In ko, this message translates to:
  /// **'악보 스타일'**
  String get sheetStyle;

  /// No description provided for @themeSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템'**
  String get themeSystem;

  /// No description provided for @themeDark.
  ///
  /// In ko, this message translates to:
  /// **'다크'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In ko, this message translates to:
  /// **'라이트'**
  String get themeLight;

  /// No description provided for @themeMidnight.
  ///
  /// In ko, this message translates to:
  /// **'미드나잇'**
  String get themeMidnight;

  /// No description provided for @themeForest.
  ///
  /// In ko, this message translates to:
  /// **'포레스트'**
  String get themeForest;

  /// No description provided for @micPermission.
  ///
  /// In ko, this message translates to:
  /// **'마이크 권한'**
  String get micPermission;

  /// No description provided for @micPermissionDesc.
  ///
  /// In ko, this message translates to:
  /// **'연습 시 연주를 녹음하고\nAI가 음정을 실시간 분석합니다.'**
  String get micPermissionDesc;

  /// No description provided for @micPermissionWhy.
  ///
  /// In ko, this message translates to:
  /// **'정확한 피드백을 위해 필요해요'**
  String get micPermissionWhy;

  /// No description provided for @cameraPermission.
  ///
  /// In ko, this message translates to:
  /// **'카메라 권한'**
  String get cameraPermission;

  /// No description provided for @cameraPermissionDesc.
  ///
  /// In ko, this message translates to:
  /// **'연습 중 연주 자세를 촬영하여\nAI가 자세 피드백을 제공합니다.'**
  String get cameraPermissionDesc;

  /// No description provided for @cameraPermissionWhy.
  ///
  /// In ko, this message translates to:
  /// **'자세 분석 및 녹화를 위해 필요해요'**
  String get cameraPermissionWhy;

  /// No description provided for @allow.
  ///
  /// In ko, this message translates to:
  /// **'허용'**
  String get allow;

  /// No description provided for @later.
  ///
  /// In ko, this message translates to:
  /// **'나중에 하기'**
  String get later;

  /// No description provided for @skip.
  ///
  /// In ko, this message translates to:
  /// **'건너뛰기'**
  String get skip;

  /// No description provided for @granted.
  ///
  /// In ko, this message translates to:
  /// **'허용됨'**
  String get granted;

  /// No description provided for @advancedReport.
  ///
  /// In ko, this message translates to:
  /// **'고급 리포트'**
  String get advancedReport;

  /// No description provided for @save.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get save;

  /// No description provided for @compose.
  ///
  /// In ko, this message translates to:
  /// **'악보 만들기'**
  String get compose;

  /// No description provided for @saveAsMyMusic.
  ///
  /// In ko, this message translates to:
  /// **'내 곡으로 저장'**
  String get saveAsMyMusic;

  /// No description provided for @shareToComm.
  ///
  /// In ko, this message translates to:
  /// **'커뮤니티에 공유'**
  String get shareToComm;

  /// No description provided for @enterTitle.
  ///
  /// In ko, this message translates to:
  /// **'제목을 입력해주세요'**
  String get enterTitle;

  /// No description provided for @studentVerify.
  ///
  /// In ko, this message translates to:
  /// **'학생 인증'**
  String get studentVerify;

  /// No description provided for @schoolEmail.
  ///
  /// In ko, this message translates to:
  /// **'학교 이메일'**
  String get schoolEmail;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
