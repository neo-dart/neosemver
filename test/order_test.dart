import 'package:neosemver/neosemver.dart';
import 'package:test/test.dart';

void main() {
  test(
    'precedence is first determined by major, minor, patch differences',
    () {
      final sorted = [
        Version(2, 1, 0),
        Version(1, 0, 0),
        Version(2, 1, 1),
        Version(2, 0, 0),
      ]..sort(Version.standardOrdering);
      expect(sorted, [
        Version(1, 0, 0),
        Version(2, 0, 0),
        Version(2, 1, 0),
        Version(2, 1, 1),
      ]);
    },
  );

  test(
    'precedence is next determined by pre-release < non-pre-release',
    () {
      final sorted = [
        Version(1, 0, 0),
        Version(1, 0, 0, preRelease: const ['alpha']),
      ]..sort(Version.standardOrdering);
      expect(sorted, [
        Version(1, 0, 0, preRelease: const ['alpha']),
        Version(1, 0, 0),
      ]);
    },
  );

  test(
    'precedence is next determined by pre-release identifier ordering',
    () {
      final sorted = [
        Version(1, 0, 0, preRelease: const ['beta', '11']),
        Version(1, 0, 0, preRelease: const ['alpha', 'beta']),
        Version(1, 0, 0, preRelease: const ['beta', '2']),
        Version(1, 0, 0, preRelease: const ['alpha', '1']),
        Version(1, 0, 0),
        Version(1, 0, 0, preRelease: const ['rc', '1']),
        Version(1, 0, 0, preRelease: const ['beta']),
        Version(1, 0, 0, preRelease: const ['alpha']),
      ]..sort(Version.standardOrdering);
      expect(sorted, [
        Version(1, 0, 0, preRelease: const ['alpha']),
        Version(1, 0, 0, preRelease: const ['alpha', '1']),
        Version(1, 0, 0, preRelease: const ['alpha', 'beta']),
        Version(1, 0, 0, preRelease: const ['beta']),
        Version(1, 0, 0, preRelease: const ['beta', '2']),
        Version(1, 0, 0, preRelease: const ['beta', '11']),
        Version(1, 0, 0, preRelease: const ['rc', '1']),
        Version(1, 0, 0),
      ]);
    },
  );
}
