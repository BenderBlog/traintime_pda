// Copyright 2025 Hazuki Keatsu.
// SPDX-License-Identifier: MPL-2.0

/// 独立运行的图像相似度计算脚本
/// 
/// 使用方法:
/// dart run test/image_similarity_standalone.dart <image1_path> <image2_path>
/// 
/// 示例:
/// dart run test/image_similarity_standalone.dart assets/experiment_score/image_generator/6_5.png assets/experiment_score/image_generator/95.png

import 'dart:io';
import 'package:image/image.dart' as img;

/// 计算两个图像之间的 MSE (均方误差)
/// 返回值范围 [0, +∞), 0 表示完全相同，值越大差异越大
double computeMSE(img.Image img1, img.Image img2) {
  if (img1.width != img2.width || img1.height != img2.height) {
    throw ArgumentError('Images must have the same dimensions for MSE calculation');
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

/// 计算两个图像之间的 SSIM (结构相似性指数)
/// 返回值范围 [0, 1], 1 表示完全相同，0 表示完全不同
double computeSSIM(img.Image img1, img.Image img2) {
  if (img1.width != img2.width || img1.height != img2.height) {
    throw ArgumentError('Images must have the same dimensions for SSIM calculation');
  }

  final gray1 = img.grayscale(img1);
  final gray2 = img.grayscale(img2);

  // SSIM 常量
  const c1 = 6.5025; // (0.01 * 255)^2
  const c2 = 58.5225; // (0.03 * 255)^2

  // 计算平均值
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

  // 计算方差和协方差
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

  // 计算 SSIM
  final numerator = (2 * mean1 * mean2 + c1) * (2 * covariance + c2);
  final denominator =
      (mean1 * mean1 + mean2 * mean2 + c1) * (variance1 + variance2 + c2);

  return numerator / denominator;
}

/// 图像特征数据结构
class ImageFeatures {
  final int width;
  final int height;
  final double meanLuminance;
  final double variance;
  final List<int> histogram;

  const ImageFeatures({
    required this.width,
    required this.height,
    required this.meanLuminance,
    required this.variance,
    required this.histogram,
  });
}

/// 计算图像特征
ImageFeatures computeImageFeatures(img.Image image) {
  final gray = img.grayscale(image);
  final totalPixels = gray.width * gray.height;

  // 计算平均亮度
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

  // 计算方差
  var varianceSum = 0.0;
  for (var y = 0; y < gray.height; y++) {
    for (var x = 0; x < gray.width; x++) {
      final luma = img.getLuminance(gray.getPixel(x, y));
      final diff = luma - mean;
      varianceSum += diff * diff;
    }
  }

  final variance = varianceSum / totalPixels;

  return ImageFeatures(
    width: gray.width,
    height: gray.height,
    meanLuminance: mean,
    variance: variance,
    histogram: histogram,
  );
}

/// 计算两个特征集之间的相似度分数
/// 返回值越小表示越相似（0 = 完全相同）
/// 这是项目中使用的特征相似度算法
double calculateFeatureSimilarity(
  ImageFeatures query,
  ImageFeatures corpus,
) {
  // 将特征归一化到相似的尺度
  
  // 1. 平均亮度差异 (0-255 范围)
  final meanDiff = (query.meanLuminance - corpus.meanLuminance).abs();
  final meanScore = meanDiff / 255.0;

  // 2. 方差差异 (归一化)
  final varianceDiff = (query.variance - corpus.variance).abs();
  final varianceScore = varianceDiff / 10000.0; // 归一化方差

  // 3. 直方图相关性 (卡方距离)
  // 计算总像素数用于归一化
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
  
  // 通过总像素数归一化卡方值，得到 0-1 范围
  final histogramScore = histogramDiff / totalPixels;

  // 加权组合
  final score = meanScore * 0.2 + varianceScore * 0.2 + histogramScore * 0.6;

  return score;
}

/// 将相似度分数转换为置信度
/// 使用项目中的置信度计算公式
/// 低分数 = 高置信度
double calculateConfidence(double similarityScore) {
  // 公式: confidence = 1 / (1 + score * k)
  // k=2.0 时的映射关系:
  //   score=0.00 -> confidence=1.000 (完美匹配)
  //   score=0.01 -> confidence=0.980 (几乎完美)
  //   score=0.05 -> confidence=0.909 (优秀)
  //   score=0.10 -> confidence=0.833 (非常好)
  //   score=0.50 -> confidence=0.500 (中等)
  const k = 2.0;
  return 1.0 / (1.0 + similarityScore * k);
}

void printUsage() {
  print('''
图像相似度计算工具

使用方法:
  dart run test/image_similarity_standalone.dart <image1_path> <image2_path>

参数:
  image1_path  第一张图像的路径
  image2_path  第二张图像的路径

示例:
  dart run test/image_similarity_standalone.dart assets/experiment_score/image_generator/6_5.png assets/experiment_score/image_generator/95.png

输出指标说明:
  传统算法:
    MSE (均方误差)    - 值越小越相似，0 表示完全相同，范围 [0, +∞)
    SSIM (结构相似性) - 值越大越相似，1 表示完全相同，范围 [0, 1]
  
  项目算法:
    特征相似度分数    - 基于亮度、方差和直方图的加权组合
    置信度 (Confidence) - 匹配可信度，1.0 表示完美匹配
''');
}

Future<void> main(List<String> args) async {
  // 检查命令行参数
  if (args.length != 2) {
    printUsage();
    exit(1);
  }

  final imagePath1 = args[0];
  final imagePath2 = args[1];

  // 读取图像文件
  print('[1/4] 加载图像...');
  final file1 = File(imagePath1);
  final file2 = File(imagePath2);

  if (!await file1.exists()) {
    print('错误: 图像文件不存在: $imagePath1');
    exit(1);
  }

  if (!await file2.exists()) {
    print('错误: 图像文件不存在: $imagePath2');
    exit(1);
  }

  // 解码图像
  print('[2/4] 解码图像...');
  final bytes1 = await file1.readAsBytes();
  final bytes2 = await file2.readAsBytes();

  final image1 = img.decodeImage(bytes1);
  final image2 = img.decodeImage(bytes2);

  if (image1 == null) {
    print('错误: 无法解码图像 1: $imagePath1');
    exit(1);
  }

  if (image2 == null) {
    print('错误: 无法解码图像 2: $imagePath2');
    exit(1);
  }

  print('      图像加载成功\n');

  // 显示图像信息
  // print('-' * 60);
  // print('图像信息');
  // print('-' * 60);
  // print('图像 1: $imagePath1');
  // print('  尺寸: ${image1.width} x ${image1.height} 像素');
  // print('  通道: ${image1.numChannels}');
  // print('');
  // print('图像 2: $imagePath2');
  // print('  尺寸: ${image2.width} x ${image2.height} 像素');
  // print('  通道: ${image2.numChannels}');
  // print('');

  // 如果尺寸不同，调整第二张图像
  var resizedImage2 = image2;
  if (image1.width != image2.width || image1.height != image2.height) {
    print('注意: 图像尺寸不同，正在调整图像 2 的尺寸以匹配图像 1...');
    resizedImage2 = img.copyResize(
      image2,
      width: image1.width,
      height: image1.height,
    );
    print('      已调整为: ${resizedImage2.width} x ${resizedImage2.height} 像素\n');
  }

  // 计算特征
  print('[3/4] 计算图像特征...');
  final features1 = computeImageFeatures(image1);
  final features2 = computeImageFeatures(resizedImage2);

  // print('\n图像 1 特征:');
  // print('  平均亮度: ${features1.meanLuminance.toStringAsFixed(2)}');
  // print('  方差: ${features1.variance.toStringAsFixed(2)}');

  // print('\n图像 2 特征:');
  // print('  平均亮度: ${features2.meanLuminance.toStringAsFixed(2)}');
  // print('  方差: ${features2.variance.toStringAsFixed(2)}');
  // print('');

  // 计算相似度指标
  print('[4/4] 计算相似度指标...\n');

  final stopwatch = Stopwatch()..start();
  
  // 1. 传统的 MSE 和 SSIM
  final mse = computeMSE(image1, resizedImage2);
  final ssim = computeSSIM(image1, resizedImage2);
  
  // 2. 项目中使用的特征相似度和置信度
  final featureSimilarity = calculateFeatureSimilarity(features1, features2);
  final confidence = calculateConfidence(featureSimilarity);
  
  stopwatch.stop();

  // 显示结果
  print('=' * 60);
  print('计算结果');
  print('=' * 60);
  print('');
  print('[传统相似度指标]');
  print('');
  print('MSE (均方误差):');
  print('  值: ${mse.toStringAsFixed(2)}');
  print('  说明: 值越小越相似，0 表示完全相同');
  print('  范围: [0, +∞)');
  print('');
  print('SSIM (结构相似性指数):');
  print('  值: ${ssim.toStringAsFixed(6)}');
  print('  说明: 值越大越相似，1 表示完全相同');
  print('  范围: [0, 1]');
  print('');
  print('-' * 60);
  print('[项目特征匹配算法]');
  print('');
  print('特征相似度分数:');
  print('  值: ${featureSimilarity.toStringAsFixed(6)}');
  print('  说明: 值越小越相似，0 表示完全相同');
  print('  算法: 加权组合 (亮度 20% + 方差 20% + 直方图 60%)');
  print('');
  print('置信度 (Confidence):');
  print('  值: ${confidence.toStringAsFixed(6)} (${(confidence * 100).toStringAsFixed(2)}%)');
  print('  说明: 匹配的可信程度，1.0 表示完全匹配');
  print('  公式: 1 / (1 + 特征相似度分数 x 2.0)');
  print('');

  // 相似度评估
  print('-' * 60);
  print('综合评估');
  print('-' * 60);
  
  // 性能信息
  print('计算耗时: ${stopwatch.elapsedMilliseconds} ms');
  print('');
}
