import 'package:flutter/cupertino.dart';
import 'package:spiramentum2/mindfulStore.dart';
import 'dart:async';
import 'package:sprintf/sprintf.dart';
import 'package:flutter/animation.dart';


class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {

  String _timerText;
  DateTime _startDateTime;
  bool _isTimerRunning;
  int _selectedMinutes;
  MindfulStore _mindfulStore;
  AnimationController _animationController;
  Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _timerText = "00:00";
    _isTimerRunning = false;
    _selectedMinutes = 1;
    _mindfulStore = new MindfulStore();
    _animationController  =
        AnimationController(duration: const Duration(seconds: 1), vsync: this);
    _animation = Tween<double>(begin: 1, end:0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _updateTimer () async {

    // User might have canceled timer
    if (!_isTimerRunning){
      return;
    }

    // Calculate time
    DateTime currentDateTime = DateTime.now();
    Duration difference = currentDateTime.difference(_startDateTime);
    int minutes = difference.inMinutes;
    int seconds = difference.inSeconds - minutes * 60;

    // Update UI
    setState(() {
      if (_isTimerRunning) {
        _timerText = sprintf("%02d:%02d", [minutes, seconds]);

        if (minutes >= _selectedMinutes) {
          print("Timer goal reached.");
          this._cancelTimer();
          return;
        }

      } else {
        // No timer to schedule
        _timerText = "00:00";
      }
    });

    // When timer is finished, store the time
    if(!_isTimerRunning){
      await _mindfulStore.storeMindfulMinutes(minutes);
    } else {
      // Or schedule for the next update
      Timer.periodic(Duration(seconds: 1), (timer) {
        _updateTimer();
        timer.cancel();
      });
    }
    print("Timer shows $_timerText");
  }

  _cancelTimer() {
    print("Stopping timer");
    setState(() {
      _isTimerRunning = false;
      _startDateTime = null;
      _timerText = "00:00";
    });
  }


  @override
  Widget build(BuildContext context) {

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text("Spiramentum"),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(padding: EdgeInsets.all(16),child:
            Text("How much time do you want to spend on yourself today?",
                style: TextStyle(fontWeight: FontWeight.bold), textScaleFactor: 2,
            textAlign: TextAlign.center,),
            ),
            SizeTransition(
                sizeFactor: _animation,
                child: Container(
                  height: 200,
                  child: CupertinoPicker(
                    backgroundColor: Color.fromARGB(0, 0, 0, 0),
                    children: <Widget>[
                      Text("1 minute"),
                      Text("2 minutes"),
                      Text("5 minutes"),
                      Text("10 minutes"),
                      Text("20 minutes"),
                      Text("30 minutes"),
                      Text("60 minutes"),
                    ],
                    itemExtent: 44.0,
                    onSelectedItemChanged: (index) {
                      _selectedMinutes = minutesForPickerIndex(index);
                      print("Interval updated to $_selectedMinutes minutes");
                    },
                  ),
                )
            ),
            Text(
              _timerText,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 64.0),
            ),
            CupertinoButton(
              child: Text(_isTimerRunning ? "Cancel": "Start"),
              onPressed: () {
                if (_isTimerRunning) {
                  _animationController.reverse();
                  this._cancelTimer();
                } else {
                  print("Starting timer");
                  _animationController.forward();
                  // Timer is not running
                  _isTimerRunning = true;
                  _startDateTime = DateTime.now();
                }

                _updateTimer();
              },
            )
          ],
        ),
      ),
    );
  }

  int minutesForPickerIndex(int index) {
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