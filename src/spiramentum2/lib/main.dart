import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'home.dart';


void main() {
  // Override status bar on ios
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.white, // android
        statusBarBrightness: Brightness.dark // iOS
      )
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Spiramentum 2',
      home: MyHomePage(key: Key('home'), title: 'Spiramentum 2'),
    );
  }
}

