// Copyright 2025 Hazuki Keatsu.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:watermeter/repository/experiment_score/experiment_report_session.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/preference.dart' as preference;

/// Image feature cache data structure
class ImageFeatureCache {
  final String path;
  final int width;
  final int height;
  final double meanLuminance;
  final double variance;
  final List<int> histogram;

  const ImageFeatureCache({
    required this.path,
    required this.width,
    required this.height,
    required this.meanLuminance,
    required this.variance,
    required this.histogram,
  });

  factory ImageFeatureCache.fromJson(Map<String, dynamic> json) =>
      ImageFeatureCache(
        path: json['path'] as String,
        width: json['width'] as int,
        height: json['height'] as int,
        meanLuminance: (json['meanLuminance'] as num).toDouble(),
        variance: (json['variance'] as num).toDouble(),
        histogram: (json['histogram'] as List).cast<int>(),
      );

  /// Extract the label from the image path
  String get label {
    final fileName = path.split('/').last.split('\\').last;
    final nameWithoutExt = fileName.split('.').first;
    
    // Handle decimal scores: "6_5" -> "6.5"
    if (nameWithoutExt.contains('_')) {
      return nameWithoutExt.replaceAll('_', '.');
    }
    
    // Handle integer scores: "95" -> "95"
    return nameWithoutExt;
  }
}

/// Score recognition result
class RecognitionResult {
  final String label;
  final double confidence;
  final double mse;
  final double ssim;
  final bool isPredicted;

  const RecognitionResult({
    required this.label,
    required this.confidence,
    required this.mse,
    required this.ssim,
    required this.isPredicted
  });

  @override
  String toString() =>
      'RecognitionResult(label: $label, confidence: ${confidence.toStringAsFixed(4)}, mse: ${mse.toStringAsFixed(2)}, ssim: ${ssim.toStringAsFixed(4)}, isPredicted: $isPredicted)';
}

/// Image recognition service for experiment scores
class ImageRecognitionService {
  // Use lazy initialization to avoid creating session until needed
  ExperimentReportSession? _session;
  ExperimentReportSession get session {
    _session ??= ExperimentReportSession();
    return _session!;
  }

  List<ImageFeatureCache>? _corpusCache;

  /// Load precomputed corpus from assets (only features, no images)
  Future<void> loadCorpus() async {
    try {
      log.info(
        '[ImageRecognitionService][loadCorpus]',
        'Loading corpus cache from assets...',
      );

      // Load cache file from assets
      final cacheData =
          await rootBundle.loadString('assets/experiment_score/cache');
      final List decoded = jsonDecode(cacheData);
      _corpusCache =
          decoded.map((item) => ImageFeatureCache.fromJson(item)).toList();

      log.info(
        '[ImageRecognitionService][loadCorpus]',
        'Successfully loaded ${_corpusCache!.length} cached features',
      );
    } catch (e) {
      log.error(
        '[ImageRecognitionService][loadCorpus]',
        'Failed to load corpus: $e',
      );
      throw Exception('Failed to load corpus: $e');
    }
  }

  /// Ensure corpus is loaded
  Future<void> _ensureCorpusLoaded() async {
    if (_corpusCache == null) {
      await loadCorpus();
    }

    if (_corpusCache == null || _corpusCache!.isEmpty) {
      throw Exception('Corpus is empty or failed to load');
    }
  }

  /// Compute image features from an image
  ImageFeatureCache _computeImageFeatures(img.Image image) {
    final gray = img.grayscale(image);
    final totalPixels = gray.width * gray.height;

    // Calculate mean luminance
    var sum = 0.0;
    final histogram = List<int>.filled(256, 0);

    for (var y = 0; y < gray.height; y++) {
      for (var x = 0; x < gray.width; x++) {
        final luma = img.getLuminance(gray.getPixel(x, y)).toInt().clamp(0, 255);
        sum += luma;
        histogram[luma]++;
      }
    }

    final mean = sum / totalPixels;

    // Calculate variance
    var varianceSum = 0.0;
    for (var y = 0; y < gray.height; y++) {
      for (var x = 0; x < gray.width; x++) {
        final luma = img.getLuminance(gray.getPixel(x, y));
        final diff = luma - mean;
        varianceSum += diff * diff;
      }
    }

    final variance = varianceSum / totalPixels;

    return ImageFeatureCache(
      path: '',
      width: gray.width,
      height: gray.height,
      meanLuminance: mean,
      variance: variance,
      histogram: histogram,
    );
  }

