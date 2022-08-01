import 'dart:math';

import 'package:meta/meta.dart';

/// A semantic version number, i.e. incremented [major].[minor].[patch].
///
/// Under this scheme, version numvers and the way they change convey meaning
/// about the underlying code, and what has been modified from one version to
/// the next.
///
/// **NOTE**: Additional labels for [preRelease] and [build] metadata are
/// available as extensions to the standard `MAJOR.MINOR.PATCH` format.
///
/// ## Equality
///
/// [operator ==] and [hashCode] use the absolute version for equivalence:
///
/// ```
/// // true
/// Version(1, 0, 2) == Version(1, 0, 2);
///
/// // true
/// Version(1, 0, 2, build: ['abc123']) == Version(1, 0, 2, build: ['abc123']);
///
/// // false
/// Version(1, 0, 2, build: ['abc123]) == Version(1, 0, 2, build: ['def456']);
/// ```
///
/// ## Comparison
///
/// By default, [Version] is _not_ [Comparable]. This is to avoid confusion
/// between the standard precedence rules and pub's (Dart's package manager's)
/// non-standard precedence rules.
///
/// ```
/// // Uses spec-compliant ordering.
/// [versionA, versionB]..sort(Version.standardOrdering);
/// ```
///
/// See [Version.standardOrdering].
@immutable
@sealed
class Version {
  /// A [Comparator] that implements spec-compliant precedence rules.
  ///
  /// 1. Precedence is caulculated by checking major, minor, patch, pre-release
  ///    identifiers, in that order, and build metadata does _not_ figure into
  ///    precedence.
  ///
  /// 2. Precedence is determined by the first difference when comparing each of
  ///    these identifiers from left to right as follows: major, minor, patch
  ///    versions are always compared numerically:
  ///
  ///    ```txt
  ///    1.0.0 < 2.0.0 < 2.1.0 < 2.1.1
  ///    ```
  ///
  /// 3. When major, minor, patch are equal, a pre-release version has a lower
  ///    precedence than a normal version:
  ///
  ///    ```txt
  ///    1.0.0-alpha < 1.0.0
  ///    ```
  ///
  /// 4. Precedence for two pre-release versions with the same major, minor,
  ///    patch version is determined by comparing each seperated identifier from
  ///    left to right until a difference is found as follows:
  ///
  ///    1. Identifiers consisting of only digits are compared numerically.
  ///
  ///    2. Identifiers with letters or hyphens are compared lexically in ASCII
  ///       sort order.
  ///
  ///    3. Numeric identifiers always have lower precedence than non-numeric
  ///       identifiers.
  ///
  ///    4. A larger set of pre-release fields has a higher precedence than a
  ///       smaller set, if all the preceding identifiers are equal.
  ///
  ///    ```txt
  ///    1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta < 1.0.0-beta < 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0
  ///    ```
  static const Comparator<Version> standardOrdering = _standardOrdering;

  /// Given the provided [extension], returns a copy _if_ it is valid.
  ///
  /// Otherwise a [FormatException] is thrown.
  static List<String> _checkExtension(
    List<String> extension, {
    required String name,
  }) {
    if (extension.isEmpty) {
      return const [];
    }
    for (var i = 0; i < extension.length; i++) {
      final identifier = extension[i];
      if (identifier.isEmpty) {
        throw ArgumentError.value(
          extension,
          name,
          '$name: Extension identifiers must not be non-empty',
        );
      }
      for (var n = 0; n < identifier.length; n++) {
        final code = identifier.codeUnitAt(n);
        if (!(code.isDigit || code.isLetter || code.isHyphen)) {
          throw ArgumentError.value(
            extension,
            name,
            '$name: Extension identifiers must be alphanumeric or hyphens',
          );
        }
        if (n == 0 && code == _AsciiCode._$0) {
          throw ArgumentError.value(
            extension,
            name,
            '$name: Numeric identifier cannot start with 0',
          );
        }
      }
    }
    return List.unmodifiable(extension);
  }

