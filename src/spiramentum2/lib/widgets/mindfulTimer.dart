import 'package:flutter/material.dart';
import "dart:math";
import 'package:flutter/services.dart';
import "./../common/logger.dart";
import 'package:sprintf/sprintf.dart';

class MindfulTimer extends StatefulWidget {
  MindfulTimer({Key key}) : super(key: key);

  @override
  MindfulTimerState createState() => MindfulTimerState();
}

class MindfulTimerState extends State<MindfulTimer> {
  final _radius = 86.0;
  ValueNotifier<Offset> _notifier;
  double _selectionAngleDegrees;
  String _selectionText;

  @override
  void initState() {
    super.initState();
    _notifier = ValueNotifier(null);
    _selectionAngleDegrees = 0;
    _selectionText = "00:00";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanUpdate: (details) {
          var angle = -atan2(context.size.width / 2 - details.localPosition.dx,
              context.size.height / 2 - details.localPosition.dy);

          // Only allow updates for 5 minute steps, assuming the entire circle is "60 minutes", means there are 12 steps allowed, 30 degrees/5 minutes each
          var angleDegrees = angle * 180 / pi - 90;
          angleDegrees = angleDegrees - angleDegrees % 30;

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
          var minutes = (_selectionAngleDegrees / 30 * 5 + 15).round();
          if (minutes < 0) minutes += 60;
          setState(() {
            _selectionText = sprintf("%02d:00", [minutes]);
          });
          HapticFeedback.selectionClick();
        },
        child: CustomPaint(
          // We assume that centers for the painter and this wrapper are the same, hence we do not need to pass the center as a parameter
          painter: TimerPainter(_notifier, _radius),
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

  TimerPainter(this._notifier, double radius) : super(repaint: _notifier) {
    _radius = radius;
  }

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
    paint.color = Colors.deepPurple;
    canvas.drawCircle(center, _radius, paint);
    paint.color = Colors.white;
    canvas.drawCircle(pointerPosition, _padding, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
