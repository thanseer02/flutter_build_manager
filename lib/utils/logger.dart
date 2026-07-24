import 'package:mason_logger/mason_logger.dart';

/// A global logger instance configured for the CLI.
/// 
/// This wraps the [Logger] from the `mason_logger` package and provides
/// standard output coloring and formatting.
class ReleaseManagerLogger {
  /// Internal [Logger] instance from `mason_logger`.
  final Logger _logger;

  /// Creates a [ReleaseManagerLogger].
  ReleaseManagerLogger({Logger? logger}) : _logger = logger ?? Logger();

  /// Logs informational messages.
  void info(String message) => _logger.info(message);

  /// Logs success messages.
  void success(String message) => _logger.success(message);

  /// Logs warning messages.
  void warn(String message) => _logger.warn(message);

  /// Logs error messages.
  void err(String message) => _logger.err(message);

  /// Logs detailed diagnostic information (only shown if verbose mode is on).
  void detail(String message) => _logger.detail(message);

  /// Prompts the user for a boolean confirmation.
  bool confirm(String message, {bool defaultValue = false}) {
    return _logger.confirm(message, defaultValue: defaultValue);
  }

  /// Sets the logging level.
  set level(Level level) => _logger.level = level;
}
