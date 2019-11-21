import 'package:flutter/cupertino.dart';
import 'home.dart';

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

