import 'package:flutter/material.dart';
import "dart:math";
import 'package:flutter/services.dart';
import 'package:sprintf/sprintf.dart';
import '../common/theme.dart';
import "mindfulTimerPainter.dart";

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
  // Only allow updates in 1 minute steps, assuming the entire circle is "60 minutes", there are 60 steps allowed, 6 degrees/1 minute each
  static final int _minutesPerStep = 1;
  static final int _degreesPerStep = 360 ~/ 60 ~/ _minutesPerStep;
  static final _radius = 134.0;
  static final int _zeroAngleDegrees = -90;

  ValueNotifier<Offset> _notifier;
  int _selectionAngleDegrees;
  String _timerText;

  @override
  void initState() {
    super.initState();
    _notifier = ValueNotifier(null);
    _selectionAngleDegrees = -90;
    _timerText = "00:00";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanUpdate: (details) {
          // Get the angle of the touch compared to the y axis
          var angle = -atan2(context.size.width / 2 - details.localPosition.dx,
              context.size.height / 2 - details.localPosition.dy);

          // start at the top, not at x = 0
          var angleDegrees = (angle * 180 / pi + _zeroAngleDegrees).toInt();
          if (angleDegrees < _zeroAngleDegrees) angleDegrees += 360;

          // only allow defined steps
          angleDegrees = angleDegrees - angleDegrees % _degreesPerStep;

          // Only update if the angle actually changes
          if (angleDegrees == _selectionAngleDegrees) return;

          // This is the new angle to render
          _selectionAngleDegrees = angleDegrees;

          // Calculate position based on angle
          angle = angleDegrees * pi / 180;
          var x = context.size.width / 2 + cos(angle) * _radius;
          var y = context.size.height / 2 + sin(angle) * _radius;
          var newPosition = Offset(x, y);
          _notifier.value = newPosition;

          // User feedback
          var minutes = (_selectionAngleDegrees / _degreesPerStep + 15).round();
          setState(() {
            _timerText = sprintf("%02d:00", [minutes]);
          });
          widget.onTimerDurationUpdated(minutes);
          HapticFeedback.selectionClick();
        },
        child: CustomPaint(
          // We assume that centers for the painter and this wrapper are the same, hence we do not need to pass the center as a parameter
          painter: MindfulTimerPainter(
              _notifier, _radius, _selectionAngleDegrees.toDouble()),
          child: Center(
            child: Text(
              _timerText,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 64.0,
                  color: kTextColor),
              textAlign: TextAlign.center,
            ),
          ),
        ));
  }
}
