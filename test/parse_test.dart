import 'package:neosemver/neosemver.dart';
import 'package:test/test.dart';

void main() {
  group('Version.parse should parse', () {
    test('1.0.0', () {
      expect(Version.parse('1.0.0'), Version(1, 0, 0));
    });

    test('2.0.0', () {
      expect(Version.parse('2.0.0'), Version(2, 0, 0));
    });

    test('2.1.0', () {
      expect(Version.parse('2.1.0'), Version(2, 1, 0));
    });

    test('2.1.1', () {
      expect(Version.parse('2.1.1'), Version(2, 1, 1));
    });

    test('1.0.0-alpha', () {
      expect(
        Version.parse('1.0.0-alpha'),
        Version(1, 0, 0, preRelease: const ['alpha']),
      );
    });

    test('1.0.0-alpha.1', () {
      expect(
        Version.parse('1.0.0-alpha.1'),
        Version(1, 0, 0, preRelease: const ['alpha', '1']),
      );
    });

    test('1.0.0+1', () {
      expect(
        Version.parse('1.0.0+1'),
        Version(1, 0, 0, build: const ['1']),
      );
    });

    test('1.0.0-alpha+1', () {
      expect(
        Version.parse('1.0.0-alpha+1'),
        Version(1, 0, 0, preRelease: const ['alpha'], build: const ['1']),
      );
    });
  });
}
