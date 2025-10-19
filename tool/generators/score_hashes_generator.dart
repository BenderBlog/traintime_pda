// Copyright 2025 Hazuki Keatsu.
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;
import 'package:build/build.dart';
import 'package:glob/glob.dart';

/// Builder factory for score hashes generator
Builder scoreHashesBuilder(BuilderOptions options) => _ScoreHashesBuilder();

/// Generates Dart constants from score images
class _ScoreHashesBuilder implements Builder {
  static const _triggerFile = 'pubspec.yaml';
  static const _outputPath = 'lib/generated/score_hashes.g.dart';

  @override
  Map<String, List<String>> get buildExtensions => const {
        _triggerFile: [_outputPath],
      };

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    log.info('Starting score hashes generation...');
    
    final decoded = await _calculateAllFNVHash(buildStep);

    if (decoded.isEmpty) {
      log.warning('No hashes calculated! Check if images exist.');
      return;
    }

    log.info('Calculated ${decoded.length} hashes');

    // Sort entries by key for consistent output
    final entries = decoded.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Generate Dart code
    final buffer = StringBuffer()
      ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND')
      ..writeln('// This file is auto-generated from score images')
      ..writeln('// Generated at: ${DateTime.now().toIso8601String()}')
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

    log.info('Generate the score_hashes.g.dart successfully.');
  }
}

Future<Map<String, int>> _calculateAllFNVHash(BuildStep buildStep) async {
  final fileHashes = <String, int>{};
  
  try {
    // 使用 buildStep 来访问 assets
    final scoresDir = 'assets/experiment_score/scores';
    
    log.info('Searching for images in $scoresDir');
    
    // 查找所有图片文件
    final imageExtensions = ['.png', '.jpg', '.jpeg', '.bmp', '.gif'];
    
    await for (final input in buildStep.findAssets(Glob('$scoresDir/**'))) {
      final filePath = input.path;
      final ext = path.extension(filePath).toLowerCase();
      
      if (!imageExtensions.contains(ext)) {
        continue;
      }
      
      try {
        log.fine('Processing: $filePath');
        
        // 读取文件内容
        final bytes = await buildStep.readAsBytes(input);
        
        // 计算哈希值
        final hash = _calculatePixelFNV1AFromBytes(Uint8List.fromList(bytes));
        
        // 获取相对路径作为 key（去掉扩展名）
        final relativePath = path.relative(
          filePath,
          from: scoresDir,
        );
        final key = relativePath.substring(0, relativePath.length - ext.length);
        
        fileHashes[key] = hash;
        log.fine('  -> Hash: $hash');
      } catch (e) {
        log.warning('Failed to process $filePath: $e');
      }
    }
    
    log.info('Total images processed: ${fileHashes.length}');
    return fileHashes;
  } catch (e, stackTrace) {
    log.severe('Error calculating hashes: $e', e, stackTrace);
    return {};
  }
}

/// 计算单个文件的FNV哈希值（从字节数据）
int _calculatePixelFNV1AFromBytes(Uint8List bytes) {
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