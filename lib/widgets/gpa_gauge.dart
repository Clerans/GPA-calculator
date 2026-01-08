import 'dart:math';
import 'package:flutter/material.dart';

class GPAGauge extends StatelessWidget {
  final double gpa;
  final double maxGpa;
  final bool isWeighted;
  final ValueChanged<bool> onToggleWeighted;

  const GPAGauge({
    super.key,
    required this.gpa,
    this.maxGpa = 4.0,
    required this.isWeighted,
    required this.onToggleWeighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E5EC),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Colors.white,
            offset: Offset(-8, -8),
            blurRadius: 16,
          ),
          BoxShadow(
            color: Color(0xFFA3B1C6),
            offset: Offset(8, 8),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gauge
          SizedBox(
            height: 200,
            width: 200,
            child: Stack(
              children: [
                Center(
                  child: CustomPaint(
                    size: const Size(200, 200),
                    painter: _GaugePainter(
                      percentage: (gpa / maxGpa).clamp(0.0, 1.0),
                      trackColor: const Color(0xFFD1D9E6), // Slightly darker than bg for track/groove
                      gradientColors: const [Color(0xFF26C6DA), Color(0xFF00ACC1)], // Cyan Gradient
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        gpa.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D44),
                        ),
                      ),
                      const Text(
                        'Cumulative GPA',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildOption('Unweighted', !isWeighted),
                _buildOption('Weighted', isWeighted),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String text, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          onToggleWeighted(text == 'Weighted');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0E5EC) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? const [
                   BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
                   BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(3, 3), blurRadius: 6),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? const Color(0xFF00ACC1) : const Color(0xFF4E586E),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double percentage;
  final Color trackColor;
  final List<Color> gradientColors;

  _GaugePainter({
    required this.percentage,
    required this.trackColor,
    required this.gradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 15.0;
    
    // We want a 270 degree arc starting from 135 degrees (bottom leftish)
    // 135 degrees in radians = 2.35619
    // Sweep = 270 degrees in radians = 4.71239
    
    // Actually, reference image looks like a full 270 degree arc with opening at bottom
    // Start angle: 135 degrees (3pi/4)
    // Sweep angle: 270 degrees (3pi/2)
    const startAngle = 135 * pi / 180;
    const sweepAngle = 270 * pi / 180;

    // Background Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      sweepAngle,
      false,
      trackPaint,
    );

    // Foreground Gradient
    final gradient = SweepGradient(
      colors: gradientColors,
      startAngle: startAngle,
      endAngle: startAngle + sweepAngle,
      transform: GradientRotation(0), // rotation handled by arc start
      tileMode: TileMode.clamp, // important for sweep
    );
    // Actually sweep gradient is tricky to align perfectly with start/end angularly without rotation.
    // simpler method for gradient on arc: use Shader
    
    // Let's simpler: Linear Gradient in paint shader
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradientShader = LinearGradient(
      colors: gradientColors,
      begin: Alignment.bottomLeft,
      end: Alignment.topRight,
    ).createShader(rect);

    final progressPaint = Paint()
      ..shader = gradientShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressSweep = sweepAngle * percentage;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      startAngle,
      progressSweep,
      false,
      progressPaint,
    );
    
    // Optional: Draw a subtle shadow or glow? Reference has a glow.
    // Keeping it simple for flutter drawing first.
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage;
  }
}
