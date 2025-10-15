// Copyright 2025 Hazuki Keatsu.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
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

  Map<String, String>? _scoreHashes;

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
      _scoreHashes = decoded.map((key, value) => MapEntry(key, value as String));

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
  RecognitionResult _findMatchByHash(String imageHash, String imageUrl) {
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
    return RecognitionResult(
      label: '',
      found: false,
      rawUrl: imageUrl,
    );
  }

  /// Complete workflow: fetch URLs and recognize all scores
  Future<Map<String, RecognitionResult>> recognizeAllScores() async {
    try {
      log.info('[ImageRecognitionService]', 'Starting score recognition...');

      // Get credentials from preferences
      final account = preference.getString(preference.Preference.idsAccount);
      final password = preference.getString(preference.Preference.experimentPassword);

      if (account.isEmpty || password.isEmpty) {
        throw Exception('IDS account or experiment password is not set');
      }

      // Fetch score image URLs
      final urlMap = await session.getScoreImageUrls(account, password);
      
      if (urlMap.isEmpty) {
        log.warning('[ImageRecognitionService]', 'No score images found');
        return {};
      }

      log.info('[ImageRecognitionService]', 'Processing ${urlMap.length} images...');

      // Load score hashes
      await _ensureHashesLoaded();

      // Recognize all images
      final resultMap = <String, RecognitionResult>{};
      var index = 0;
      
      for (final entry in urlMap.entries) {
        index++;
        try {
          log.info('[ImageRecognitionService]', 'Processing $index/${urlMap.length}...');
          
          final imageBytes = await session.downloadImageBytes(entry.value);
          final imageHash = md5.convert(imageBytes).toString();
          final result = _findMatchByHash(imageHash, entry.value);
          
          resultMap[entry.key] = result;
          
          log.info('[ImageRecognitionService]', '${entry.key}: $result');
        } catch (e) {
          log.error('[ImageRecognitionService]', 'Failed to process ${entry.key}: $e');
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
}
