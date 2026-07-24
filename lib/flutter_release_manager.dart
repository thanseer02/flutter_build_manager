/// A production-ready open-source Dart CLI package that manages Flutter releases.
///
/// This barrel file exports the public API of the package, primarily for use
/// by plugin developers extending `flutter_release_manager`.
library flutter_release_manager;

// Core
export 'src/core/exceptions/release_manager_exception.dart';
export 'src/core/logging/logger.dart';
export 'src/core/plugins/release_plugin.dart';

// Domain
export 'src/domain/repositories/process_repository.dart';
