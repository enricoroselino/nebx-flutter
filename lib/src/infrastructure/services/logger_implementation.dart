import 'package:logger/logger.dart';

abstract interface class ILogger {
  void error({required String message});

  void debug({required String message});
}

class LoggerImplementation implements ILogger {
  late final Logger _logger;

  LoggerImplementation() {
    final printer = PrettyPrinter(
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    );

    _logger = Logger(
      level: Level.all,
      filter: null,
      // null to use the default LogFilter (-> only log in debug mode)
      printer: printer, // Use the PrettyPrinter to format and print log
    );
  }

  @override
  void error({required String message}) {
    _logger.e(message);
  }

  @override
  void debug({required String message}) {
    _logger.d(message);
  }
}
