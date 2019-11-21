import 'package:flutter/services.dart';
import 'dart:async';

class MindfulStore {

  static const platform = const MethodChannel('de.sventropy/mindfulness-minutes');

  Future<void> storeMindfulMinutes(int minutes) async {
    try {
      await platform.invokeMethod('storeMindfulMinutes',minutes);
      print("$minutes stored");
    } on PlatformException catch (e) {
      print(e);
    }
  }
}