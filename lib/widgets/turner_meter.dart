import 'package:flutter/material.dart';
import 'dart:math' as math;

class TunerMeter extends StatelessWidget {
  /// Posição da agulha (0.0 = -50 cents, 0.5 = 0 cents, 1.0 = +50 cents)
  final double needlePosition;

  /// Se está afinado (muda cor da agulha e zona verde)
  final bool isInTune;

  /// Valor em cents para exibir no display
  final int cents;

  /// Se deve mostrar o label de cents abaixo do medidor
  final bool showCentsLabel;

  /// Se deve mostrar a escala de valores (-50, 0, +50)
  final bool showScale;

  /// Altura do widget (largura será automática)
  final double? height;

  /// Cores personalizáveis
  final Color? backgroundColor;
  final Color? scaleColor;
  final Color? inTuneColor;
  final Color? outOfTuneColor;
  final Color? zoneColor;

  const TunerMeter({
    Key? key,
    required this.needlePosition,
    required this.isInTune,
    required this.cents,
    this.showCentsLabel = true,
    this.showScale = true,
    this.height,
    this.backgroundColor,
    this.scaleColor,
    this.inTuneColor,
    this.outOfTuneColor,
    this.zoneColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Escala de cents
          if (showScale) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '-50',
                  style: TextStyle(
                    color: scaleColor ?? Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '0',
                  style: TextStyle(
                    color: scaleColor ?? Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '+50',
                  style: TextStyle(
                    color: scaleColor ?? Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          // Medidor visual
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: TunerMeterPainter(
                needlePosition: needlePosition,
                isInTune: isInTune,
                cents: cents,
                inTuneColor: inTuneColor ?? Colors.green.shade600,
                outOfTuneColor: outOfTuneColor ?? Colors.red.shade600,
                zoneColor: zoneColor ?? Colors.green.shade400,
                scaleColor: scaleColor ?? Colors.grey.shade600,
              ),
            ),
          ),

          // Indicador de cents
          if (showCentsLabel) ...[
            const SizedBox(height: 10),
            Text(
              cents == 0 ? '0' : '${cents > 0 ? '+' : ''}$cents',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isInTune
                    ? (inTuneColor ?? Colors.green.shade600)
                    : (outOfTuneColor ?? Colors.red.shade600),
              ),
            ),
            Text(
              'cents',
              style: TextStyle(
                fontSize: 12,
                color: scaleColor ?? Colors.grey.shade600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Painter personalizado para desenhar o medidor de afinação
class TunerMeterPainter extends CustomPainter {
  final double needlePosition;
  final bool isInTune;
  final int cents;
  final Color inTuneColor;
  final Color outOfTuneColor;
  final Color zoneColor;
  final Color scaleColor;

  TunerMeterPainter({
    required this.needlePosition,
    required this.isInTune,
    required this.cents,
    required this.inTuneColor,
    required this.outOfTuneColor,
    required this.zoneColor,
    required this.scaleColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 3;

    // Desenhar arco de fundo
    paint.color = Colors.grey.shade300;
    paint.strokeWidth = 8;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      paint,
    );

    // Desenhar zona verde (afinado) - ±10 cents
    paint.color = zoneColor;
    paint.strokeWidth = 8;
    final greenZone = 20.0 / 100.0 * math.pi; // ±10 cents = 20% do arco
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi + math.pi/2 - greenZone/2,
      greenZone,
      false,
      paint,
    );

    // Desenhar marcações da escala
    paint.color = scaleColor;
    paint.strokeWidth = 2;
    paint.style = PaintingStyle.stroke;

    for (int i = 0; i <= 10; i++) {
      final angle = math.pi + (i / 10.0) * math.pi;
      final startRadius = radius - 10;
      final endRadius = radius + (i % 5 == 0 ? 15 : 10);

      final startX = center.dx + startRadius * math.cos(angle);
      final startY = center.dy + startRadius * math.sin(angle);
      final endX = center.dx + endRadius * math.cos(angle);
      final endY = center.dy + endRadius * math.sin(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }

    // Desenhar agulha
    if (needlePosition >= 0.0 && needlePosition <= 1.0) {
      final needleAngle = math.pi + needlePosition * math.pi;
      final needleLength = radius - 5;

      // Cor da agulha baseada na afinação
      paint.color = isInTune ? inTuneColor : outOfTuneColor;
      paint.strokeWidth = 4;
      paint.strokeCap = StrokeCap.round;
      paint.style = PaintingStyle.stroke;

      final needleEnd = Offset(
        center.dx + needleLength * math.cos(needleAngle),
        center.dy + needleLength * math.sin(needleAngle),
      );

      canvas.drawLine(center, needleEnd, paint);

      // Desenhar ponto central
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(center, 6, paint);

      // Desenhar sombra da agulha para melhor visibilidade
      paint.color = Colors.black.withOpacity(0.2);
      paint.strokeWidth = 6;
      paint.style = PaintingStyle.stroke;
      canvas.drawLine(
          Offset(center.dx + 1, center.dy + 1),
          Offset(needleEnd.dx + 1, needleEnd.dy + 1),
          paint
      );
    }

    // Desenhar marca central (0 cents)
    paint.color = scaleColor;
    paint.strokeWidth = 3;
    paint.style = PaintingStyle.stroke;

    final centerAngle = math.pi + math.pi/2;
    final centerMarkStart = Offset(
      center.dx + (radius - 15) * math.cos(centerAngle),
      center.dy + (radius - 15) * math.sin(centerAngle),
    );
    final centerMarkEnd = Offset(
      center.dx + (radius + 20) * math.cos(centerAngle),
      center.dy + (radius + 20) * math.sin(centerAngle),
    );

    canvas.drawLine(centerMarkStart, centerMarkEnd, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is TunerMeterPainter) {
      return needlePosition != oldDelegate.needlePosition ||
          isInTune != oldDelegate.isInTune ||
          cents != oldDelegate.cents;
    }
    return true;
  }
}