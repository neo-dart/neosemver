import 'package:neosemver/neosemver.dart';
import 'package:test/test.dart';

void main() {
  test('Should print 1.0.2', () {
    expect(
      Version(1, 0, 2).toString(),
      '1.0.2',
    );
  });

  test('Should print 1.0.2-pre', () {
    expect(
      Version(
        1,
        0,
        2,
        preRelease: const ['pre'],
      ).toString(),
      '1.0.2-pre',
    );
  });

  test('Should print 1.0.2+build', () {
    expect(
      Version(
        1,
        0,
        2,
        build: const ['build'],
      ).toString(),
      '1.0.2+build',
    );
  });

  test('Should print 1.0.2-pre+build', () {
    expect(
      Version(
        1,
        0,
        2,
        preRelease: const ['pre'],
        build: const ['build'],
      ).toString(),
      '1.0.2-pre+build',
    );
  });
}
