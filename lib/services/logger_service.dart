import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

enum LogLevel { info, warning, error }

/// Service responsible for daily persistent file logging.
class LoggerService {
  final String _logsDir = '.build_release/logs';

  /// Writes an info message to the daily log file.
  Future<void> info(String message, {String? baseDir}) => _log(LogLevel.info, message, baseDir: baseDir);

  /// Writes a warning message to the daily log file.
  Future<void> warning(String message, {String? baseDir}) => _log(LogLevel.warning, message, baseDir: baseDir);

  /// Writes an error message to the daily log file.
  Future<void> error(String message, {dynamic error, StackTrace? stackTrace, String? baseDir}) async {
    final buffer = StringBuffer(message);
    if (error != null) {
      buffer.writeln();
      buffer.write('Exception: $error');
    }
    if (stackTrace != null) {
      buffer.writeln();
      buffer.write(stackTrace);
    }
    await _log(LogLevel.error, buffer.toString(), baseDir: baseDir);
  }

  Future<void> _log(LogLevel level, String message, {String? baseDir}) async {
    final root = baseDir ?? Directory.current.path;
    final dirPath = p.join(root, _logsDir);
    
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final now = DateTime.now();
    final dateString = DateFormat('yyyyMMdd').format(now);
    final timeString = DateFormat('HH:mm:ss').format(now);
    
    final filePath = p.join(dirPath, '$dateString.log');
    final file = File(filePath);

    final levelStr = level.toString().split('.').last.toUpperCase();
    final logEntry = '[$timeString] [$levelStr] $message\n';

    // Synchronous append to prevent interleaved async writes in rapid succession
    file.writeAsStringSync(logEntry, mode: FileMode.append);
  }
}
