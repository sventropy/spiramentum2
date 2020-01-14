import 'package:flutter/material.dart';
import "dart:math";
import 'package:flutter/services.dart';
import 'package:sprintf/sprintf.dart';
import '../common/theme.dart';

// Allows the user of this control to get notified on duration updates
typedef TimerDurationUpdateCallback = void Function(int minutes);

class MindfulTimer extends StatefulWidget {
  MindfulTimer({Key key, this.onTimerDurationUpdated}) : super(key: key);

  // Route through delegate to state
  final TimerDurationUpdateCallback onTimerDurationUpdated;

  @override
  MindfulTimerState createState() => MindfulTimerState();
}

class MindfulTimerState extends State<MindfulTimer> {
  final _radius = 134.0;
  ValueNotifier<Offset> _notifier;
  double _selectionAngleDegrees;
  String _selectionText;

  @override
  void initState() {
    super.initState();
    _notifier = ValueNotifier(null);
    _selectionAngleDegrees = -90;
    _selectionText = "00:00";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanUpdate: (details) {
          var angle = -atan2(context.size.width / 2 - details.localPosition.dx,
              context.size.height / 2 - details.localPosition.dy);

          // Only allow updates in 1 minute steps, assuming the entire circle is "60 minutes", there are 60 steps allowed, 6 degrees/1 minute each
          // start at the top, not at x = 0
          var angleDegrees = angle * 180 / pi - 90;
          // only allow defined steps
          angleDegrees = angleDegrees - angleDegrees % 6;

          // Only update if the angle actually changes
          if (angleDegrees == _selectionAngleDegrees) return;
          _selectionAngleDegrees = angleDegrees;

          // Calculate position based on angle
          angle = angleDegrees * pi / 180;
          var x = context.size.width / 2 + cos(angle) * _radius;
          var y = context.size.height / 2 + sin(angle) * _radius;
          var newPosition = Offset(x, y);
          _notifier.value = newPosition;

          // User feedback
          var minutes = (_selectionAngleDegrees / 6 + 15).round();
          if (minutes < 0) minutes += 60;
          setState(() {
            _selectionText = sprintf("%02d:00", [minutes]);
          });
          widget.onTimerDurationUpdated(minutes);
          HapticFeedback.selectionClick();
        },
        child: CustomPaint(
          // We assume that centers for the painter and this wrapper are the same, hence we do not need to pass the center as a parameter
          painter: TimerPainter(_notifier, _radius, _selectionAngleDegrees),
          child: Center(
            child: Text(
              _selectionText,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 42.0,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ));
  }
}

class TimerPainter extends CustomPainter {
  final _padding = 16.0;
  ValueNotifier<Offset> _notifier;
  double _radius = 0;
  double _angleDegrees;

  TimerPainter(this._notifier, this._radius, this._angleDegrees)
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

    // draw the circle on centre and filling the available space
    paint.color = kPrimaryAccentColor;
    canvas.drawCircle(center, _radius, paint);
    paint.color = kTextColor;
    canvas.drawCircle(pointerPosition, _padding, paint);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 16;

    // Correct angles on left side of center
    var angle = _angleDegrees < -90 ? _angleDegrees + 360 : _angleDegrees;
    // Correct angle start from x-axis to top
    var arcAngle = (angle + 90) / 180 * pi;
    canvas.drawArc(Rect.fromCircle(center: center, radius: _radius), -0.5 * pi,
        arcAngle, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
