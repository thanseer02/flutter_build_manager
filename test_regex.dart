import 'dart:io';
void main() {
  final content = File('example/flutter_build_manager.yaml').readAsStringSync();
  final match = RegExp(r'template:\s*"?([^"\n]+)"?').firstMatch(content);
  print("MATCH: ${match?.group(1)}");
}
