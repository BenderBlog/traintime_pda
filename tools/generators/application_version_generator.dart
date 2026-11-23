// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:build/build.dart';
import 'package:yaml/yaml.dart';

/// Builder factory for the application version generator.
Builder applicationVersionBuilder(BuilderOptions options) =>
    _ApplicationVersionBuilder();

/// Generates `lib/generated/application_version.g.dart` from `pubspec.yaml`.
///
/// The version only changes with the build configuration, so it is parsed
/// once at generation time and shipped as a `const`. Consumers do not need
/// `package_info_plus`, a platform channel, or an async startup step.
class _ApplicationVersionBuilder implements Builder {
  static const _triggerFile = 'pubspec.yaml';
  static const _outputPath = 'lib/generated/application_version.g.dart';

  /// Semantic version with an optional prerelease suffix, without the build
  /// number.
  static final _semanticVersion = RegExp(
    r'^\d+\.\d+\.\d+(-[0-9A-Za-z.-]+)?$',
  );

  @override
  Map<String, List<String>> get buildExtensions => const {
    _triggerFile: [_outputPath],
  };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final rawVersion = await _readRawVersion(buildStep);
    final (version, buildNumber) = _parseVersion(rawVersion);

    final buffer = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln(
        '// Generated from pubspec.yaml by '
        'tools/generators/application_version_generator.dart.',
      )
      ..writeln()
      ..writeln(
        '/// Semantic version from `pubspec.yaml`, without the build number.',
      )
      ..writeln("const String kApplicationVersion = '$version';")
      ..writeln()
      ..writeln(
        '/// Build number from `pubspec.yaml`, or `null` when it is omitted.',
      );
    if (buildNumber != null) {
      // The source may omit the build number, so the constant stays nullable.
      buffer.writeln(
        '// ignore: unnecessary_nullable_for_final_variable_declarations',
      );
    }
    buffer.writeln('const int? kApplicationBuildNumber = $buildNumber;');

    await buildStep.writeAsString(
      AssetId(buildStep.inputId.package, _outputPath),
      buffer.toString(),
    );
  }

  /// Reads the `version` entry through the asset graph instead of `dart:io`,
  /// so the value always matches the input build_runner is processing.
  Future<String> _readRawVersion(BuildStep buildStep) async {
    final content = await buildStep.readAsString(buildStep.inputId);

    Object? pubspec;
    try {
      pubspec = loadYaml(content);
    } on YamlException catch (error) {
      throw FormatException('pubspec.yaml is not valid YAML: $error');
    }

    if (pubspec is! Map) {
      throw const FormatException('pubspec.yaml must be a YAML map.');
    }
    final version = pubspec['version'];
    if (version is! String || version.isEmpty) {
      throw const FormatException(
        'pubspec.yaml has no top-level "version" string.',
      );
    }
    return version;
  }

  (String, int?) _parseVersion(String raw) {
    final plus = raw.indexOf('+');
    final version = plus < 0 ? raw : raw.substring(0, plus);
    final buildNumber = plus < 0
        ? null
        : int.tryParse(raw.substring(plus + 1));

    if (!_semanticVersion.hasMatch(version)) {
      throw FormatException(
        'Unsupported version in pubspec.yaml: "$raw". '
        'Expected a semantic version such as "1.2.3" or "1.2.3+45".',
      );
    }
    if (plus >= 0 && buildNumber == null) {
      throw FormatException(
        'Build number in pubspec.yaml version "$raw" is not an integer.',
      );
    }
    return (version, buildNumber);
  }
}
