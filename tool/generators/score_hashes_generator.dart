// Copyright 2025 Hazuki Keatsu.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';

/// Builder factory for score hashes generator
Builder scoreHashesBuilder(BuilderOptions options) => _ScoreHashesBuilder();

/// Generates Dart constants from score_hashes.json
class _ScoreHashesBuilder implements Builder {
  static const _inputPath = 'assets/experiment_score/score_hashes.json';
  static const _outputPath = 'lib/generated/score_hashes.g.dart';

  @override
  Map<String, List<String>> get buildExtensions => const {
        _inputPath: [_outputPath],
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    // Read the JSON file
    final source = await buildStep.readAsString(buildStep.inputId);
    final decoded = jsonDecode(source) as Map<String, dynamic>;

    // Sort entries by key for consistent output
    final entries = decoded.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Generate Dart code
    final buffer = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln('// This file is auto-generated from score_hashes.json')
      ..writeln()
      ..writeln('/// Pre-computed FNV1a hashes for experiment score images')
      ..writeln('/// Maps score label to FNV1a hash value')
      ..writeln('const Map<String, int> kScoreHashes = {');

    for (final entry in entries) {
      // Escape single quotes in keys
      final key = entry.key.replaceAll("'", "\\'");
      final value = entry.value;
      buffer.writeln("  '$key': $value,");
    }

    buffer.writeln('};');

    // Write the generated file
    final outputId = AssetId(buildStep.inputId.package, _outputPath);
    await buildStep.writeAsString(outputId, buffer.toString());
  }
}
