import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:spiramentum2/mindfulStore.dart';
import 'package:spiramentum2/notificationService.dart';
import 'package:sprintf/sprintf.dart';
import 'dart:async';
import 'theme.dart';
import 'logger.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  bool isTimerRunning;
  String _timerText;
  DateTime _startDateTime;
  int _selectedMinutes;
  MindfulStore _mindfulStore;
  NotificationService _notificationService;
  AnimationController _animationController;
  Animation<double> _pickerAnimation;
  Animation<double> _counterLabelAnimation;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _timerText = "00:00";
    isTimerRunning = false;
    _selectedMinutes = 1;
    _mindfulStore = new MindfulStore();
    _notificationService = new NotificationService();
    _animationController  =
        AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _pickerAnimation = Tween<double>(begin: 1, end: 0).animate(_animationController);
    _counterLabelAnimation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    if(_timer != null) {
      _timer.cancel();
      _timer = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final titleText = Padding(
      padding: EdgeInsets.all(16),
      child: Text("How much time do you want to spend on yourself today?",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: kPrimaryAccentColor
        ),
        textScaleFactor: 2,
        textAlign: TextAlign.center)
    );

    final durationPicker = CupertinoPicker(
      backgroundColor: Colors.transparent,
      children: <Widget>[
        Text("1 minute", style: TextStyle(color: kTextColor)),
        Text("2 minutes", style: TextStyle(color: kTextColor)),
        Text("5 minutes", style: TextStyle(color: kTextColor)),
        Text("10 minutes", style: TextStyle(color: kTextColor)),
        Text("20 minutes", style: TextStyle(color: kTextColor)),
        Text("30 minutes", style: TextStyle(color: kTextColor)),
        Text("60 minutes", style: TextStyle(color: kTextColor)),
      ],
      itemExtent: 44.0,
      onSelectedItemChanged: (index) {
        _selectedMinutes = _minutesForPickerIndex(index);
        Logger.instance.debug("Interval updated to $_selectedMinutes minutes");
      },
    );

    final pickerTransition = SizeTransition(
        sizeFactor: _pickerAnimation,
        child: Container(
          height: 200,
          child: durationPicker
        )
    );

    final timerTextTransition = SizeTransition(
      sizeFactor: _counterLabelAnimation,
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
    );

    final startStopButton = CupertinoButton(
      color: kPrimaryAccentColor,
      child: Icon(
          isTimerRunning ? CupertinoIcons.clear : CupertinoIcons.play_arrow_solid,
          color: kTextColor,
          size: 44
      ),
      onPressed: () {
        if (isTimerRunning) {
          this._cancelTimer();
        } else {
          Logger.instance.debug("Starting timer");
          _animationController.forward();
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
            pickerTransition,
            timerTextTransition,
            Spacer(),
            startStopButton,
            Spacer()
          ],
        ),
      ),
    );
  }


  Future _updateTimer () async {

    // User might have canceled timer
    if (!isTimerRunning){
      return;
    }

    // Calculate time
    DateTime currentDateTime = DateTime.now();
    Duration difference = currentDateTime.difference(_startDateTime);
    int minutes = difference.inMinutes;
    int seconds = difference.inSeconds - minutes * 60;

    // Update UI
    setState(() {
      if (isTimerRunning) {
        _timerText = sprintf("%02d:%02d", [minutes, seconds]);

        if (minutes >= _selectedMinutes) {
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
    if(!isTimerRunning){
      await _storeMindfulMinutes(minutes);
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
    _animationController.reverse();
    setState(() {
      isTimerRunning = false;
      _startDateTime = null;
      _timerText = "00:00";
    });
  }

  Future _storeMindfulMinutes(int minutes) async {
    await _mindfulStore.storeMindfulMinutes(minutes);
    await _notificationService.showNotification("Mindful time complete", "The time spent was stored");
  }

  int _minutesForPickerIndex(int index) {
    switch (index) {
      case 0:
        return 1;
        break;
      case 1:
        return 2;
        break;
      case 2:
        return 5;
        break;
      case 3:
        return 10;
        break;
      case 4:
        return 15;
        break;
      case 5:
        return 20;
        break;
      case 6:
        return 30;
        break;
      case 7:
        return 60;
        break;
      default:
        return 0;
    }
  }
}