/// A production-ready open-source Dart CLI package that manages Flutter releases.
///
/// This barrel file exports the public API of the package, primarily for use
/// by plugin developers extending `flutter_build_manager`.
library flutter_build_manager;

// Exceptions
export 'exceptions/release_manager_exception.dart';

// Utils
export 'utils/logger.dart';

// Models
export 'models/release_plugin.dart';

// Services
export 'services/process_service.dart';
