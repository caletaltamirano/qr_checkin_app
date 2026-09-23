import 'package:flutter/material.dart';

/// Darkens everything outside a centered rounded square and draws corner
/// brackets around it, guiding the operator to where the QR code should
/// be placed. The bracket color reflects the current scan state.
class ScanFrameOverlay extends StatelessWidget {
  final Color accentColor;

  const ScanFrameOverlay({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ScanFramePainter(accentColor: accentColor),
        size: Size.infinite,
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  final Color accentColor;

  _ScanFramePainter({required this.accentColor});

  static const _cornerLength = 32.0;
  static const _strokeWidth = 3.5;
  static const _radius = Radius.circular(28);

  @override
  void paint(Canvas canvas, Size size) {
    final frameSize = size.shortestSide * 0.68;
    final frameRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - size.height * 0.06),
      width: frameSize,
      height: frameSize,
    );
    final frameRRect = RRect.fromRectAndRadius(frameRect, _radius);

    final scrimPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
      Path()..addRRect(frameRRect),
    );
    canvas.drawPath(scrimPath, Paint()..color = Colors.black.withValues(alpha: 0.6));

    canvas.drawRRect(
      frameRRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    final cornerPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;

    void corner(Offset a, Offset b, Offset c) {
      canvas.drawPath(
        Path()
          ..moveTo(a.dx, a.dy)
          ..lineTo(b.dx, b.dy)
          ..lineTo(c.dx, c.dy),
        cornerPaint,
      );
    }

    final r = frameRect;
    corner(Offset(r.left, r.top + _cornerLength), r.topLeft, Offset(r.left + _cornerLength, r.top));
    corner(Offset(r.right - _cornerLength, r.top), r.topRight, Offset(r.right, r.top + _cornerLength));
    corner(Offset(r.right, r.bottom - _cornerLength), r.bottomRight, Offset(r.right - _cornerLength, r.bottom));
    corner(Offset(r.left + _cornerLength, r.bottom), r.bottomLeft, Offset(r.left, r.bottom - _cornerLength));
  }

  @override
  bool shouldRepaint(covariant _ScanFramePainter oldDelegate) =>
      oldDelegate.accentColor != accentColor;
}
