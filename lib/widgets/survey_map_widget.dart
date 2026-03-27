// ─────────────────────────────────────────────────────────────────────────────
// SurveyMapWidget — simulated aerial field map using CustomPainter
// ─────────────────────────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import '../core/commons/app_colors.dart';
import '../core/commons/app_dimensions.dart';

class SurveyMapWidget extends StatelessWidget {
  final String coordinateLabel;
  final bool isActual;

  const SurveyMapWidget({
    super.key,
    required this.coordinateLabel,
    required this.isActual,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(context.getWidth(12)),
      child: SizedBox(
        height: context.getHeight(160),
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Aerial field background
            CustomPaint(painter: _AerialFieldPainter()),

            // Center coordinate label
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.getWidth(10),
                  vertical: context.getHeight(4),
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(context.getWidth(4)),
                ),
                child: Text(
                  coordinateLabel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.getFontSize(9),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),

            // Top-left: Actual / Survey badges
            Positioned(
              top: context.getHeight(10),
              left: context.getWidth(10),
              child: Row(
                children: [
                  _badge(
                    context,
                    label: isActual ? 'Actual' : 'Survey',
                    bg: isActual ? AppColors.primary : Colors.orange,
                    textColor: Colors.white,
                  ),
                  if (isActual) ...[
                    SizedBox(width: context.getWidth(6)),
                    _badge(
                      context,
                      label: 'Survey',
                      bg: Colors.white.withValues(alpha: 0.88),
                      textColor: AppColors.textPrimary,
                    ),
                  ],
                ],
              ),
            ),

            // Top-right: fullscreen icon
            Positioned(
              top: context.getHeight(10),
              right: context.getWidth(10),
              child: Container(
                padding: EdgeInsets.all(context.getWidth(5)),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(context.getWidth(5)),
                ),
                child: Icon(
                  Icons.fullscreen_rounded,
                  size: context.getWidth(16),
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(
    BuildContext context, {
    required String label,
    required Color bg,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.getWidth(8),
        vertical: context.getHeight(4),
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(context.getWidth(5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: context.getFontSize(11),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AerialFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Gradient green background
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF33691E), Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF388E3C)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Diagonal field lines
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (double i = -size.height; i < size.width + size.height; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), linePaint);
    }

    // Horizontal dividers
    final hPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.09)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), hPaint);
    }

    // Field polygon
    final fieldPath = Path()
      ..moveTo(size.width * 0.12, size.height * 0.22)
      ..lineTo(size.width * 0.72, size.height * 0.14)
      ..lineTo(size.width * 0.88, size.height * 0.68)
      ..lineTo(size.width * 0.22, size.height * 0.82)
      ..close();

    canvas.drawPath(
      fieldPath,
      Paint()
        ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.13)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      fieldPath,
      Paint()
        ..color = const Color(0xFFFFEB3B).withValues(alpha: 0.6)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
