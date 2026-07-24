import 'dart:io';

import '../exceptions/release_manager_exception.dart';
import '../models/build_result_model.dart';
import 'process_service.dart';

/// Service responsible for executing and validating Flutter builds safely.
class BuildService {
  final ProcessService _processService;

  BuildService({required ProcessService processService})
      : _processService = processService;

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

      final result = await _processService.run('flutter', buildArgs);

      if (result.exitCode != 0) {
        return BuildResultModel(
          isSuccess: false,
          target: target,
          buildDuration: DateTime.now().difference(startTime),
          errorMessage: 'Build failed with exit code ${result.exitCode}:\n${result.stderr}',
        );
      }

      // Infer the default output path Flutter uses.
      // (Note: BuildService does not move/rename this file. It just returns its assumed location).
      String originalPath = '';
      if (flutterTarget == 'apk') {
        if (flavor != null) {
          originalPath = 'build/app/outputs/flutter-apk/app-${flavor.toLowerCase()}-release.apk';
        } else {
          originalPath = 'build/app/outputs/flutter-apk/app-release.apk';
        }
      } else if (flutterTarget == 'appbundle') {
        if (flavor != null) {
          originalPath = 'build/app/outputs/bundle/${flavor.toLowerCase()}Release/app-${flavor.toLowerCase()}-release.aab';
        } else {
          originalPath = 'build/app/outputs/bundle/release/app-release.aab';
        }
      } else if (flutterTarget == 'ipa') {
        originalPath = 'build/ios/ipa/Runner.ipa';
      }

      // Validate the file actually exists where we expect it
      if (!File(originalPath).existsSync()) {
        return BuildResultModel(
          isSuccess: false,
          target: target,
          buildDuration: DateTime.now().difference(startTime),
          errorMessage: 'Build succeeded, but artifact was not found at the expected path: $originalPath',
        );
      }

      return BuildResultModel(
        isSuccess: true,
        target: target,
        buildDuration: DateTime.now().difference(startTime),
        originalArtifactPath: originalPath,
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
    if (!File('flutter_release.yaml').existsSync()) {
      throw const ReleaseManagerException(
        'Invalid configuration: flutter_release.yaml not found.',
        details: 'Run `flutter_release init` to create the configuration file.',
      );
    }
  }

  Future<void> _validateFlutterInstallation() async {
    try {
      final result = await _processService.run('flutter', ['--version']);
      if (result.exitCode != 0) {
        throw const ReleaseManagerException('Flutter installation validation failed.');
      }
    } catch (e) {
      throw ReleaseManagerException('Flutter is not installed or not in PATH.', details: e.toString());
    }
  }
}
