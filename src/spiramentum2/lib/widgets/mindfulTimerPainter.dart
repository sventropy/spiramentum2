import 'package:flutter/material.dart';
import '../common/theme.dart';
import "dart:math";

class MindfulTimerPainter extends CustomPainter {
  final _padding = 16.0;
  ValueNotifier<Offset> _notifier;
  double _radius = 0;
  double _angleDegrees;

  MindfulTimerPainter(this._notifier, this._radius, this._angleDegrees)
      : super(repaint: _notifier);

  @override
  void paint(Canvas canvas, Size size) {
    // Define the paint
    final paint = Paint();

    // Determine the center
    var center = Offset(size.width / 2, size.height / 2);

    // When pointer position is not explicitly set, assume default
    var pointerPosition = _notifier.value;
    if (pointerPosition == null) {
      pointerPosition = Offset(size.width / 2, _padding);
    }

    // Draw the circle on centre and filling the available space
    paint.color = kBackgroundColor;
    canvas.drawCircle(center, _radius, paint);
    // Add a border to it
    paint.color = kTextColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(center, _radius, paint);

    // Add arc depicting the timespan selected
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 12;
    paint.color = kPrimaryAccentColor;
    // Correct angles on left side of center
    var angle = _angleDegrees < -90 ? _angleDegrees + 360 : _angleDegrees;
    // Correct angle start from x-axis to top
    var arcAngle = (angle + 90) / 180 * pi;
    canvas.drawArc(Rect.fromCircle(center: center, radius: _radius), -0.5 * pi,
        arcAngle, true, paint);

    // Add little knob to draw the timeframe
    paint.color = kTextColor;
    canvas.drawCircle(pointerPosition, _padding, paint);
    paint.color = kPrimaryAccentColor;
    canvas.drawCircle(pointerPosition, _padding - 4, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