  /// Calculate similarity score between two feature sets
  /// Returns a score where lower is better (0 = identical)
  double _calculateFeatureSimilarity(
    ImageFeatureCache query,
    ImageFeatureCache corpus,
  ) {
    // Normalize features to similar scales
    
    // 1. Mean luminance difference (0-255 range)
    final meanDiff = (query.meanLuminance - corpus.meanLuminance).abs();
    final meanScore = meanDiff / 255.0;

    // 2. Variance difference (normalized)
    final varianceDiff = (query.variance - corpus.variance).abs();
    final varianceScore = varianceDiff / 10000.0; // Normalize variance

    // 3. Histogram correlation (chi-square distance)
    // Calculate total pixels for normalization
    final totalPixels = query.histogram.reduce((a, b) => a + b);
    var histogramDiff = 0.0;
    
    for (var i = 0; i < 256; i++) {
      final q = query.histogram[i];
      final c = corpus.histogram[i];
      if (q + c > 0) {
        final diff = q - c;
        histogramDiff += (diff * diff) / (q + c);
      }
    }
    
    // Normalize chi-square by total pixels to get a 0-1 range
    final histogramScore = histogramDiff / totalPixels;

    // Weighted combination
    final score = meanScore * 0.2 + varianceScore * 0.2 + histogramScore * 0.6;

    return score;
  }

  /// Find the best match from corpus using precomputed features
  RecognitionResult _findBestMatch(ImageFeatureCache queryFeatures) {
    var bestIdx = -1;
    var bestScore = double.infinity;

    for (var i = 0; i < _corpusCache!.length; i++) {
      final score = _calculateFeatureSimilarity(queryFeatures, _corpusCache![i]);

      if (score < bestScore) {
        bestScore = score;
        bestIdx = i;
      }
    }

    if (bestIdx == -1) {
      return const RecognitionResult(
        label: 'unknown',
        confidence: 0.0,
        mse: double.infinity,
        ssim: 0.0,
        isPredicted: false,
      );
    }

    final matchedCache = _corpusCache![bestIdx];
    final label = matchedCache.label;
    
    // Check if the matched image is a predicted image
    // Predicted images have filenames ending with .predicted.png
    final isPredicted = matchedCache.path.toLowerCase().endsWith('.predicted.png');

    // Convert similarity score to confidence (0-1 range)
    // Lower score = higher confidence
    // Formula: confidence = 1 / (1 + score * k)
    // With k=2.0, the mapping is:
    //   score=0.00 -> confidence=1.000 (perfect match)
    //   score=0.01 -> confidence=0.980 (nearly perfect)
    //   score=0.05 -> confidence=0.909 (excellent)
    //   score=0.10 -> confidence=0.833 (very good)
    //   score=0.50 -> confidence=0.500 (moderate)
    final confidence = 1.0 / (1.0 + bestScore * 2.0);

    return RecognitionResult(
      label: label,
      confidence: confidence,
      mse: bestScore * 10000, // Approximate MSE for logging
      ssim: confidence, // Approximate SSIM for logging
      isPredicted: isPredicted,
    );
  }

  /// Recognize a single image URL and return the best matching label
  Future<RecognitionResult> recognizeFromUrl(String imageUrl) async {
    try {
      log.info(
        '[ImageRecognitionService][recognizeFromUrl]',
        'Starting recognition for URL: $imageUrl',
      );

      // Ensure corpus is loaded
      await _ensureCorpusLoaded();

      // Download and decode the image
      log.info(
        '[ImageRecognitionService][recognizeFromUrl]',
        'Downloading image...',
      );

      final queryImage = await session.downloadAndDecodeImage(imageUrl);

      log.info(
        '[ImageRecognitionService][recognizeFromUrl]',
        'Image downloaded, size: ${queryImage.width}x${queryImage.height}',
      );

      // Compute features from the query image
      log.info(
        '[ImageRecognitionService][recognizeFromUrl]',
        'Computing features and matching with ${_corpusCache!.length} corpus entries...',
      );

      final queryFeatures = _computeImageFeatures(queryImage);
      final result = _findBestMatch(queryFeatures);

      log.info(
        '[ImageRecognitionService][recognizeFromUrl]',
        'Recognition complete: $result',
      );

      return result;
    } catch (e) {
      log.error(
        '[ImageRecognitionService][recognizeFromUrl]',
        'Recognition failed: $e',
      );
      rethrow;
    }
  }

