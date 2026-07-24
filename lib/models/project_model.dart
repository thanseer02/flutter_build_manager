/// Represents the general project information extracted from a project configuration.
class ProjectModel {
  /// The name of the project.
  final String name;

  /// Creates a new [ProjectModel].
  const ProjectModel({
    required this.name,
  });

  @override
  String toString() {
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is ProjectModel &&
      other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
