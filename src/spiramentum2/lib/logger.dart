import 'dart:developer' as developer;
class Logger {

  static final instance = Logger();

  trace(String message){
    developer.log(message, level: 100, name: "trace");
  }
  debug(String message){
    developer.log(message, level: 100, name: "debug");
  }
  info(String message){
    developer.log(message, level: 10, name: "info");
  }
  error(String message, {Object error}){
    developer.log(message, level: 1, name: "error", error: error);
  }
}