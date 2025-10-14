import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

class ImageFeatureCache {
  final String path;
  final int width;
  final int height;
  final double meanLuminance;
  final double variance;
  final List<int> histogram; // 256 bins

  ImageFeatureCache({
    required this.path,
    required this.width,
    required this.height,
    required this.meanLuminance,
    required this.variance,
    required this.histogram,
  });

  Map<String, dynamic> toJson() => {
        'path': path,
        'width': width,
        'height': height,
        'meanLuminance': meanLuminance,
        'variance': variance,
        'histogram': histogram,
      };

  factory ImageFeatureCache.fromJson(Map<String, dynamic> json) => ImageFeatureCache(
        path: json['path'] as String,
        width: json['width'] as int,
        height: json['height'] as int,
        meanLuminance: (json['meanLuminance'] as num).toDouble(),
        variance: (json['variance'] as num).toDouble(),
        histogram: (json['histogram'] as List).cast<int>(),
      );
}

/// Calculate the single image features
ImageFeatureCache computeImageFeatures(String imagePath) {
  final bytes = File(imagePath).readAsBytesSync();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    throw FormatException('Cannot decode image: $imagePath');
  }

  final gray = img.grayscale(decoded);
  final totalPixels = gray.width * gray.height;

  // Mean
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

  // Variance
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
    path: imagePath,
    width: gray.width,
    height: gray.height,
    meanLuminance: mean,
    variance: variance,
    histogram: histogram,
  );
}

/// Scan the specific folder, and precalculate all the images' feature and save them in the cache file.
Future<void> precomputeAndCache(String folderPath, String cacheFilePath) async {
  await precomputeAndCacheMultiple([folderPath], cacheFilePath);
}

/// Scan multiple folders, and precalculate all the images' features and save them in the cache file.
Future<void> precomputeAndCacheMultiple(List<String> folderPaths, String cacheFilePath) async {
  final features = <ImageFeatureCache>[];

  for (var folderPath in folderPaths) {
    final dir = Directory(folderPath);
    if (!dir.existsSync()) {
      stdout.writeln('⚠ Warning: Directory does not exist: $folderPath');
      continue;
    }

    final imageFiles = dir
        .listSync(recursive: false)
        .whereType<File>()
        .where((f) => ['.png', '.jpg', '.jpeg', '.webp', '.bmp'].contains(p.extension(f.path).toLowerCase()))
        .toList();

    stdout.writeln('Found ${imageFiles.length} images in $folderPath');

    for (var file in imageFiles) {
      try {
        stdout.write('Processing ${p.basename(file.path)}... ');
        final feature = computeImageFeatures(file.path);
        features.add(feature);
        stdout.writeln('✓');
      } catch (e) {
        stdout.writeln('✗ Error: $e');
      }
    }
    stdout.writeln('');
  }

  // Save into the file
  final json = jsonEncode(features.map((f) => f.toJson()).toList());
  if (!File(cacheFilePath).existsSync()) {
    File(cacheFilePath).createSync(recursive: true);
  }
  await File(cacheFilePath).writeAsString(json);
  stdout.writeln('Cache saved to $cacheFilePath');
  stdout.writeln('Total: ${features.length} images from ${folderPaths.length} folder(s)');
}

/// Load feature from cache
Future<List<ImageFeatureCache>> loadCache(String cacheFilePath) async {
  final file = File(cacheFilePath);
  if (!file.existsSync()) {
    return [];
  }

  final json = await file.readAsString();
  final List decoded = jsonDecode(json);
  return decoded.map((item) => ImageFeatureCache.fromJson(item)).toList();
}

/// Check if the cache need to update
Future<bool> isCacheValid(String folderPath, String cacheFilePath) async {
  final cacheFile = File(cacheFilePath);
  if (!cacheFile.existsSync()) return false;

  final dir = Directory(folderPath);
  if (!dir.existsSync()) return false;

  final imageFiles = dir
      .listSync(recursive: false)
      .whereType<File>()
      .where((f) => ['.png', '.jpg', '.jpeg', '.webp', '.bmp'].contains(p.extension(f.path).toLowerCase()))
      .toList();

  final cache = await loadCache(cacheFilePath);
  if (cache.length != imageFiles.length) return false;

  final cachePaths = cache.map((c) => c.path).toSet();
  final currentPaths = imageFiles.map((f) => f.path).toSet();

  return cachePaths.difference(currentPaths).isEmpty && currentPaths.difference(cachePaths).isEmpty;
}


void main(List<String> args) async {
  if (args.isEmpty) {
    print("用法:");
    print("  单个文件夹: dart run gen_cache.dart <folder_path> <cache_file>");
    print("  多个文件夹: dart run gen_cache.dart <folder1> <folder2> ... <folderN> <cache_file>");
    print("");
    print("示例:");
    print("  dart run gen_cache.dart scores cache");
    print("  dart run gen_cache.dart scores predict cache");
    return;
  }
  
  if (args.length < 2) {
    print("错误: 参数不足");
    print("至少需要一个文件夹路径和一个缓存文件路径");
    return;
  }
  
  // 最后一个参数是缓存文件路径，其余都是文件夹路径
  final cacheFilePath = args.last;
  final folderPaths = args.sublist(0, args.length - 1);
  
  stdout.writeln('');
  stdout.writeln('=' * 60);
  stdout.writeln('图像特征缓存生成器');
  stdout.writeln('=' * 60);
  stdout.writeln('文件夹数量: ${folderPaths.length}');
  for (var i = 0; i < folderPaths.length; i++) {
    stdout.writeln('  [$i+1] ${folderPaths[i]}');
  }
  stdout.writeln('缓存文件: $cacheFilePath');
  stdout.writeln('=' * 60);
  stdout.writeln('');
  
  await precomputeAndCacheMultiple(folderPaths, cacheFilePath);
  
  stdout.writeln('');
  stdout.writeln('=' * 60);
  stdout.writeln('✓ 完成！');
  stdout.writeln('=' * 60);
}