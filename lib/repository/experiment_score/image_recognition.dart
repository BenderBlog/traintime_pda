// Copyright 2025 Hazuki Keatsu.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:watermeter/repository/experiment_score/experiment_report_session.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;

/// Score recognition result
class RecognitionResult {
  final String label;
  final bool found;
  final String rawUrl;

  const RecognitionResult({
    required this.label,
    required this.found,
    required this.rawUrl,
  });

  factory RecognitionResult.fromJson(Map<String, dynamic> json) =>
      RecognitionResult(
        label: json['label'] as String,
        found: json['found'] as bool,
        rawUrl: json['rawUrl'] as String,
      );

  Map<String, dynamic> toJson() => {
    'label': label,
    'found': found,
    'rawUrl': rawUrl,
  };

  @override
  String toString() =>
      'RecognitionResult(label: $label, found: $found, rawUrl: $rawUrl)';
}

/// Image recognition service for experiment scores using MD5 hash matching
class ImageRecognitionService {
  ExperimentReportSession? _session;
  ExperimentReportSession get session {
    _session ??= ExperimentReportSession();
    return _session!;
  }

  Map<String, int>? _scoreHashes;

  /// Ensure score hashes are loaded from assets
  Future<void> _ensureHashesLoaded() async {
    if (_scoreHashes != null) return;

    try {
      log.info(
        '[ImageRecognitionService]',
        'Loading score hashes from assets...',
      );

      final hashData = await rootBundle.loadString(
        'assets/experiment_score/score_hashes.json',
      );
      final decoded = jsonDecode(hashData) as Map<String, dynamic>;
      _scoreHashes = decoded.map(
        (key, value) => MapEntry(key, value as int),
      );

      log.info(
        '[ImageRecognitionService]',
        'Successfully loaded ${_scoreHashes!.length} score hashes',
      );
    } catch (e) {
      log.error('[ImageRecognitionService]', 'Failed to load score hashes: $e');
      throw Exception('Failed to load score hashes: $e');
    }
  }

  /// Find matching label by MD5 hash
  RecognitionResult _findMatchByHash(int imageHash, String imageUrl) {
    for (final entry in _scoreHashes!.entries) {
      if (entry.value == imageHash) {
        log.info(
          '[ImageRecognitionService]',
          'Match found: ${entry.key} (hash: $imageHash)',
        );
        return RecognitionResult(
          label: entry.key,
          found: true,
          rawUrl: imageUrl,
        );
      }
    }

    log.warning('[ImageRecognitionService]', 'No match for hash: $imageHash');
    return RecognitionResult(label: '', found: false, rawUrl: imageUrl);
  }

  /// Complete workflow: fetch URLs and recognize all scores
  Future<Map<String, RecognitionResult>> recognizeAllScores() async {
    try {
      log.info('[ImageRecognitionService]', 'Starting score recognition...');

      // Get credentials from preferences
      final account = preference.getString(preference.Preference.idsAccount);
      final password = preference.getString(
        preference.Preference.experimentPassword,
      );

      if (account.isEmpty || password.isEmpty) {
        throw Exception('IDS account or experiment password is not set');
      }

      // Fetch score image URLs
      final urlMap = await session.getScoreImageUrls(account, password);

      if (urlMap.isEmpty) {
        log.warning('[ImageRecognitionService]', 'No score images found');
        return {};
      }

      log.info(
        '[ImageRecognitionService]',
        'Processing ${urlMap.length} images...',
      );

      // Load score hashes
      await _ensureHashesLoaded();

      // Recognize all images
      final resultMap = <String, RecognitionResult>{};
      var index = 0;

      for (final entry in urlMap.entries) {
        index++;
        try {
          log.info(
            '[ImageRecognitionService]',
            'Processing $index/${urlMap.length}...',
          );

          final imageBytes = await session.downloadImageBytes(entry.value);
          // final imageHash = md5.convert(imageBytes).toString();
          final imageHash = await _calculatePixelFNV1A(imageBytes);
          final result = _findMatchByHash(imageHash, entry.value);

          resultMap[entry.key] = result;

          log.info('[ImageRecognitionService]', '${entry.key}: $result');
        } catch (e) {
          log.error(
            '[ImageRecognitionService]',
            'Failed to process ${entry.key}: $e',
          );
          resultMap[entry.key] = RecognitionResult(
            label: '',
            found: false,
            rawUrl: entry.value,
          );
        }
      }

      log.info('[ImageRecognitionService]', 'Recognition complete');
      return resultMap;
    } catch (e) {
      log.error('[ImageRecognitionService]', 'Recognition failed: $e');
      rethrow;
    }
  }

  Future<int> _calculatePixelFNV1A(Uint8List bytes) async {
    final image = img.decodeImage(bytes);
    if (image == null) {
      log.error(
        "[image_recognition][_calculatePixelFNV1A]",
        "img.decodeImage(bytes) return null. Unsupported format.",
      );
      throw Exception(
        "img.decodeImage(bytes) return null. Unsupported format.",
      );
    }

    final width = 50;
    final height = 20;
    final pixelBytes = <int>[];

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final pixel = image.getPixel(x, y);

        final a = pixel.a.toInt();
        if (a == 255) {  // ignore the transparent pixel to reduce the calculation
          pixelBytes.addAll([
            pixel.r.toInt(),
            pixel.g.toInt(),
            pixel.b.toInt(),
            pixel.a.toInt(),
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
}
