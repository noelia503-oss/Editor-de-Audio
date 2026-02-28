import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget que visualiza la forma de onda del audio durante la grabación
class WaveformVisualizer extends StatefulWidget {
  final double amplitude; // Amplitud actual (0.0 - 1.0)
  final Color color;
  final int barCount;
  final bool isRecording;

  const WaveformVisualizer({
    Key? key,
    required this.amplitude,
    this.color = Colors.orange,
    this.barCount = 50,
    this.isRecording = false,
  }) : super(key: key);

  @override
  State<WaveformVisualizer> createState() => _WaveformVisualizerState();
}

class _WaveformVisualizerState extends State<WaveformVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<double> _amplitudeHistory = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..repeat();
  }

  @override
  void didUpdateWidget(WaveformVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Actualizar historial de amplitudes
    if (widget.isRecording) {
      _amplitudeHistory.add(widget.amplitude);
      if (_amplitudeHistory.length > widget.barCount) {
        _amplitudeHistory.removeAt(0);
      }
    } else {
      _amplitudeHistory.clear();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: WaveformPainter(
            amplitudes: _amplitudeHistory,
            color: widget.color,
            animationValue: _animationController.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

/// Painter que dibuja las barras de la forma de onda
class WaveformPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color color;
  final double animationValue;

  WaveformPainter({
    required this.amplitudes,
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (amplitudes.isEmpty) {
      // Si no hay datos, dibujar una línea plana
      _drawFlatLine(canvas, size);
      return;
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final barWidth = size.width / amplitudes.length;
    final centerY = size.height / 2;

    for (int i = 0; i < amplitudes.length; i++) {
      final amplitude = amplitudes[i];
      final x = i * barWidth + barWidth / 2;

      // Altura de la barra basada en la amplitud
      final barHeight = (amplitude * size.height * 0.8).clamp(2.0, size.height);

      // Efecto de pulso con animación
      final pulse = math.sin(animationValue * math.pi * 2) * 0.1 + 1.0;
      final animatedHeight = barHeight * pulse;

      // Dibujar barra (línea vertical)
      canvas.drawLine(
        Offset(x, centerY - animatedHeight / 2),
        Offset(x, centerY + animatedHeight / 2),
        paint,
      );
    }
  }

  void _drawFlatLine(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.amplitudes != amplitudes ||
        oldDelegate.animationValue != animationValue;
  }
}

/// Widget simplificado para mostrar niveles de audio
class AudioLevelIndicator extends StatelessWidget {
  final double level; // 0.0 - 1.0
  final Color color;

  const AudioLevelIndicator({
    Key? key,
    required this.level,
    this.color = Colors.orange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Colors.grey[800],
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: level.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [
                color,
                color.withOpacity(0.6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
