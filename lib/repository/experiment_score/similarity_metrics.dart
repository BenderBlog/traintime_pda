// Copyright 2025 Hazuki Keatsu.
// SPDX-License-Identifier: MPL-2.0

import 'dart:isolate';

import 'package:image/image.dart' as img;
import 'package:pool/pool.dart';
import 'package:watermeter/repository/logger.dart';

/// MSE (Mean Squared Error) and SSIM (Structural Similarity Index) calculation module
/// Support parallel computing

/// Calculate the MSE (Mean Squared Error) between two images
/// Return value range [0, +∞), 0 means identical, the larger the value, the greater the difference
double computeMSE(img.Image img1, img.Image img2) {
  // Ensure the two images have the same dimensions
  if (img1.width != img2.width || img1.height != img2.height) {
    log.error(
      '[similarity_metrics][computeMSE]',
      '[ArgumentError]Images must have the same dimensions for MSE calculation',
    );
    throw ArgumentError(
      'Images must have the same dimensions for MSE calculation',
    );
  }

  final gray1 = img.grayscale(img1);
  final gray2 = img.grayscale(img2);

  var sumSquaredDiff = 0.0;
  final totalPixels = gray1.width * gray1.height;

  for (var y = 0; y < gray1.height; y++) {
    for (var x = 0; x < gray1.width; x++) {
      final c1 = gray1.getPixel(x, y);
      final c2 = gray2.getPixel(x, y);
      final luma1 = img.getLuminance(c1).toDouble();
      final luma2 = img.getLuminance(c2).toDouble();
      final diff = luma1 - luma2;
      sumSquaredDiff += diff * diff;
    }
  }

  return sumSquaredDiff / totalPixels;
}

/// Calculate the SSIM (Structural Similarity Index) between two images
/// Return value range [0, 1], 1 means identical, 0 means completely different
double computeSSIM(img.Image img1, img.Image img2) {
  if (img1.width != img2.width || img1.height != img2.height) {
    log.error(
      '[similarity_metrics][computeSSIM]',
      '[ArgumentError]Images must have the same dimensions for MSE calculation',
    );
    throw ArgumentError(
      'Images must have the same dimensions for SSIM calculation',
    );
  }

  final gray1 = img.grayscale(img1);
  final gray2 = img.grayscale(img2);

  // SSIM constants
  const c1 = 6.5025; // (0.01 * 255)^2
  const c2 = 58.5225; // (0.03 * 255)^2

  // Calculate mean values
  var sum1 = 0.0, sum2 = 0.0;
  final totalPixels = gray1.width * gray1.height;

  for (var y = 0; y < gray1.height; y++) {
    for (var x = 0; x < gray1.width; x++) {
      sum1 += img.getLuminance(gray1.getPixel(x, y));
      sum2 += img.getLuminance(gray2.getPixel(x, y));
    }
  }

  final mean1 = sum1 / totalPixels;
  final mean2 = sum2 / totalPixels;

  // Calculate variance and covariance
  var variance1 = 0.0, variance2 = 0.0, covariance = 0.0;

  for (var y = 0; y < gray1.height; y++) {
    for (var x = 0; x < gray1.width; x++) {
      final luma1 = img.getLuminance(gray1.getPixel(x, y)) - mean1;
      final luma2 = img.getLuminance(gray2.getPixel(x, y)) - mean2;
      variance1 += luma1 * luma1;
      variance2 += luma2 * luma2;
      covariance += luma1 * luma2;
    }
  }

  variance1 /= totalPixels;
  variance2 /= totalPixels;
  covariance /= totalPixels;

  // Calculate SSIM
  final numerator = (2 * mean1 * mean2 + c1) * (2 * covariance + c2);
  final denominator =
      (mean1 * mean1 + mean2 * mean2 + c1) * (variance1 + variance2 + c2);

  return numerator / denominator;
}

/// Batch calculation: For each query image, find the best match in the corpus with the smallest MSE
/// Return the best match index and MSE value for each query
class SimilarityMatch {
  final int index; // In the corpus index
  final double mse; // MSE value
  final double ssim; // SSIM value

  const SimilarityMatch(this.index, this.mse, this.ssim);

  @override
  String toString() =>
      'SimilarityMatch(index: $index, mse: ${mse.toStringAsFixed(2)}, ssim: ${ssim.toStringAsFixed(4)})';
}

/// Parallel computation: For the list of query images, find the most similar match in the corpus (based on MSE + SSIM combination)
Future<List<SimilarityMatch>> findBestMatches(
  List<img.Image> queries,
  List<img.Image> corpus, {
  int? concurrency,
  double mseWeight = 1.0,
  double ssimWeight = 1.0,
}) async {
  if (corpus.isEmpty) {
    return List<SimilarityMatch>.filled(
      queries.length,
      const SimilarityMatch(-1, double.infinity, 0.0),
    );
  }

  final pool = Pool(concurrency ?? 4);
  final results = List<SimilarityMatch?>.filled(queries.length, null);

  await Future.wait([
    for (var i = 0; i < queries.length; i++)
      pool.withResource(() async {
        results[i] = await Isolate.run(
          () => _findBestMatchSync(queries[i], corpus, mseWeight, ssimWeight),
        );
      }),
  ]);

  await pool.close();
  return results.cast<SimilarityMatch>();
}

SimilarityMatch _findBestMatchSync(
  img.Image query,
  List<img.Image> corpus,
  double mseWeight,
  double ssimWeight,
) {
  var bestIdx = -1;
  var bestScore = double.infinity; // The lower the better
  var bestMSE = double.infinity;
  var bestSSIM = 0.0;

  for (var j = 0; j < corpus.length; j++) {
    try {
      // Resize to the size of the query image
      final candidate = img.copyResize(
        corpus[j],
        width: query.width,
        height: query.height,
      );

      final mse = computeMSE(query, candidate);
      final ssim = computeSSIM(query, candidate);

      // Combined score: the smaller the MSE, the better the SSIM
      // Normalize: mse/10000 + (1-ssim)
      final score = mseWeight * (mse / 10000.0) + ssimWeight * (1.0 - ssim);

      if (score < bestScore) {
        bestScore = score;
        bestIdx = j;
        bestMSE = mse;
        bestSSIM = ssim;
      }
    } catch (e) {
      log.error(
        '[similarity_metrics][_findBestMatchSync]',
        'Images can not be processed: $e',
      );
      continue;
    }
  }

  return SimilarityMatch(bestIdx, bestMSE, bestSSIM);
}
