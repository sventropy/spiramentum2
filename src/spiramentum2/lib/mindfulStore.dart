import 'package:flutter/services.dart';
import 'dart:async';

class MindfulStore {

  static const platform = const MethodChannel('de.sventropy/mindfulness-minutes');

  Future<void> storeMindfulMinutes(int minutes) async {
      await platform.invokeMethod('storeMindfulMinutes',minutes);
      print("$minutes stored");
  }
}