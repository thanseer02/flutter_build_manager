/// Represents the deployment or build environment (e.g., DEV, UAT, PROD).
class EnvironmentModel {
  /// The dynamic string representation of the environment.
  final String name;

  /// Creates a new [EnvironmentModel].
  const EnvironmentModel(this.name);

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is EnvironmentModel &&
      other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
