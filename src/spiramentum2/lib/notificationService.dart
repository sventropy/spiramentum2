import 'package:flutter/services.dart';
import 'dart:async';

class NotificationService {

  static const platform = const MethodChannel('de.sventropy/notification-service');

  Future<void> showNotification(String title, String message) async {
    await platform.invokeMethod('showNotification', [title, message]);
    print("Triggered notification with text $message");
  }
}