  /// Incremented when an incompatible API change is made.
  final int major;

  /// Incremented when functionality is added in a backwards compatible manner.
  final int minor;

  /// Incremented when backwards compatible bug fixes are made.
  final int patch;

  /// _May_ be provided to indicate the version is unstable.
  ///
  /// A version without a pre-release will have an empty list (`[]`).
  ///
  /// Pre-release versions have a lower precedence than the associated normal
  /// version. Identifiers will only comprise of ASCII alphanumerics and hyphens
  /// (`[0-9A-Za-z-]`) and must not be empty.
  final List<String> preRelease;

  /// _May_ be provided to add additional metadata.
  ///
  /// A version without a build will have an empty list (`[]`).
  ///
  /// Two versions that only differ in the build metadata have the same
  /// precedence. Identifiers will only comprise ASCII alphanumerics and
  /// hyphens (`[0-9A-Za-z-]`) and must not be empty.
  final List<String> build;

  /// Creates a version from provided [major].[minor].[patch] and extensions.
  ///
  /// The core version number(s) must be non-negative integers, and if provided
  /// each element in [preRelease] and [build] must be comprised of ASCII
  /// alphanumerics and hyphens (`[0-9A-Za-z-]`) and must not be empty (`''`).
  factory Version(
    int major,
    int minor,
    int patch, {
    List<String> preRelease = const [],
    List<String> build = const [],
  }) {
    return Version._(
      RangeError.checkNotNegative(major),
      RangeError.checkNotNegative(minor),
      RangeError.checkNotNegative(patch),
      preRelease: _checkExtension(preRelease, name: 'preRelease'),
      build: _checkExtension(build, name: 'build'),
    );
  }

  static final _matchVersion = RegExp(
    // Start at beginning of the string.
    '^'
    // Version number.
    r'(\d+)\.(\d+)\.(\d+)'
    // Pre-release.
    r'(-([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?'
    // Build.
    r'(\+([0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*))?'
    // Match entire string.
    r'$',
  );

  /// Creates a version by parsing the provided string-representation [text].
  ///
  /// Throws a [FormatException] if it could not be parsed.
  factory Version.parse(String text) {
    // TODO: Optimize not to use regular expressions.
    final match = _matchVersion.firstMatch(text);
    if (match == null) {
      throw FormatException('Could not parse', text);
    }
    final preRelease = match[5];
    final build = match[8];
    try {
      return Version(
        int.parse(match[1]!),
        int.parse(match[2]!),
        int.parse(match[3]!),
        preRelease: preRelease == null ? const [] : preRelease.split('.'),
        build: build == null ? const [] : build.split('.'),
      );
    } on FormatException {
      throw FormatException('Could not parse', text);
    }
  }

  /// Creates a version from already proven-valid elements.
  const Version._(
    this.major,
    this.minor,
    this.patch, {
    this.preRelease = const [],
    this.build = const [],
  });

