/// Base exception class for all errors thrown by the Flutter Release Manager.
/// 
/// This ensures we can catch specific exceptions and handle them gracefully
/// without exposing stack traces to the user unless they request it.
class ReleaseManagerException implements Exception {
  /// Creates a new [ReleaseManagerException] with the given [message] and optional [details].
  const ReleaseManagerException(this.message, {this.details});

  /// A user-friendly message describing the error.
  final String message;

  /// Optional technical details or underlying error that caused this exception.
  final Object? details;

  @override
  String toString() {
    if (details != null) {
      return 'ReleaseManagerException: $message\nDetails: $details';
    }
    return 'ReleaseManagerException: $message';
  }
}
