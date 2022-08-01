import 'package:neosemver/neosemver.dart';
import 'package:test/test.dart';

void main() {
  group('Version(...) should', () {
    test('create a version from valid MAJOR.MINOR.PATCH', () {
      final version = Version(1, 0, 2);
      expect(version.major, 1);
      expect(version.minor, 0);
      expect(version.patch, 2);
      expect(version.preRelease, isEmpty);
      expect(version.build, isEmpty);
    });

    test('create a version from a valid MAJOR.MINOR.PATCH-preRelease', () {
      final version = Version(
        1,
        0,
        2,
        preRelease: const ['a', '1', '-', 'b'],
      );
      expect(version.preRelease, ['a', '1', '-', 'b']);
    });

    test('create a version from a valid MAJOR.MINOR.PATCH+build', () {
      final version = Version(
        1,
        0,
        2,
        build: const ['a', '1', '-', 'b'],
      );
      expect(version.build, ['a', '1', '-', 'b']);
    });

    test('throw on an invalid MAJOR version', () {
      expect(() => Version(-1, 0, 0), throwsRangeError);
    });

    test('throw on an invalid MINOR version', () {
      expect(() => Version(0, -1, 0), throwsRangeError);
    });

    test('throw on an invalid PATCH version', () {
      expect(() => Version(0, 0, -1), throwsRangeError);
    });

    group('throw on an invalid preRelease version', () {
      test('[empty identifier]', () {
        expect(
          () => Version(0, 0, 0, preRelease: const ['']),
          throwsArgumentError,
        );
      });

      test('[invalid identifier]', () {
        expect(
          () => Version(0, 0, 0, preRelease: const ['&']),
          throwsArgumentError,
        );
      });

      test('[invalid identifier: starts with 0]', () {
        expect(
          () => Version(0, 0, 0, preRelease: const ['0123']),
          throwsArgumentError,
        );
      });
    });

    group('throw on an invalid build version', () {
      test('[empty identifier]', () {
        expect(
          () => Version(0, 0, 0, build: const ['']),
          throwsArgumentError,
        );
      });

      test('[invalid identifier]', () {
        expect(
          () => Version(0, 0, 0, build: const ['&']),
          throwsArgumentError,
        );
      });

      test('[invalid identifier: starts with 0]', () {
        expect(
          () => Version(0, 0, 0, build: const ['0123']),
          throwsArgumentError,
        );
      });
    });
  });
}
