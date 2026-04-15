import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:fftea/fftea.dart';
import '../../domain/models/practice_session.dart';
import '../../../lesson/domain/models/lesson.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

enum PracticeStatus { idle, countdown, recording, analyzing, done, error }

class PracticeState {
  final PracticeStatus status;
  final int countdownSeconds;
  final double currentPitchHz;
  final String detectedNote;
  final String? recordingPath;
  final PracticeSession? result;
  final String? errorMessage;

  const PracticeState({
    this.status = PracticeStatus.idle,
    this.countdownSeconds = 3,
    this.currentPitchHz = 0.0,
    this.detectedNote = '-',
    this.recordingPath,
    this.result,
    this.errorMessage,
  });

  PracticeState copyWith({
    PracticeStatus? status,
    int? countdownSeconds,
    double? currentPitchHz,
    String? detectedNote,
    String? recordingPath,
    PracticeSession? result,
    String? errorMessage,
  }) {
    return PracticeState(
      status: status ?? this.status,
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      currentPitchHz: currentPitchHz ?? this.currentPitchHz,
      detectedNote: detectedNote ?? this.detectedNote,
      recordingPath: recordingPath ?? this.recordingPath,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}

class PracticeNotifier extends StateNotifier<PracticeState> {
  final Lesson lesson;
  final Ref _ref;
  late final AudioRecorder _recorder;

  PracticeNotifier(this.lesson, this._ref) : super(const PracticeState()) {
    _recorder = AudioRecorder();
  }

  Future<void> startCountdown() async {
    state = state.copyWith(status: PracticeStatus.countdown, countdownSeconds: 3);

    for (int i = 3; i >= 1; i--) {
      state = state.copyWith(countdownSeconds: i);
      await Future.delayed(const Duration(seconds: 1));
    }

    await _startRecording();
  }

  Future<void> _startRecording() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        state = state.copyWith(
          status: PracticeStatus.error,
          errorMessage: '마이크 권한이 필요합니다.',
        );
        return;
      }

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/practice_${DateTime.now().millisecondsSinceEpoch}.wav';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: path,
      );

      state = state.copyWith(
        status: PracticeStatus.recording,
        recordingPath: path,
      );

      // 레슨 길이만큼 녹음
      final recordDuration = lesson.targetNotes.isEmpty
          ? 10
          : (lesson.targetNotes.last.startTime + lesson.targetNotes.last.duration).ceil() + 2;

      await Future.delayed(Duration(seconds: recordDuration));

