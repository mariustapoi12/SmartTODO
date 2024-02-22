// ignore_for_file: avoid_print

import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final log = Logger(
  filter: LogsFilter(),
  output: CustomLogOutput(),
  printer: PrettyPrinter(
    methodCount: 0,
    colors: true,
    printEmojis: false,
    printTime: false,
    noBoxingByDefault: true,
  ),
);

class LogsFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    var shouldLog = kDebugMode;
    assert(() {
      if (event.level.index >= level!.index) {
        shouldLog = true;
      }
      return true;
    }());
    return shouldLog;
  }
}

class CustomLogOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (String message in event.lines) {
      var firstIndex = message.indexOf('{');
      var lastIndex = message.lastIndexOf('}') + 1;
      if (firstIndex != -1 && lastIndex != 0) {
        dev.log(message);
      } else {
        printWrapped(message);
      }
    }
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }
}
