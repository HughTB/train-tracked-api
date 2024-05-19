import 'dart:io';

late final Logger log;

enum Level { debug, info, warning, error }

class Logger {
  String file;
  bool displayTimes;
  Level level;

  Logger(this.file, this.displayTimes, this.level) {
    i("Logger initialised...");
  }

  void _log(String msg, String format) {
    if (displayTimes) {
      print("${DateTime.now().toIso8601String()} - $format$msg\x1B[0m");
      File(file).writeAsStringSync("${DateTime.now().toIso8601String()} - $msg\n", mode: FileMode.append);
    } else {
      print("$format$msg\x1B[0m");
      File(file).writeAsStringSync("$msg\n", mode: FileMode.append);
    }
  }

  void d(String msg) {
    if (level.index > Level.debug.index) { return; }
    _log("DEBUG: $msg", "\x1B[35m");
  }

  void i(String msg) {
    if (level.index > Level.info.index) { return; }
    _log("INFO: $msg", "");
  }

  void w(String msg) {
    if (level.index > Level.warning.index) { return; }
    _log("WARN: $msg", "\x1B[33m");
  }

  void e(String msg) {
    if (level.index > Level.error.index) { return; }
    _log("ERROR: $msg", "\x1B[31m");
  }

  void f(String msg) {
    _log("FATAL: $msg", "\x1B[1m\x1B[41m\x1B[30m");
  }
}