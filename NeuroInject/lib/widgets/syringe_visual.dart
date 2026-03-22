import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Visual syringe diagram showing volume markings with unit labels.
/// Renders a 1 mL syringe with 0.1 mL graduation marks and
/// shows how many units are at each mark based on the current dilution.
class SyringeVisual extends StatelessWidget {
  final double concentrationPerMl;
  final double highlightVolumeMl;
  final Color brandColor;

  const SyringeVisual({
    super.key,
    required this.concentrationPerMl,
    required this.highlightVolumeMl,
    this.brandColor = AppColors.accentBlue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(double.infinity, 280),
      painter: _SyringePainter(
        concentrationPerMl: concentrationPerMl,
        highlightVolumeMl: highlightVolumeMl,
        brandColor: brandColor,
      ),
    );
  }
}

class _SyringePainter extends CustomPainter {
  final double concentrationPerMl;
  final double highlightVolumeMl;
  final Color brandColor;

  _SyringePainter({
    required this.concentrationPerMl,
    required this.highlightVolumeMl,
    required this.brandColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Syringe body dimensions
    final barrelLeft = w * 0.30;
    final barrelRight = w * 0.70;
    final barrelTop = h * 0.08;
    final barrelBottom = h * 0.82;
    final barrelHeight = barrelBottom - barrelTop;

    // Needle
    final needlePaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.fill;
    final needleCenterX = (barrelLeft + barrelRight) / 2;
    canvas.drawRect(
      Rect.fromLTWH(needleCenterX - 1.5, 0, 3, barrelTop),
      needlePaint,
    );
    // Needle hub
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(needleCenterX - 8, barrelTop - 6, 16, 8),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.grey.shade500,
    );

    // Barrel outline
    final barrelOutlinePaint = Paint()
      ..color = Colors.white.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final barrelRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(barrelLeft, barrelTop, barrelRight, barrelBottom),
      const Radius.circular(6),
    );
    canvas.drawRRect(barrelRect, barrelOutlinePaint);

    // Barrel fill (background)
    canvas.drawRRect(
      barrelRect,
      Paint()..color = Colors.white.withAlpha(8),
    );

    // Highlighted fill (the dose volume)
    final highlightFraction = (highlightVolumeMl / 1.0).clamp(0.0, 1.0);
    if (highlightFraction > 0) {
      final fillTop = barrelBottom - (barrelHeight * highlightFraction);
      final fillRect = RRect.fromRectAndCorners(
        Rect.fromLTRB(barrelLeft + 2, fillTop, barrelRight - 2, barrelBottom - 2),
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
        topLeft: Radius.zero,
        topRight: Radius.zero,
      );
      canvas.drawRRect(
        fillRect,
        Paint()..color = brandColor.withAlpha(50),
      );
      // Fill top line
      canvas.drawLine(
        Offset(barrelLeft + 2, fillTop),
        Offset(barrelRight - 2, fillTop),
        Paint()
          ..color = brandColor
          ..strokeWidth = 2,
      );
    }

    // Graduation marks and labels (0.1 mL increments)
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= 10; i++) {
      final fraction = i / 10.0;
      final y = barrelBottom - (barrelHeight * fraction);
      final volumeMl = i * 0.1;
      final units = concentrationPerMl * volumeMl;

      final isMajor = i % 5 == 0;
      final tickLength = isMajor ? 14.0 : 8.0;

      // Left tick marks
      canvas.drawLine(
        Offset(barrelLeft - tickLength, y),
        Offset(barrelLeft, y),
        Paint()
          ..color = Colors.white.withAlpha(isMajor ? 150 : 60)
          ..strokeWidth = isMajor ? 1.5 : 1.0,
      );

      // Right tick marks
      canvas.drawLine(
        Offset(barrelRight, y),
        Offset(barrelRight + tickLength, y),
        Paint()
          ..color = Colors.white.withAlpha(isMajor ? 150 : 60)
          ..strokeWidth = isMajor ? 1.5 : 1.0,
      );

      // Volume labels (left side) — every 0.2 mL
      if (i % 2 == 0) {
        textPainter.text = TextSpan(
          text: volumeMl.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withAlpha(120),
            fontWeight: isMajor ? FontWeight.w600 : FontWeight.w400,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(barrelLeft - tickLength - textPainter.width - 4,
              y - textPainter.height / 2),
        );
      }

      // Unit labels (right side) — every 0.2 mL
      if (i % 2 == 0 && i > 0) {
        final unitText = units >= 100
            ? '${units.toStringAsFixed(0)} U'
            : '${units.toStringAsFixed(1)} U';
        textPainter.text = TextSpan(
          text: unitText,
          style: TextStyle(
            fontSize: 11,
            color: brandColor,
            fontWeight: FontWeight.w600,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(barrelRight + tickLength + 4,
              y - textPainter.height / 2),
        );
      }
    }

    // Plunger
    final plungerTop = barrelBottom + 4;
    final plungerBottom = h;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(
            needleCenterX - 3, plungerTop, needleCenterX + 3, plungerBottom - 8),
        const Radius.circular(2),
      ),
      Paint()..color = Colors.grey.shade500,
    );
    // Plunger handle
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(barrelLeft + 6, plungerBottom - 8, barrelRight - 6, plungerBottom),
        const Radius.circular(3),
      ),
      Paint()..color = Colors.grey.shade400,
    );

    // Axis labels
    // "mL" label left
    textPainter.text = const TextSpan(
      text: 'mL',
      style: TextStyle(
        fontSize: 10,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(barrelLeft - 30, barrelBottom + 6),
    );

    // "Units" label right
    textPainter.text = TextSpan(
      text: 'Units',
      style: TextStyle(
        fontSize: 10,
        color: brandColor,
        fontWeight: FontWeight.w600,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(barrelRight + 10, barrelBottom + 6),
    );
  }

  @override
  bool shouldRepaint(_SyringePainter oldDelegate) {
    return oldDelegate.concentrationPerMl != concentrationPerMl ||
        oldDelegate.highlightVolumeMl != highlightVolumeMl ||
        oldDelegate.brandColor != brandColor;
  }
}
