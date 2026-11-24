// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated from pubspec.yaml by tools/generators/application_version_generator.dart.

import 'package:package_info_plus/package_info_plus.dart';

/// Semantic version from `pubspec.yaml`, without the build number.
const String _kApplicationVersion = '2.0.0';

/// Build number from `pubspec.yaml`, or `null` when it is omitted.
// ignore: unnecessary_nullable_for_final_variable_declarations
const int? _kApplicationBuildNumber = 60;

/// The build time of the package. Must be specify by --dart-define.
const String _buildTimeRaw = String.fromEnvironment('BUILD_TIME');
DateTime? get _buildTime =>
    _buildTimeRaw.isEmpty ? null : DateTime.tryParse(_buildTimeRaw);

final class PackageApplicationInfo {
  late final Future<String?> androidBuildSignature = _loadSignature();

  Future<String?> _loadSignature() async {
    final signature = (await PackageInfo.fromPlatform()).buildSignature;
    return signature.isEmpty ? null : signature;
  }

  static int? get applicationBuildNumber => _kApplicationBuildNumber;

  static String get applicationVersion => _kApplicationVersion;

  static DateTime? get buildDateTime => _buildTime;

  static String get versionWithBuildNumber =>
      "$applicationVersion${applicationBuildNumber == null ? '' : ' + $applicationBuildNumber'}";
}
