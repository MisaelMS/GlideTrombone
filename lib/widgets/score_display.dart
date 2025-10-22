import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Classe para representar uma nota musical
class MusicalNote {
  final String note;
  final String? displayName;
  final double? duration;
  final bool isRest;
  final Map<String, dynamic>? metadata;
  final String? position;

  const MusicalNote({
    required this.note,
    this.displayName,
    this.duration = 1.0,
    this.isRest = false,
    this.metadata,
    this.position,
  });

  factory MusicalNote.rest({double duration = 1.0}) {
    return MusicalNote(
      note: '',
      duration: duration,
      isRest: true,
    );
  }

  String get name => displayName ?? note;
}

/// Widget principal para exibição da partitura com scroll
class ScoreDisplayWidget extends StatefulWidget {
  final List<MusicalNote> notes;
  final int currentNoteIndex;
  final String detectedNote;
  final double accuracy;
  final bool isListening;
  final Animation<Color?>? accuracyAnimation;
  final Animation<double>? progressAnimation;
  final String title;
  final String keySignature;
  final String timeSignature;
  final int? tempo;
  final bool showKeySignature;
  final bool showTimeSignature;

  const ScoreDisplayWidget({
    Key? key,
    required this.notes,
    this.currentNoteIndex = 0,
    this.detectedNote = '',
    this.accuracy = 0.0,
    this.isListening = false,
    this.accuracyAnimation,
    this.progressAnimation,
    this.title = '',
    this.keySignature = 'C',
    this.timeSignature = '4/4',
    this.tempo,
    this.showKeySignature = true,
    this.showTimeSignature = true,
  }) : super(key: key);

  @override
  State<ScoreDisplayWidget> createState() => _ScoreDisplayWidgetState();
}

class _ScoreDisplayWidgetState extends State<ScoreDisplayWidget> {
  final ScrollController _scrollController = ScrollController();

  double get beatsPerMeasure {
    final parts = widget.timeSignature.split('/');
    if (parts.length == 2) {
      return double.tryParse(parts[0]) ?? 4.0;
    }
    return 4.0;
  }

  @override
  void didUpdateWidget(ScoreDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.currentNoteIndex != oldWidget.currentNoteIndex) {
      _autoScroll();
    }
  }

  void _autoScroll() {
    if (!_scrollController.hasClients) return;

    double accumulatedBeats = 0;
    for (int i = 0; i < widget.currentNoteIndex && i < widget.notes.length; i++) {
      accumulatedBeats += widget.notes[i].duration ?? 1.0;
    }

    int currentMeasure = (accumulatedBeats / beatsPerMeasure).floor();
    double targetScroll = currentMeasure * 300.0; // 300 = largura aproximada do compasso

    _scrollController.animateTo(
      targetScroll,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double totalBeats = 0;
    for (var note in widget.notes) {
      totalBeats += note.duration ?? 1.0;
    }

    int totalMeasures = (totalBeats / beatsPerMeasure).ceil();
    double totalWidth = math.max(totalMeasures * 300.0 + 150, MediaQuery.of(context).size.width - 40);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: CustomPaint(
            painter: ScoreDisplayPainter(
              notes: widget.notes,
              currentNoteIndex: widget.currentNoteIndex,
              detectedNote: widget.detectedNote,
              accuracy: widget.accuracy,
              isListening: widget.isListening,
              accuracyColor: widget.accuracyAnimation?.value,
              progress: widget.progressAnimation?.value ?? 0.0,
              title: widget.title,
              keySignature: widget.keySignature,
              timeSignature: widget.timeSignature,
              showKeySignature: widget.showKeySignature,
              showTimeSignature: widget.showTimeSignature,
              beatsPerMeasure: beatsPerMeasure,
            ),
            child: Container(),
          ),
        ),
      ),
    );
  }
}

/// Painter personalizado para desenhar a partitura
class ScoreDisplayPainter extends CustomPainter {
  final List<MusicalNote> notes;
  final int currentNoteIndex;
  final String detectedNote;
  final double accuracy;
  final bool isListening;
  final Color? accuracyColor;
  final double progress;
  final String title;
  final String keySignature;
  final String timeSignature;
  final bool showKeySignature;
  final bool showTimeSignature;
  final double beatsPerMeasure;