  /// Recognize multiple images in parallel
  Future<List<RecognitionResult>> recognizeFromUrls(
    List<String> imageUrls,
  ) async {
    try {
      log.info(
        '[ImageRecognitionService][recognizeFromUrls]',
        'Starting batch recognition for ${imageUrls.length} images',
      );

      // Ensure corpus is loaded
      await _ensureCorpusLoaded();

      // Download and process images
      log.info(
        '[ImageRecognitionService][recognizeFromUrls]',
        'Downloading and processing ${imageUrls.length} images...',
      );

      final results = <RecognitionResult>[];
      for (var i = 0; i < imageUrls.length; i++) {
        try {
          log.info(
            '[ImageRecognitionService][recognizeFromUrls]',
            'Processing image ${i + 1}/${imageUrls.length}...',
          );

          final image = await session.downloadAndDecodeImage(imageUrls[i]);
          final queryFeatures = _computeImageFeatures(image);
          final result = _findBestMatch(queryFeatures);
          
          results.add(result);

          log.info(
            '[ImageRecognitionService][recognizeFromUrls]',
            'Image ${i + 1} result: $result',
          );
        } catch (e) {
          log.error(
            '[ImageRecognitionService][recognizeFromUrls]',
            'Failed to process image ${i + 1}: $e',
          );
          results.add(
            const RecognitionResult(
              label: 'unknown',
              confidence: 0.0,
              mse: double.infinity,
              ssim: 0.0,
              isPredicted: false,
            ),
          );
        }
      }

      log.info(
        '[ImageRecognitionService][recognizeFromUrls]',
        'Batch recognition complete',
      );

      return results;
    } catch (e) {
      log.error(
        '[ImageRecognitionService][recognizeFromUrls]',
        'Batch recognition failed: $e',
      );
      rethrow;
    }
  }

  /// Get score image URLs using credentials from preferences
  Future<Map<String, String>> getScoreImageUrls() async {
    try {
      log.info(
        '[ImageRecognitionService][getScoreImageUrls]',
        'Retrieving credentials from preferences...',
      );

      final account = preference.getString(preference.Preference.idsAccount);
      final password =
          preference.getString(preference.Preference.experimentPassword);

      if (account.isEmpty) {
        log.error(
          '[ImageRecognitionService][getScoreImageUrls]',
          'IDS account is empty',
        );
        throw Exception('IDS account is not set in preferences');
      }

      if (password.isEmpty) {
        log.error(
          '[ImageRecognitionService][getScoreImageUrls]',
          'Experiment password is empty',
        );
        throw Exception('Experiment password is not set in preferences');
      }

      log.info(
        '[ImageRecognitionService][getScoreImageUrls]',
        'Fetching score image URLs...',
      );

      final urls = await session.getScoreImageUrls(account, password);

      log.info(
        '[ImageRecognitionService][getScoreImageUrls]',
        'Retrieved ${urls.length} score image URLs',
      );

      return urls;
    } catch (e) {
      log.error(
        '[ImageRecognitionService][getScoreImageUrls]',
        'Failed to get score image URLs: $e',
      );
      rethrow;
    }
  }

  /// Complete workflow: fetch URLs and recognize all scores
  Future<Map<String, RecognitionResult>> recognizeAllScores() async {
    try {
      log.info(
        '[ImageRecognitionService][recognizeAllScores]',
        'Starting complete recognition workflow...',
      );

      // Get image URLs
      final urlMap = await getScoreImageUrls();

      if (urlMap.isEmpty) {
        log.warning(
          '[ImageRecognitionService][recognizeAllScores]',
          'No score images found',
        );
        return {};
      }

      // Recognize all images
      final urls = urlMap.values.toList();
      final keys = urlMap.keys.toList();

      final results = await recognizeFromUrls(urls);

      // Build result map
      final resultMap = <String, RecognitionResult>{};
      for (var i = 0; i < keys.length; i++) {
        resultMap[keys[i]] = results[i];
      }

      log.info(
        '[ImageRecognitionService][recognizeAllScores]',
        'Complete recognition workflow finished successfully',
      );

      return resultMap;
    } catch (e) {
      log.error(
        '[ImageRecognitionService][recognizeAllScores]',
        'Complete recognition workflow failed: $e',
      );
      rethrow;
    }
  }
}
