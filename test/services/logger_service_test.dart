import 'dart:io';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;
import 'package:intl/intl.dart';

import 'package:flutter_build_manager/services/logger_service.dart';

void main() {
  group('LoggerService', () {
    late LoggerService service;
    late String testDir;
    late String todayLogFile;

    setUp(() {
      service = LoggerService();
      final dir = Directory.systemTemp.createTempSync('logger_service_test_');
      testDir = dir.path;
      
      final today = DateFormat('yyyyMMdd').format(DateTime.now());
      todayLogFile = p.join(testDir, '.build_release', 'logs', '$today.log');
    });

    tearDown(() {
      final dir = Directory(testDir);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    test('writes info message to daily log file', () async {
      await service.info('Build Started', baseDir: testDir);
      
      final file = File(todayLogFile);
      expect(file.existsSync(), isTrue);
      
      final content = file.readAsStringSync();
      expect(content, contains('[INFO] Build Started'));
    });

    test('writes warning message', () async {
      await service.warning('Low disk space', baseDir: testDir);
      
      final file = File(todayLogFile);
      final content = file.readAsStringSync();
      expect(content, contains('[WARNING] Low disk space'));
    });

    test('writes error message with exception and stacktrace', () async {
      try {
        throw Exception('Mock crash');
      } catch (e, st) {
        await service.error('Build Failure', error: e, stackTrace: st, baseDir: testDir);
      }
      
      final file = File(todayLogFile);
      final content = file.readAsStringSync();
      
      expect(content, contains('[ERROR] Build Failure'));
      expect(content, contains('Exception: Exception: Mock crash'));
      expect(content, contains('logger_service_test.dart')); // Part of stacktrace
    });

    test('appends to existing log file', () async {
      await service.info('First message', baseDir: testDir);
      await service.info('Second message', baseDir: testDir);
      
      final file = File(todayLogFile);
      final content = file.readAsStringSync();
      final lines = content.trim().split('\n');
      
      expect(lines.length, equals(2));
      expect(lines[0], contains('First message'));
      expect(lines[1], contains('Second message'));
    });
  });
}
