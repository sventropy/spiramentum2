import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:sprintf/sprintf.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Spiramentum 2',
      home: MyHomePage(title: 'Spiramentum 2'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String timerText = "00:00";
  DateTime startDateTime;
  bool isTimerRunning = false;
  int selectedIndex = 0;
  int selectedMinutes = 1;

  void _updateTimer() {
    setState(() {
      if (isTimerRunning) {
        DateTime currentDateTime = DateTime.now();
        Duration difference = currentDateTime.difference(startDateTime);
        int minutes = difference.inMinutes;
        int seconds = difference.inSeconds - minutes * 60;
        timerText = sprintf("%02d:%02d", [minutes, seconds]);
        print("Timer shows $timerText");

        if (minutes >= selectedMinutes) {
          print("Timer goal reached. Stopping.");
          isTimerRunning = false;
          startDateTime = null;
          timerText = "00:00";
          return;
        }

        Timer.periodic(Duration(seconds: 1), (timer) {
          _updateTimer();
          timer.cancel();
        });
      } else {
        // No timer to schedule
        timerText = "00:00";
      }
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
            SizedBox(
              height: 200.0,
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
                  selectedMinutes = minutesForPickerIndex(index);
                  print("Interval updated to $selectedMinutes minutes");
                },
              ),
            ),
            Text(
              timerText,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 64.0),
            ),
            CupertinoButton(
              child: Text("Start/Stop"),
              onPressed: () {
                if (isTimerRunning) {
                  print("Stopping timer");
                  isTimerRunning = false;
                  startDateTime = null;
                } else {
                  print("Starting timer");
                  // Timer is not running
                  isTimerRunning = true;
                  startDateTime = DateTime.now();
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