import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../core/constants/app_colors.dart';
import '../../features/lesson/domain/models/lesson.dart';

/// VexFlow 기반 전문 악보 위젯
class VexFlowSheet extends StatefulWidget {
  final List<MusicNote> notes;
  final String? instrument;
  final double height;
  final List<bool>? hitResults; // AI 피드백 (적중/미스)
  final List<String>? annotations; // AI 텍스트 피드백
  final int? activeNoteIndex;
  final bool showLabels;
  final bool isDark;

  const VexFlowSheet({
    super.key,
    required this.notes,
    this.instrument,
    this.height = 250,
    this.hitResults,
    this.annotations,
    this.activeNoteIndex,
    this.showLabels = true,
    this.isDark = true,
  });

  @override
  State<VexFlowSheet> createState() => _VexFlowSheetState();
}

class _VexFlowSheetState extends State<VexFlowSheet> {
  InAppWebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.bgCard : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgSurface),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(13),
        child: InAppWebView(
          initialData: InAppWebViewInitialData(data: _generateHtml()),
          initialSettings: InAppWebViewSettings(
            transparentBackground: true,
            javaScriptEnabled: true,
            disableHorizontalScroll: false,
            disableVerticalScroll: true,
          ),
          onWebViewCreated: (controller) => _controller = controller,
        ),
      ),
    );
  }

  String _generateHtml() {
    final bgColor = widget.isDark ? '#21262D' : '#FFFFFF';
    final noteColor = widget.isDark ? '#E6EDF3' : '#1A1A2E';
    final staffColor = widget.isDark ? '#8B949E' : '#333333';

    // MusicNote → VexFlow 노트 변환
    final vexNotes = <String>[];
    for (int i = 0; i < widget.notes.length; i++) {
      final note = widget.notes[i];
      final vexName = _toVexName(note.noteName);
      final duration = _toDuration(note.duration);

      // 색상 (AI 피드백)
      String color = noteColor;
      if (widget.hitResults != null && i < widget.hitResults!.length) {
        color = widget.hitResults![i] ? '#3FB950' : '#E07070';
      } else if (widget.activeNoteIndex != null && i == widget.activeNoteIndex) {
        color = '#00BFA5';
      }

      // 어노테이션
      String annotation = '';
      if (widget.annotations != null && i < widget.annotations!.length && widget.annotations![i].isNotEmpty) {
        annotation = '.addModifier(new VF.Annotation("${widget.annotations![i]}").setFont("Arial", 10).setVerticalJustification(VF.Annotation.VerticalJustify.BOTTOM))';
      }

      vexNotes.add('''
        new VF.StaveNote({keys: ["$vexName"], duration: "$duration", stem_direction: ${_stemDirection(note.noteName)}})
          .setStyle({fillStyle: "$color", strokeStyle: "$color"})
          $annotation
      ''');
    }

    // 마디 분배 (4박자 기준)
    final measures = <List<String>>[];
    var currentMeasure = <String>[];
    double currentBeats = 0;
    for (int i = 0; i < widget.notes.length; i++) {
      currentMeasure.add(vexNotes[i]);
      currentBeats += widget.notes[i].duration;
      if (currentBeats >= 3.5 || i == widget.notes.length - 1) {
        measures.add(currentMeasure);
        currentMeasure = [];
        currentBeats = 0;
      }
    }

    final measuresJs = measures.asMap().entries.map((e) {
      final idx = e.key;
      final notes = e.value;
      return '''
        var stave$idx = new VF.Stave(${idx * 300}, 40, 280);
        ${idx == 0 ? 'stave$idx.addClef("treble").addTimeSignature("4/4");' : ''}
        stave$idx.setStyle({strokeStyle: "$staffColor", fillStyle: "$staffColor"});
        stave$idx.setContext(context).draw();
        var notes$idx = [${notes.join(',')}];
        VF.Formatter.FormatAndDraw(context, stave$idx, notes$idx);
      ''';
    }).join('\n');

    final totalWidth = measures.length * 300 + 50;

    return '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes">
<script src="https://cdn.jsdelivr.net/npm/vexflow@4.2.6/build/cjs/vexflow.js"></script>
<style>
  body { margin: 0; padding: 8px; background: $bgColor; overflow-x: auto; overflow-y: hidden; }
  #output { width: ${totalWidth}px; height: 180px; }
</style>
</head>
<body>
<div id="output"></div>
<script>
  const VF = Vex.Flow;
  const div = document.getElementById("output");
  const renderer = new VF.Renderer(div, VF.Renderer.Backends.SVG);
  renderer.resize($totalWidth, 180);
  const context = renderer.getContext();
  context.setFont("Arial", 12);

  $measuresJs
</script>
</body>
</html>
''';
  }

  String _toVexName(String noteName) {
    // 드럼 처리
    if (noteName == '킥' || noteName == '스네어' || noteName == '하이햇') {
      return 'c/5';
    }

    // C4 → c/4, D#4 → d#/4, F5 → f/5
    final clean = noteName.replaceAll('♯', '#').replaceAll('♭', 'b');
    final match = RegExp(r'([A-Ga-g][#b]?)(\d)').firstMatch(clean);
    if (match != null) {
      return '${match.group(1)!.toLowerCase()}/${match.group(2)}';
    }
    return 'c/4';
  }

  String _toDuration(double dur) {
    if (dur >= 3.0) return 'w';   // 온음표
    if (dur >= 1.5) return 'h';   // 2분음표
    if (dur >= 0.7) return 'q';   // 4분음표
    if (dur >= 0.35) return '8';  // 8분음표
    return '16';                   // 16분음표
  }

  int _stemDirection(String noteName) {
    // B4 이상이면 줄기 아래로
    final match = RegExp(r'(\d)').firstMatch(noteName);
    if (match != null) {
      final octave = int.tryParse(match.group(1)!) ?? 4;
      return octave >= 5 ? -1 : 1;
    }
    return 1;
  }
}