  static const double BEAT_WIDTH = 50.0;

  ScoreDisplayPainter({
    required this.notes,
    required this.currentNoteIndex,
    required this.detectedNote,
    required this.accuracy,
    required this.isListening,
    required this.accuracyColor,
    required this.progress,
    required this.title,
    required this.keySignature,
    required this.timeSignature,
    required this.showKeySignature,
    required this.showTimeSignature,
    required this.beatsPerMeasure,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (notes.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 1.5
      ..color = Colors.black87
      ..style = PaintingStyle.stroke;

    final height = size.height;
    final staffTop = height * 0.5;
    final staffHeight = height * 0.35;
    final lineSpacing = staffHeight / 4;
    final staffBottom = staffTop + staffHeight;

    if (title.isNotEmpty) {
      _drawTitle(canvas, size);
    }

    double currentX = 40.0;
    double measureStartX = currentX;

    // Desenhar pauta inicial (antes da clave)
    double firstMeasureWidth = (beatsPerMeasure * BEAT_WIDTH) + 200;
    _drawStaff(canvas, staffTop, lineSpacing, measureStartX, measureStartX + firstMeasureWidth, paint);

    // Desenhar clave, armadura e fórmula de compasso no início
    _drawBassClef(canvas, currentX, staffTop, lineSpacing);
    currentX += 55;

    if (showKeySignature && keySignature != 'C') {
      currentX += _drawKeySignature(canvas, currentX, staffTop, lineSpacing, paint);
    }

    if (showTimeSignature) {
      currentX += _drawTimeSignature(canvas, currentX, staffTop, lineSpacing, paint);
    }

    // Linha inicial do primeiro compasso
    canvas.drawLine(
      Offset(currentX, staffTop),
      Offset(currentX, staffBottom),
      Paint()..color = Colors.black87..strokeWidth = 2,
    );
    currentX += 15;

    double currentMeasureBeats = 0;
    int measureCount = 1;

    for (int i = 0; i < notes.length; i++) {
      final note = notes[i];
      final noteDuration = note.duration ?? 1.0;
      final isActive = i == currentNoteIndex;
      final isPassed = i < currentNoteIndex;

      if (currentMeasureBeats + noteDuration > beatsPerMeasure + 0.01) {
        double remainingSpace = (beatsPerMeasure - currentMeasureBeats) * BEAT_WIDTH;
        currentX += remainingSpace;

        canvas.drawLine(
          Offset(currentX, staffTop),
          Offset(currentX, staffBottom),
          Paint()..color = Colors.black87..strokeWidth = 1.5,
        );
        currentX += 15;

        measureStartX = currentX;
        currentMeasureBeats = 0;
        measureCount++;

        double measureWidth = beatsPerMeasure * BEAT_WIDTH + 40;
        _drawStaff(canvas, staffTop, lineSpacing, currentX - 15, currentX + measureWidth, paint);
      }

      double noteWidth = noteDuration * BEAT_WIDTH;
      double noteX = currentX + (noteWidth * 0.3);

      if (note.isRest) {
        _drawRest(canvas, noteX, staffTop, lineSpacing, noteDuration, isActive, isPassed);
      } else {
        _drawNote(canvas, note, noteX, staffTop, lineSpacing, isActive, isPassed, paint);
      }

      if (isActive && isListening) {
        _drawActiveIndicator(canvas, noteX, staffTop, lineSpacing);

        if (detectedNote.isNotEmpty && detectedNote != note.note) {
          _drawDetectedNote(canvas, detectedNote, noteX + 30, staffTop, lineSpacing);
        }
      }

      if (isActive && isListening && progress > 0) {
        _drawProgressIndicator(canvas, noteX, staffTop, lineSpacing, progress);
      }

      currentX += noteWidth;
      currentMeasureBeats += noteDuration;
    }

    double finalBarX = currentX + ((beatsPerMeasure - currentMeasureBeats) * BEAT_WIDTH);
    canvas.drawLine(
      Offset(finalBarX, staffTop),
      Offset(finalBarX, staffBottom),
      Paint()..color = Colors.black87..strokeWidth = 1.5,
    );
    canvas.drawLine(
      Offset(finalBarX + 5, staffTop),
      Offset(finalBarX + 5, staffBottom),
      Paint()..color = Colors.black87..strokeWidth = 3,
    );
  }

  void _drawTitle(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(40, 15));
  }

  void _drawStaff(Canvas canvas, double top, double lineSpacing, double startX, double endX, Paint paint) {
    paint.strokeWidth = 1.5;
    for (int i = 0; i < 5; i++) {
      final y = top + (i * lineSpacing);
      canvas.drawLine(Offset(startX, y), Offset(endX, y), paint);
    }
  }

  void _drawBassClef(Canvas canvas, double x, double staffTop, double lineSpacing) {
    final clefPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final clefY = staffTop + (lineSpacing);

    final path = Path();

    path.moveTo(x + 5, clefY + 15);

    path.cubicTo(
        x + 15, clefY + 15,
        x + 20, clefY + 8,
        x + 20, clefY
    );

    path.cubicTo(
        x + 20, clefY - 8,
        x + 15, clefY - 15,
        x + 5, clefY - 15
    );

    path.cubicTo(
        x, clefY - 12,
        x + 5, clefY,
        x + 12, clefY + 2
    );

    path.cubicTo(
        x + 20, clefY - 5,
        x + 10, clefY - 3,
        x + 8, clefY
    );

    canvas.drawPath(path, clefPaint);

    final dotPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x + 30, staffTop + lineSpacing * 0.7), 3, dotPaint);
    canvas.drawCircle(Offset(x + 30, staffTop + lineSpacing * 1.3), 3, dotPaint);
  }

  double _drawKeySignature(Canvas canvas, double x, double staffTop, double lineSpacing, Paint paint) {
    double width = 0;

    switch (keySignature) {
      case 'Bb':
        _drawFlat(canvas, x, staffTop + lineSpacing * 3, paint);
        _drawFlat(canvas, x + 18, staffTop + (lineSpacing * 1.5), paint);
        width = 40;
        break;
      case 'Eb':
        _drawFlat(canvas, x, staffTop + lineSpacing * 3, paint);
        _drawFlat(canvas, x + 15, staffTop + (lineSpacing * 1.5), paint);
        _drawFlat(canvas, x + 30, staffTop + (lineSpacing * 3.5), paint);
        width = 50;
        break;
      case 'Ab':
        _drawFlat(canvas, x, staffTop + lineSpacing * 3, paint);
        _drawFlat(canvas, x + 15, staffTop + (lineSpacing * 1.5), paint);
        _drawFlat(canvas, x + 30, staffTop + (lineSpacing * 3.5), paint);
        _drawFlat(canvas, x + 45, staffTop + (lineSpacing * 2), paint);
        width = 65;
        break;
      case 'F':
        _drawFlat(canvas, x, staffTop + lineSpacing * 3, paint);
        width = 20;
        break;
      case 'G':
        _drawSharp(canvas, x, staffTop + lineSpacing, paint);
        width = 20;
        break;
      case 'D':
        _drawSharp(canvas, x, staffTop + lineSpacing, paint);
        _drawSharp(canvas, x + 15, staffTop + (lineSpacing * 2.5), paint);
        width = 35;
        break;
      case 'A':
        _drawSharp(canvas, x, staffTop + lineSpacing, paint);
        _drawSharp(canvas, x + 15, staffTop + (lineSpacing * 2.5), paint);
        _drawSharp(canvas, x + 30, staffTop + (lineSpacing * 0.5), paint);
        width = 50;
        break;
      case 'E':
        _drawSharp(canvas, x, staffTop + lineSpacing, paint);
        _drawSharp(canvas, x + 15, staffTop + (lineSpacing * 2.5), paint);
        _drawSharp(canvas, x + 30, staffTop + (lineSpacing * 0.5), paint);
        _drawSharp(canvas, x + 45, staffTop + (lineSpacing * 2), paint);
        width = 65;
        break;
      default:
        width = 0;
    }

    return width + 10;
  }

  double _drawTimeSignature(Canvas canvas, double x, double staffTop, double lineSpacing, Paint paint) {
    final parts = timeSignature.split('/');
    if (parts.length != 2) return 0;

    final textStyle = const TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
      fontFamily: 'serif',
    );

    final numeratorPainter = TextPainter(
      text: TextSpan(text: parts[0], style: textStyle),
      textDirection: TextDirection.ltr,
    );
    numeratorPainter.layout();
    numeratorPainter.paint(canvas, Offset(x, staffTop + lineSpacing * 0.8));

    final denominatorPainter = TextPainter(
      text: TextSpan(text: parts[1], style: textStyle),
      textDirection: TextDirection.ltr,
    );
    denominatorPainter.layout();
    denominatorPainter.paint(canvas, Offset(x, staffTop + lineSpacing * 2.5));

    return math.max(numeratorPainter.width, denominatorPainter.width) + 15;
  }

  void _drawFlat(Canvas canvas, double x, double y, Paint paint) {
    final flatPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(x, y - 12);
    path.lineTo(x, y + 8);
    path.moveTo(x, y);
    path.quadraticBezierTo(x + 6, y - 4, x + 9, y + 1);
    path.quadraticBezierTo(x + 6, y + 6, x, y + 3);

    canvas.drawPath(path, flatPaint);
  }

  void _drawSharp(Canvas canvas, double x, double y, Paint paint) {
    final sharpPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(x + 2, y - 8), Offset(x + 2, y + 8), sharpPaint);
    canvas.drawLine(Offset(x + 6, y - 8), Offset(x + 6, y + 8), sharpPaint);
    canvas.drawLine(Offset(x, y - 2), Offset(x + 8, y - 4), sharpPaint);
    canvas.drawLine(Offset(x, y + 2), Offset(x + 8, y), sharpPaint);
  }

  void _drawNote(Canvas canvas, MusicalNote musicalNote, double x, double staffTop, double lineSpacing, bool isActive, bool isPassed, Paint paint) {
    final y = _getNoteYPosition(musicalNote.note, staffTop, lineSpacing);

    Color noteColor = Colors.black87;
    if (isPassed) {
      noteColor = Colors.green.shade600;
    } else if (isActive) {
      noteColor = accuracyColor ?? Colors.blue.shade600;
    }

    _drawLedgerLines(canvas, musicalNote.note, x, staffTop, lineSpacing, noteColor);

    final noteHeadPaint = Paint()
      ..color = noteColor
      ..style = PaintingStyle.fill;

    double noteHeadWidth = 12;
    double noteHeadHeight = 9;

    // Semibreve é oca
    if ((musicalNote.duration ?? 1.0) >= 4.0) {
      noteHeadWidth = 14;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: noteHeadWidth, height: noteHeadHeight),
        Paint()
          ..color = noteColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    // Mínima é oca com haste
    else if ((musicalNote.duration ?? 1.0) >= 2.0) {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: noteHeadWidth, height: noteHeadHeight),
        Paint()
          ..color = noteColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      _drawNoteStem(canvas, x, y, staffTop, lineSpacing, noteColor);
    }
    else {
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x, y), width: noteHeadWidth, height: noteHeadHeight),
        noteHeadPaint,
      );
      _drawNoteStem(canvas, x, y, staffTop, lineSpacing, noteColor);

      if ((musicalNote.duration ?? 1.0) <= 0.5) {
        _drawNoteFlag(canvas, x, y, staffTop, lineSpacing, noteColor, musicalNote.duration ?? 1.0);
      }
    }

    if (isActive) {
      final activePaint = Paint()
        ..color = (accuracyColor ?? Colors.blue).withOpacity(0.5)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(Offset(x, y), 16, activePaint);
    }
  }

  void _drawNoteStem(Canvas canvas, double x, double y, double staffTop, double lineSpacing, Color color) {
    final stemPaint = Paint()
      ..color = color
      ..strokeWidth = 1.8;

    final stemHeight = 32.0;

    if (y >= staffTop + (lineSpacing * 2)) {
      canvas.drawLine(Offset(x + 6, y), Offset(x + 6, y - stemHeight), stemPaint);
    } else {
      canvas.drawLine(Offset(x - 6, y), Offset(x - 6, y + stemHeight), stemPaint);
    }
  }

  void _drawNoteFlag(Canvas canvas, double x, double y, double staffTop, double lineSpacing, Color color, double duration) {
    final flagPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    bool stemUp = y >= staffTop + (lineSpacing * 2);
    double stemHeight = 32.0;

    if (stemUp) {
      double flagX = x + 6;
      double flagY = y - stemHeight;

      final path = Path();
      path.moveTo(flagX, flagY);
      path.quadraticBezierTo(flagX + 8, flagY + 5, flagX + 6, flagY + 12);
      canvas.drawPath(path, flagPaint);

      if (duration <= 0.25) {
        path.moveTo(flagX, flagY + 6);
        path.quadraticBezierTo(flagX + 8, flagY + 11, flagX + 6, flagY + 18);
        canvas.drawPath(path, flagPaint);
      }
    } else {
      double flagX = x - 6;
      double flagY = y + stemHeight;

      final path = Path();
      path.moveTo(flagX, flagY);
      path.quadraticBezierTo(flagX - 8, flagY - 5, flagX - 6, flagY - 12);
      canvas.drawPath(path, flagPaint);

      if (duration <= 0.25) {
        path.moveTo(flagX, flagY - 6);
        path.quadraticBezierTo(flagX - 8, flagY - 11, flagX - 6, flagY - 18);
        canvas.drawPath(path, flagPaint);
      }
    }
  }

  void _drawRest(Canvas canvas, double x, double staffTop, double lineSpacing, double duration, bool isActive, bool isPassed) {
    final y = staffTop + (lineSpacing * 2);

    Color restColor = Colors.black87;
    if (isPassed) {
      restColor = Colors.green.shade600;
    } else if (isActive) {
      restColor = accuracyColor ?? Colors.blue.shade600;
    }

    final restPaint = Paint()
      ..color = restColor
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    if (duration >= 4.0) {
      canvas.drawRect(Rect.fromLTWH(x - 8, y - lineSpacing, 16, 4), restPaint);
    }
    else if (duration >= 2.0) {
      canvas.drawRect(Rect.fromLTWH(x - 8, y, 16, 4), restPaint);
    }
    else if (duration >= 1.0) {
      final path = Path();
      path.moveTo(x - 6, y - 8);
      path.lineTo(x + 6, y + 4);
      path.lineTo(x + 2, y + 8);
      path.lineTo(x - 6, y - 4);
      path.close();
      canvas.drawPath(path, restPaint);
    }
    else if (duration >= 0.5) {
      final path = Path();
      path.moveTo(x, y - 4);
      path.lineTo(x, y + 8);
      canvas.drawPath(path, Paint()..color = restColor..strokeWidth = 2);
      canvas.drawCircle(Offset(x + 2, y), 3, restPaint);
    }
    else {
      final path = Path();
      path.moveTo(x, y - 4);
      path.lineTo(x, y + 8);
      canvas.drawPath(path, Paint()..color = restColor..strokeWidth = 2);
      canvas.drawCircle(Offset(x + 2, y - 2), 2.5, restPaint);
      canvas.drawCircle(Offset(x + 2, y + 2), 2.5, restPaint);
    }

    if (isActive) {
      final activePaint = Paint()
        ..color = (accuracyColor ?? Colors.blue).withOpacity(0.5)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(Offset(x, y), 16, activePaint);
    }
  }

  void _drawDetectedNote(Canvas canvas, String detectedNote, double x, double staffTop, double lineSpacing) {
    final y = _getNoteYPosition(detectedNote, staffTop, lineSpacing);

    final detectedPaint = Paint()
      ..color = (accuracyColor ?? Colors.red).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: 12, height: 8),
        const Radius.circular(2),
      ),
      detectedPaint,
    );

    if (accuracy > 0.3) {
      final targetY = _getNoteYPosition(notes[currentNoteIndex].note, staffTop, lineSpacing);
      final connectionPaint = Paint()
        ..color = (accuracyColor ?? Colors.orange).withOpacity(0.8)
        ..strokeWidth = 2;

      canvas.drawLine(Offset(x - 30, targetY), Offset(x - 6, y), connectionPaint);
    }
  }

  void _drawActiveIndicator(Canvas canvas, double x, double staffTop, double lineSpacing) {
    final indicatorPaint = Paint()
      ..color = Colors.blue.shade300.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final radius = 22 + (math.sin(progress * math.pi * 2) * 2);
    canvas.drawCircle(Offset(x, staffTop + (lineSpacing * 2)), radius, indicatorPaint);
  }

  void _drawProgressIndicator(Canvas canvas, double x, double staffTop, double lineSpacing, double progress) {
    final progressBarY = staffTop - 30;
    final progressWidth = 50.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - progressWidth / 2, progressBarY, progressWidth, 6),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.grey.shade300,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x - progressWidth / 2, progressBarY, progressWidth * progress, 6),
        const Radius.circular(3),
      ),
      Paint()..color = accuracyColor ?? Colors.blue,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(accuracy * 100).toStringAsFixed(0)}%',
        style: const TextStyle(
          fontSize: 11,
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, progressBarY - 18));
  }

  void _drawLedgerLines(Canvas canvas, String note, double x, double staffTop, double lineSpacing, Color color) {
    final y = _getNoteYPosition(note, staffTop, lineSpacing);
    final staffBottom = staffTop + (lineSpacing * 4);

    final ledgerPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5;

    if (y < staffTop) {
      double lineY = staffTop - lineSpacing;
      while (lineY >= y - 2) {
        canvas.drawLine(Offset(x - 12, lineY), Offset(x + 12, lineY), ledgerPaint);
        lineY -= lineSpacing;
      }
    } else if (y > staffBottom) {
      double lineY = staffBottom + lineSpacing;
      while (lineY <= y + 2) {
        canvas.drawLine(Offset(x - 12, lineY), Offset(x + 12, lineY), ledgerPaint);
        lineY += lineSpacing;
      }
    }
  }

  double _getNoteYPosition(String note, double staffTop, double lineSpacing) {
    final notePositions = {
      'E2': staffTop + (lineSpacing * 5),
      'Eb2': staffTop + (lineSpacing * 5),
      'F2': staffTop + (lineSpacing * 4.5),
      'F#2': staffTop + (lineSpacing * 4.5),
      'G2': staffTop + (lineSpacing * 4),
      'G#2': staffTop + (lineSpacing * 4),
      'A2': staffTop + (lineSpacing * 3.5),
      'A#2': staffTop + (lineSpacing * 3.5),
      'B2': staffTop + (lineSpacing * 3),
      'Bb2': staffTop + (lineSpacing * 3),
      'C3': staffTop + (lineSpacing * 2.5),
      'C#3': staffTop + (lineSpacing * 2.5),
      'D3': staffTop + (lineSpacing * 2),
      'D#3': staffTop + (lineSpacing * 2),
      'Eb3': staffTop + (lineSpacing * 1.5),
      'E3': staffTop + (lineSpacing * 1.5),
      'F3': staffTop + lineSpacing,
      'F#3': staffTop + lineSpacing,
      'Fb3': staffTop + lineSpacing,
      'G3': staffTop + (lineSpacing * 0.5),
      'G#3': staffTop + (lineSpacing * 0.5),
      'Gb3': staffTop + (lineSpacing * 0.5),
      'A3': staffTop,
      'A#3': staffTop,
      'Ab3': staffTop,
      'B3': staffTop - (lineSpacing * 0.5),
      'Bb3': staffTop - (lineSpacing * 0.5),
      'C4': staffTop - lineSpacing,
      'C#4': staffTop - lineSpacing,
      'D4': staffTop - (lineSpacing * 1.5),
      'D#4': staffTop - (lineSpacing * 1.5),
      'Db4': staffTop - (lineSpacing * 1.5),
      'E4': staffTop - (lineSpacing * 2),
      'Eb4': staffTop - (lineSpacing * 2),
      'F4': staffTop - (lineSpacing * 2.5),
      'F#4': staffTop - (lineSpacing * 2.5),
      'G4': staffTop - (lineSpacing * 3),
      'G#4': staffTop - (lineSpacing * 3),
      'A4': staffTop - (lineSpacing * 3.5),
      'A#4': staffTop - (lineSpacing * 3.5),
      'Ab4': staffTop - (lineSpacing * 3.5),
      'B4': staffTop - (lineSpacing * 4),
      'Bb4': staffTop - (lineSpacing * 4),
      'C5': staffTop - (lineSpacing * 4.5),
      'C#5': staffTop - (lineSpacing * 4.5),
      'D5': staffTop - (lineSpacing * 5),
      'D#5': staffTop - (lineSpacing * 5),
      'E5': staffTop - (lineSpacing * 5.5),
    };

    return notePositions[note] ?? (staffTop + (lineSpacing * 1.5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}