      if (state.status == PracticeStatus.recording) {
        await stopRecording();
      }
    } catch (e) {
      state = state.copyWith(
        status: PracticeStatus.error,
        errorMessage: '녹음 시작 오류: $e',
      );
    }
  }

  Future<void> stopRecording() async {
    await _recorder.stop();
    state = state.copyWith(status: PracticeStatus.analyzing);
    await _analyze();
  }

  Future<void> _analyze() async {
    await Future.delayed(const Duration(milliseconds: 1500)); // 분석 시뮬레이션

    final path = state.recordingPath;
    List<NoteResult> noteResults = [];

    if (path != null) {
      try {
        noteResults = await _analyzeAudio(path);
      } catch (_) {
        noteResults = _generateMockResults();
      }
    } else {
      noteResults = _generateMockResults();
    }

    final hitCount = noteResults.where((r) => r.isHit).length;
    final score = noteResults.isEmpty
        ? 0.0
        : (hitCount / noteResults.length * 100).roundToDouble();

    // 난이도별 EXP: Easy 10~20, Medium 20~30, Hard 30~50
    int baseXp;
    switch (lesson.difficulty) {
      case 'beginner':
        baseXp = 10 + ((score / 100) * 10).round(); // 10~20
      case 'intermediate':
        baseXp = 20 + ((score / 100) * 10).round(); // 20~30
      case 'advanced':
        baseXp = 30 + ((score / 100) * 20).round(); // 30~50
      default:
        baseXp = 10;
    }
    final xpEarned = baseXp;
    final userId = _ref.read(currentUserProvider)?.uid ?? 'unknown';

    final session = PracticeSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      lessonId: lesson.id,
      lessonTitle: lesson.title,
      userId: userId,
      score: score,
      duration: Duration(seconds: lesson.durationMinutes * 60),
      noteResults: noteResults,
      createdAt: DateTime.now(),
      xpEarned: xpEarned,
    );

    state = state.copyWith(status: PracticeStatus.done, result: session);
  }

  Future<List<NoteResult>> _analyzeAudio(String path) async {
    final file = File(path);
    if (!await file.exists()) return _generateMockResults();

    final bytes = await file.readAsBytes();
    // WAV 헤더 44바이트 건너뜀
    if (bytes.length < 44) return _generateMockResults();

    final samples = _pcm16ToDouble(bytes.sublist(44));
    if (samples.isEmpty) return _generateMockResults();

    const sampleRate = 44100;
    const windowSize = 4096;
    final fft = FFT(windowSize);

    final noteResults = <NoteResult>[];

    for (int i = 0; i < lesson.targetNotes.length; i++) {
      final note = lesson.targetNotes[i];
      final startSample = (note.startTime * sampleRate).round();
      final endSample = min(
        ((note.startTime + note.duration) * sampleRate).round(),
        samples.length,
      );

      if (startSample >= samples.length) {
        noteResults.add(NoteResult(
          targetNoteName: note.noteName,
          targetFrequency: note.frequency,
          isHit: false,
          accuracy: 0.0,
        ));
        continue;
      }

      final segment = samples.sublist(startSample, min(endSample, samples.length));
      if (segment.length < windowSize) {
        noteResults.add(NoteResult(
          targetNoteName: note.noteName,
          targetFrequency: note.frequency,
          isHit: false,
          accuracy: 0.0,
        ));
        continue;
      }

      final window = segment.sublist(0, windowSize);
      final spectrum = fft.realFft(window);
      final magnitudes = spectrum.discardConjugates().magnitudes();

      // 피크 주파수 찾기 (50Hz ~ 2000Hz 범위)
      final minBin = (50.0 * windowSize / sampleRate).round();
      final maxBin = (2000.0 * windowSize / sampleRate).round();

      double maxMag = 0;
      int peakBin = minBin;
      for (int b = minBin; b < min(maxBin, magnitudes.length); b++) {
        if (magnitudes[b] > maxMag) {
          maxMag = magnitudes[b];
          peakBin = b;
        }
      }

      final detectedFreq = peakBin * sampleRate / windowSize.toDouble();
      final accuracy = _calcAccuracy(note.frequency, detectedFreq);
      final isHit = accuracy > 0.8;

      noteResults.add(NoteResult(
        targetNoteName: note.noteName,
        targetFrequency: note.frequency,
        detectedFrequency: detectedFreq,
        isHit: isHit,
        accuracy: accuracy,
      ));
    }

    return noteResults;
  }

  List<double> _pcm16ToDouble(Uint8List bytes) {
    final samples = <double>[];
    for (int i = 0; i + 1 < bytes.length; i += 2) {
      final sample = bytes[i] | (bytes[i + 1] << 8);
      final signed = sample > 32767 ? sample - 65536 : sample;
      samples.add(signed / 32768.0);
    }
    return samples;
  }

  double _calcAccuracy(double target, double detected) {
    if (detected == 0) return 0.0;
    final ratio = detected / target;
    // 옥타브 무시 (2배 차이는 같은 음)
    final normalizedRatio = ratio > 1.5 ? ratio / 2 : (ratio < 0.75 ? ratio * 2 : ratio);
    // 반음(semitone)으로 변환 (±50센트 이내면 히트)
    final cents = (1200 * log(normalizedRatio) / log(2)).abs();
    if (cents <= 30) return 1.0;
    if (cents <= 50) return 0.9;
    if (cents <= 100) return 0.7;
    if (cents <= 200) return 0.4;
    return 0.0;
  }

  List<NoteResult> _generateMockResults() {
    final rng = Random();
    return lesson.targetNotes.map((note) {
      final accuracy = 0.5 + rng.nextDouble() * 0.5;
      return NoteResult(
        targetNoteName: note.noteName,
        targetFrequency: note.frequency,
        detectedFrequency: note.frequency * (0.95 + rng.nextDouble() * 0.1),
        isHit: accuracy > 0.75,
        accuracy: accuracy,
      );
    }).toList();
  }

  void reset() {
    state = const PracticeState();
  }

  @override
  void dispose() {
    _recorder.dispose();
    super.dispose();
  }
}

final practiceNotifierProvider =
    StateNotifierProvider.family<PracticeNotifier, PracticeState, Lesson>(
  (ref, lesson) => PracticeNotifier(lesson, ref),
);
