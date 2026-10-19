import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Gerçek defter sayfası gibi yatay satır çizgileri ve dikey kenar payı (margin) çizen arka plan bileşeni.
class LinedPaperBackground extends StatelessWidget {
  final Widget child;
  final double lineSpacing;
  final double marginOffset;

  const LinedPaperBackground({
    super.key,
    required this.child,
    this.lineSpacing = 30.0,
    this.marginOffset = 42.0,
  });

  @override
  Widget build(BuildContext context) {
    final notebookTheme = Theme.of(context).extension<NotebookTheme>();
    final lineColor = notebookTheme?.notebookLineColor ?? Colors.grey.shade300;
    final marginColor =
        notebookTheme?.notebookMarginColor ?? Colors.red.shade200;

    return CustomPaint(
      painter: _NotebookPaperPainter(
        lineColor: lineColor,
        marginColor: marginColor,
        lineSpacing: lineSpacing,
        marginOffset: marginOffset,
      ),
      child: child,
    );
  }
}

class _NotebookPaperPainter extends CustomPainter {
  final Color lineColor;
  final Color marginColor;
  final double lineSpacing;
  final double marginOffset;

  _NotebookPaperPainter({
    required this.lineColor,
    required this.marginColor,
    required this.lineSpacing,
    required this.marginOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    final marginPaint = Paint()
      ..color = marginColor
      ..strokeWidth = 1.5;

    // Yatay defter çizgileri
    double y = lineSpacing;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
      y += lineSpacing;
    }

    // Sol dikey marjin çizgisi
    canvas.drawLine(
      Offset(marginOffset, 0),
      Offset(marginOffset, size.height),
      marginPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NotebookPaperPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor ||
        oldDelegate.marginColor != marginColor ||
        oldDelegate.lineSpacing != lineSpacing ||
        oldDelegate.marginOffset != marginOffset;
  }
}
