import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:spiramentum2/platform/mindfulStore.dart';
import 'package:spiramentum2/platform/notificationService.dart';
import 'package:spiramentum2/widgets/mindfulTimer.dart';
import 'package:sprintf/sprintf.dart';
import 'dart:async';
import '../common/theme.dart';
import '../common/logger.dart';

final _animationDuration = Duration(milliseconds: 500);

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  bool isTimerRunning;
  String _timerText;
  DateTime _startDateTime;
  int _selectedMinutes;
  MindfulStore _mindfulStore;
  NotificationService _notificationService;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timerText = "00:00";
    isTimerRunning = false;
    _selectedMinutes = 1;
    _mindfulStore = new MindfulStore();
    _notificationService = new NotificationService();
  }

  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleText = Padding(
        padding: EdgeInsets.all(16),
        child: Text("How much time do you want to spend?",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: kPrimaryAccentColor),
            textScaleFactor: 2,
            textAlign: TextAlign.center));

    final durationPicker = MindfulTimer(onTimerDurationUpdated: (minutes) {
      _selectedMinutes = minutes;
      Logger.instance.debug("Interval updated to $_selectedMinutes minutes");
    });

    final pickerTransition = Container(
        height: 300,
        child: AnimatedOpacity(
            opacity: isTimerRunning ? 0.0 : 1.0,
            duration: _animationDuration,
            child: durationPicker));

    final timerText = Center(
      child: Text(
        _timerText,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 64.0, color: kTextColor),
        textAlign: TextAlign.center,
      ),
    );

    final timerTextTransition = Container(
        height: 300,
        child: AnimatedOpacity(
          opacity: isTimerRunning ? 1.0 : 0.0,
          duration: _animationDuration,
          child: timerText,
        ));

    final startStopButton = CupertinoButton(
      color: kPrimaryAccentColor,
      child: Icon(
          isTimerRunning
              ? CupertinoIcons.clear
              : CupertinoIcons.play_arrow_solid,
          color: kTextColor,
          size: 44),
      onPressed: () {
        if (isTimerRunning) {
          this._cancelTimer();
        } else if (_selectedMinutes > 0) {
          Logger.instance.debug("Starting timer");
          // Timer is not running
          isTimerRunning = true;
          _startDateTime = DateTime.now();
        }
        _updateTimer();
      },
    );

    return CupertinoPageScaffold(
      backgroundColor: kBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            titleText,
            Spacer(),
            isTimerRunning ? timerTextTransition : pickerTransition,
            Spacer(),
            startStopButton,
            Spacer()
          ],
        ),
      ),
    );
  }

  Future _updateTimer() async {
    // User might have canceled timer
    if (!isTimerRunning) {
      return;
    }

    // Calculate time
    DateTime currentDateTime = DateTime.now();
    Duration difference = currentDateTime.difference(_startDateTime);
    int minutes = _selectedMinutes - difference.inMinutes;
    int seconds = (60 - difference.inSeconds) % 60;
    if (seconds > 0) {
      minutes--;
    }

    // Update UI
    setState(() {
      if (isTimerRunning) {
        _timerText = sprintf("%02d:%02d", [minutes, seconds]);

        if (minutes <= 0 && seconds <= 0) {
          Logger.instance.debug("Timer goal reached.");
          this._cancelTimer();
          return;
        }
      } else {
        // No timer to schedule
        _timerText = "00:00";
      }
    });

    // When timer is finished, store the time
    if (!isTimerRunning) {
      await _storeMindfulMinutes(difference.inMinutes);
    } else {
      // Or schedule for the next update
      _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
        await _updateTimer();
        timer.cancel();
      });
    }
    Logger.instance.trace("Timer shows $_timerText");
  }

  _cancelTimer() {
    Logger.instance.debug("Stopping timer");
    setState(() {
      isTimerRunning = false;
      _startDateTime = null;
      _timerText = "00:00";
      _selectedMinutes = 0;
    });
  }

  Future _storeMindfulMinutes(int minutes) async {
    await _mindfulStore.storeMindfulMinutes(minutes);
    await _notificationService.showNotification("Mindful session complete",
        "The time you spent was stored in your Health App");
  }
}
