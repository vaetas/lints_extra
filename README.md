# lints_extra

## `prefer_absolute_import`

Prefer absolute imports over package imports. This helps separating your own code from third party
packages.

```dart
// BAD
import 'package:example/example_import.dart';

// FIXED
import '/example_import.dart';
```