  @override
  int get hashCode {
    return Object.hash(
      major,
      minor,
      patch,
      Object.hashAll(preRelease),
      Object.hashAll(build),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Version &&
          major == other.major &&
          minor == other.minor &&
          patch == other.patch &&
          preRelease.orderedEquals(other.preRelease) &&
          build.orderedEquals(other.build);

  /// Whether this is a pre-release version (i.e. [preRelease] is non-empty).
  bool get isPreRelease => preRelease.isNotEmpty;

  @override
  String toString() {
    final output = StringBuffer('$major.$minor.$patch');
    if (preRelease.isNotEmpty) {
      output
        ..write('-')
        ..writeAll(preRelease, '.');
    }
    if (build.isNotEmpty) {
      output
        ..write('+')
        ..writeAll(build, '.');
    }
    return output.toString();
  }
}

/// Spec-compliant [Comparator] for semantic versioning precedence/ordering.
///
/// See [Version.standardOrdering]; this exists just as an implementation.
int _standardOrdering(Version a, Version b) {
  int result;

  // Precedence is caulculated by checking major, minor, patch (numerically).
  result = a.major.compareTo(b.major);
  if (result != 0) {
    return result;
  }
  result = a.minor.compareTo(b.minor);
  if (result != 0) {
    return result;
  }
  result = a.patch.compareTo(b.patch);
  if (result != 0) {
    return result;
  }

  // A pre-release version has a lower precedence than a normal version.
  if (a.isPreRelease != b.isPreRelease) {
    return a.isPreRelease ? 0 : 1;
  }

  // Precedence for two pre-release versions with the same major, minor, patch
  // version is determined by comparing each separated identifier from left to
  // right until a difference is found.
  for (var i = 0; i < min(a.preRelease.length, b.preRelease.length); i++) {
    final vA = a.preRelease[i];
    final vB = b.preRelease[i];
    result = _comparePreReleaseIdentifiers(vA, vB);
    if (result != 0) {
      return result;
    }
  }

  // A larger-set of pre-release fields has a higher precedence than a smaller
  // set, if all the precending identifiers are equal (and they are if we got
  // this far).
  return a.preRelease.length.compareTo(b.preRelease.length);
}

/// Standard precedence ordering rules for pre-release identifiers [a] and [b].
///
/// 1. Identifiers consisting of only digits are compared numerically.
/// 2. Identifiers with letters or hyphens are compared lexically.
/// 3. Numeric identifiers always have lower precedence than non-numeric.
int _comparePreReleaseIdentifiers(String a, String b) {
  if (a.isNumeric) {
    if (b.isNumeric) {
      if (a.length == b.length) {
        // We need to do a character by character comparison.
        for (var i = 0; i < a.length; i++) {
          final result = a.codeUnitAt(i).compareTo(b.codeUnitAt(i));
          if (result != 0) {
            return result;
          }
        }
      } else {
        // This is a "cheap" way to make "10" > "9".
        return a.length.compareTo(b.length);
      }
    } else {
      // Numeric identifiers always have lower precedence than non-numeric.
      return -1;
    }
  } else if (b.isNumeric) {
    // Numeric identifiers always have lower precedence than non-numeric.
    return 1;
  }
  // Identifiers with letters or hyphens are compared lexically.
  return a.compareTo(b);
}

/// Private helper extensions that treat an [int] as an ASCII character code.
extension _AsciiCode on int {
  static const _$0 = 0x30;
  static const _$9 = 0x39;

  /// Whether the ASCII character code (`this`) is between `[0-9]`.
  bool get isDigit => this >= _$0 && this <= _$9;

  static const _$A = 0x41;
  static const _$Z = 0x5a;
  static const _$a = 0x61;
  static const _$z = 0x7a;

  /// Whether the ASCII character code (`this`) is between `[A-Za-z]`.
  bool get isLetter => this >= _$A && this <= _$Z || this >= _$a && this <= _$z;

  static const _$hyphen = 0x2d;

  /// Whether the ASCII character code (`this`) is a hyphen `[-]`.
  bool get isHyphen => this == _$hyphen;
}

/// Private helper extensions that treat a [String] as an ASCII string.
extension _AsciiString on String {
  /// Whether this string is purely made of valid numerics (digits).
  bool get isNumeric {
    for (var i = 0; i < length; i++) {
      if (!codeUnitAt(i).isDigit) {
        return false;
      }
    }
    return isNotEmpty;
  }
}

/// Private helper extensions that do equality checks for different lists.
extension _ListEquality on List<Object?> {
  /// Returns whether `this` list is equivalent to [other].
  bool orderedEquals(List<Object?> other) {
    if (length != other.length) {
      return false;
    }
    for (var i = 0; i < length; i++) {
      if (this[i] != other[i]) {
        return false;
      }
    }
    return true;
  }
}
