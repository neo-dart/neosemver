import 'package:neosemver/neosemver.dart';

void main() {
  // Standard versions, can either parse or create progmatically.
  print(Version.parse('1.0.0'));
  print(Version(1, 0, 0));

  // Versions with extensions; either/and pre-release and build.
  print(Version.parse('1.2.3-alpha+123'));
  print(Version(1, 2, 3, preRelease: const ['alpha'], build: const ['123']));
}
