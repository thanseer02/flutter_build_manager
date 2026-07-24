/// A simple logger wrapper to standardize CLI output.
library flutter_release_manager.core.logger;

import 'package:mason_logger/mason_logger.dart';

/// A global instance of the [Logger] to be used throughout the application.
/// It wraps `mason_logger` to provide professional, colorful logging.
class AppLogger {
  final Logger _logger;

  /// Creates an [AppLogger] wrapping a [Logger].
  AppLogger({Logger? logger}) : _logger = logger ?? Logger();

  /// Logs a standard information message.
  void info(String message) => _logger.info(message);

  /// Logs a success message (usually green).
  void success(String message) => _logger.success(message);

  /// Logs a warning message (usually yellow).
  void warn(String message) => _logger.warn(message);

  /// Logs an error message (usually red).
  void err(String message) => _logger.err(message);

  /// Logs a detailed message meant for debugging (only visible if verbose is enabled).
  void detail(String message) => _logger.detail(message);

  /// Prompts the user for a yes/no response.
  bool confirm(String message) => _logger.confirm(message);

  /// Prompts the user to enter text.
  String prompt(String message) => _logger.prompt(message);

  /// Shows an indeterminate progress indicator.
  Progress progress(String message) => _logger.progress(message);
}
