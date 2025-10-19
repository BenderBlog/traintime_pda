// Copyright 2025 Hazuki Keatsu.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

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

Future<Map<String,int>> calculateAllFNVHash() async {
  // 获取输入文件夹路径
  final directoryPath = '../../assets/experiment_score/scores';
  final directory = Directory(directoryPath);

  // 检查文件夹是否存在
  if (!await directory.exists()) {
    print('错误: 文件夹 "$directoryPath" 不存在');
    return {};
  }

  try {
    // 计算所有文件的哈希值并收集结果
    final Map<String, int> fileHashes = {};
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        // 获取相对路径作为文件名标识
        final relativePath = path.relative(entity.path, from: directoryPath);

        // 计算哈希值
        final hash = await _calculatePixelFNV1A(entity);
        fileHashes[relativePath.substring(0, relativePath.length - 4)] =
            hash;
      }
    }
    return fileHashes;
  } catch (e) {
    print('处理过程中发生错误: $e');
    return {};
  }
}

/// 计算单个文件的FNV哈希值
Future<int> _calculatePixelFNV1A(File file) async {
  final bytes = file.readAsBytesSync();

  // 解码图片为 image 库的 Image 对象
  final image = img.decodeImage(bytes);
  if (image == null) {
    throw Exception("img.decodeImage(bytes) return null. Unsupported format.");
  }

  // 遍历像素，提取RGB通道
  final width = 50;
  final height = 20;
  final pixelBytes = <int>[];

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final pixel = image.getPixel(x, y);

      final a = pixel.a.toInt();
      if (a == 255) {
        // ignore the transparent pixel to reduce the calculation
        pixelBytes.addAll([
          pixel.r.toInt(),
          pixel.g.toInt(),
          pixel.b.toInt(),
        ]);
      }
    }
  }

  var _hash = 0x811C9DC5;
  for (var p in pixelBytes) {
    _hash ^= p;
    _hash = (_hash * 0x01000193) & 0xFFFFFFFF;
  }

  return _hash;
}