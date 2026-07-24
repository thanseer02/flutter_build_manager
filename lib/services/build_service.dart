import 'dart:io';

import 'package:flutter_build_manager/exceptions/release_manager_exception.dart';
import 'package:flutter_build_manager/models/build_result_model.dart';
import 'process_service.dart';

import 'package:flutter_build_manager/services/flutter_sdk_service.dart';

/// Service responsible for executing and validating Flutter builds safely.
class BuildService {
  final ProcessService _processService;
  final FlutterSdkService _flutterSdkService;

  BuildService({
    required ProcessService processService,
    required FlutterSdkService flutterSdkService,
  })  : _processService = processService,
        _flutterSdkService = flutterSdkService;

  /// Validates the environment, configuration, and project, then executes the build.
  /// 
  /// Supports [target]s: 'apk', 'appbundle', 'ipa'.
  Future<BuildResultModel> executeBuild(
    String target, {
    String? flavor,
    String? env,
    List<String> additionalArgs = const [],
  }) async {
    final startTime = DateTime.now();

    try {
      await _validateProject();
      await _validateConfiguration();
      await _validateFlutterInstallation();

      // Determine the actual flutter build command target based on input
      String flutterTarget = target.toLowerCase();
      if (flutterTarget == 'aab') {
        flutterTarget = 'appbundle';
      }
      
      if (!['apk', 'appbundle', 'ipa'].contains(flutterTarget)) {
        throw ReleaseManagerException('Unsupported build target: $target. Only apk, aab, and ipa are supported.');
      }

      final buildArgs = ['build', flutterTarget];
      
      if (flavor != null && flavor.isNotEmpty) {
        buildArgs.addAll(['--flavor', flavor]);
      }
      
      if (env != null && env.isNotEmpty) {
        buildArgs.addAll(['--dart-define=ENV=$env']);
      }
      
      buildArgs.addAll(additionalArgs);

      final sdkInfo = await _flutterSdkService.getSdkInfo();
      final result = await _processService.run(sdkInfo.executablePath, buildArgs);

      if (result.exitCode != 0) {
        return BuildResultModel(
          isSuccess: false,
          target: target,
          buildDuration: DateTime.now().difference(startTime),
          errorMessage: 'Build failed with exit code ${result.exitCode}:\n${result.stderr}',
        );
      }

      return BuildResultModel(
        isSuccess: true,
        target: target,
        buildDuration: DateTime.now().difference(startTime),
      );
    } catch (e) {
      return BuildResultModel(
        isSuccess: false,
        target: target,
        buildDuration: DateTime.now().difference(startTime),
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _validateProject() async {
    if (!File('pubspec.yaml').existsSync()) {
      throw const ReleaseManagerException('Invalid project: pubspec.yaml not found.');
    }
  }

  Future<void> _validateConfiguration() async {
    if (!File('flutter_build_manager.yaml').existsSync()) {
      throw const ReleaseManagerException(
        'Invalid configuration: flutter_build_manager.yaml not found.',
        details: 'Run `flutter_build_manager init` to create the configuration file.',
      );
    }
  }

  Future<void> _validateFlutterInstallation() async {
    // getSdkInfo internally validates the installation and throws if missing.
    await _flutterSdkService.getSdkInfo();
  }
}
