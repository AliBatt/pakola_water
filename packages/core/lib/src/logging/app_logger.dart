enum LogLevel { debug, info, warning, error }

abstract class AppLogger {
  void log(LogLevel level, String message, {Map<String, Object?>? data});

  void debug(String message, {Map<String, Object?>? data}) {
    log(LogLevel.debug, message, data: data);
  }

  void info(String message, {Map<String, Object?>? data}) {
    log(LogLevel.info, message, data: data);
  }

  void warning(String message, {Map<String, Object?>? data}) {
    log(LogLevel.warning, message, data: data);
  }

  void error(String message, {Map<String, Object?>? data}) {
    log(LogLevel.error, message, data: data);
  }
}

class ConsoleLogger extends AppLogger {
  @override
  void log(LogLevel level, String message, {Map<String, Object?>? data}) {
    // ignore: avoid_print
    print('[${level.name.toUpperCase()}] $message ${data ?? ''}');
  }
}
