import 'dart:io';
import 'dart:convert';
import 'package:test/test.dart';
import 'package:intl/intl.dart';
import 'package:flutter_release_manager/services/build_counter_service.dart';

void main() {
  group('BuildCounterService', () {
    late BuildCounterService service;
    late String testDir;
    late String today;
    
    setUp(() {
      service = BuildCounterService();
      final dir = Directory.systemTemp.createTempSync('build_counter_test_');
      testDir = dir.path;
      today = DateFormat('yyyyMMdd').format(DateTime.now());
    });
    
    tearDown(() {
      final dir = Directory(testDir);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    test('initializes counter to 001 if state file is empty/missing', () async {
      final nextNumber = await service.getNextBuildNumber('LIVE', baseDir: testDir);
      expect(nextNumber, equals('001'));
      
      final stateFile = File('$testDir/.build_release/state.json');
      expect(stateFile.existsSync(), isTrue);
      
      final content = json.decode(stateFile.readAsStringSync());
      expect(content['lastDate'], equals(today));
      expect(content['counters']['LIVE'], equals(1));
    });

    test('increments counter correctly on the same day', () async {
      await service.getNextBuildNumber('LIVE', baseDir: testDir); // 001
      final nextNumber = await service.getNextBuildNumber('LIVE', baseDir: testDir); // 002
      expect(nextNumber, equals('002'));
    });

    test('maintains separate counters per environment on the same day', () async {
      await service.getNextBuildNumber('LIVE', baseDir: testDir); // 001
      await service.getNextBuildNumber('LIVE', baseDir: testDir); // 002
      
      final devNumber = await service.getNextBuildNumber('DEV', baseDir: testDir); // 001
      expect(devNumber, equals('001'));
      
      final liveNumber = await service.getNextBuildNumber('LIVE', baseDir: testDir); // 003
      expect(liveNumber, equals('003'));
    });

    test('resets counters on a new day', () async {
      // Simulate yesterday's state
      final yesterday = DateFormat('yyyyMMdd').format(DateTime.now().subtract(const Duration(days: 1)));
      final stateFile = File('$testDir/.build_release/state.json');
      stateFile.parent.createSync(recursive: true);
      stateFile.writeAsStringSync(json.encode({
        'lastDate': yesterday,
        'counters': {
          'LIVE': 8,
          'DEV': 15,
        }
      }));

      // Generate build number for today
      final nextNumber = await service.getNextBuildNumber('LIVE', baseDir: testDir);
      expect(nextNumber, equals('001')); // Should reset to 1
      
      // Verify other environments were cleared
      final stateContent = json.decode(stateFile.readAsStringSync());
      expect(stateContent['counters'].containsKey('DEV'), isFalse);
    });

    test('recovers gracefully from corrupted JSON file', () async {
      final stateFile = File('$testDir/.build_release/state.json');
      stateFile.parent.createSync(recursive: true);
      stateFile.writeAsStringSync('invalid json {[');
      
      final nextNumber = await service.getNextBuildNumber('LIVE', baseDir: testDir);
      expect(nextNumber, equals('001')); // Discards corruption and starts fresh
    });
  });
}
