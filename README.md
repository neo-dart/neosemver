# neosemver

Semantic versioning and extensible constraint solving.

<!-- ENABLE WHEN PUBLISHED
[![On pub.dev][pub_img]][pub_url]
[![Code coverage][cov_img]][cov_url]
[![Github action status][gha_img]][gha_url]
[![Dartdocs][doc_img]][doc_url]
-->

[![Style guide][sty_img]][sty_url]

[pub_url]: https://pub.dartlang.org/packages/neosemver
[pub_img]: https://img.shields.io/pub/v/neosemver.svg
[gha_url]: https://github.com/neo-dart/neosemver/actions
[gha_img]: https://github.com/neo-dart/neosemver/workflows/Dart/badge.svg
[cov_url]: https://codecov.io/gh/neo-dart/neosemver
[cov_img]: https://codecov.io/gh/neo-dart/neosemver/branch/main/graph/badge.svg
[doc_url]: https://www.dartdocs.org/documentation/neosemver/latest
[doc_img]: https://img.shields.io/badge/Documentation-neosemver-blue.svg
[sty_url]: https://pub.dev/packages/neodart
[sty_img]: https://img.shields.io/badge/style-neodart-9cf.svg

This library seeks to provide semantic version _parsing_ and constraint solving,
but with a few twists compared to [pub_semver][]:

1. Implemented precisely the same as [Semantic Versioning 2.0.0][rtf].
2. Dart specific rules ("Pub Semantic Versioning") is an _optional_ extension.

[pub_semver]: https://pub.dev/packages/pub_semver
[rtf]: https://semver.org/spec/v2.0.0.html

## Usage

```dart
// Example.
Version.parse('1.0.0') == Version(1, 0, 0);
```
