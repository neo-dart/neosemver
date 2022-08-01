import 'package:neosemver/neosemver.dart';
import 'package:test/test.dart';

void main() {
  test('Version.== the same MAJOR.MINOR.PATCH', () {
    expect(
      Version(1, 0, 2),
      Version(1, 0, 2),
    );

    expect(
      Version(1, 0, 2).hashCode,
      Version(1, 0, 2).hashCode,
    );
  });

  test('Version.== the same preRelease', () {
    expect(
      Version(0, 0, 0, preRelease: const ['a']),
      Version(0, 0, 0, preRelease: const ['a']),
    );

    expect(
      Version(0, 0, 0, preRelease: const ['a']).hashCode,
      Version(0, 0, 0, preRelease: const ['a']).hashCode,
    );
  });

  test('Version.== the same build', () {
    expect(
      Version(0, 0, 0, build: const ['a']),
      Version(0, 0, 0, build: const ['a']),
    );

    expect(
      Version(0, 0, 0, build: const ['a']).hashCode,
      Version(0, 0, 0, build: const ['a']).hashCode,
    );
  });
}
