import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import '../models/build_state_model.dart';
import '../exceptions/release_manager_exception.dart';

/// Service responsible for managing daily incrementing release numbers per environment.
class BuildCounterService {
  final String _stateDir = '.build_release';
  final String _stateFile = 'state.json';

  /// Generates the next build number for the given [environment].
  /// 
  /// The returned number is 3-digit zero-padded (e.g., '001').
  /// This operation is thread/process-safe via file locking.
  Future<String> getNextBuildNumber(String environment, {String? baseDir}) async {
    final dirPath = baseDir != null ? '$baseDir/$_stateDir' : _stateDir;
    final filePath = '$dirPath/$_stateFile';
    
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final file = File(filePath);
    if (!file.existsSync()) {
      file.writeAsStringSync('{}');
    }

    // Open file for reading/writing
    RandomAccessFile? raf;
    try {
      raf = file.openSync(mode: FileMode.append);
      
      // Acquire an exclusive lock to ensure cross-process safety
      raf.lockSync(FileLock.exclusive);

      // Read current content
      final contentBytes = file.readAsBytesSync();
      String contentString = contentBytes.isEmpty ? '{}' : utf8.decode(contentBytes);
      
      Map<String, dynamic> jsonMap;
      try {
        jsonMap = json.decode(contentString);
      } catch (_) {
        jsonMap = {}; // Recover from corrupted JSON by starting fresh
      }
      
      var state = BuildStateModel.fromJson(jsonMap);

      final today = DateFormat('yyyyMMdd').format(DateTime.now());
      int newCounter = 1;

      if (state.lastDate == today) {
        // Same day, increment the current environment's counter
        final currentCounter = state.counters[environment] ?? 0;
        newCounter = currentCounter + 1;
        
        final newCounters = Map<String, int>.from(state.counters);
        newCounters[environment] = newCounter;
        
        state = BuildStateModel(lastDate: today, counters: newCounters);
      } else {
        // New day, reset all counters to zero and increment the requested one
        state = BuildStateModel(
          lastDate: today,
          counters: {environment: 1},
        );
      }

      // Write updated state back
      final newContent = json.encode(state.toJson());
      raf.setPositionSync(0);
      raf.truncateSync(0); // Clear old content
      raf.writeStringSync(newContent);

      return newCounter.toString().padLeft(3, '0');
    } catch (e) {
      throw ReleaseManagerException('Failed to manage build counters safely.', details: e);
    } finally {
      try {
        raf?.unlockSync();
        raf?.closeSync();
      } catch (_) {
        // Ignore errors during unlock/close
      }
    }
  }
}
