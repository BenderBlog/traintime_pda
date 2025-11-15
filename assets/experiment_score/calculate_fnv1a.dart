// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

void main(List<String> arguments) async {
  // 检查是否提供了文件夹路径参数
  if (arguments.isEmpty) {
    print('请提供文件夹路径作为参数');
    print('用法: dart md5_calculator.dart <文件夹路径> [输出JSON路径]');
    return;
  }

  // 获取输入文件夹路径
  final directoryPath = arguments[0];
  final directory = Directory(directoryPath);

  // 检查文件夹是否存在
  if (!await directory.exists()) {
    print('错误: 文件夹 "$directoryPath" 不存在');
    return;
  }

  // 确定输出文件路径（默认在当前目录生成md5_hashes.json）
  final outputPath = arguments.length > 1 ? arguments[1] : 'score_hashes.json';

  try {
    // 计算所有文件的哈希值并收集结果
    final Map<String, int> fileHashes = {};
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        // 获取相对路径作为文件名标识
        final relativePath = path.relative(entity.path, from: directoryPath);
        print('正在计算: $relativePath');

        // 计算哈希值
        final hash = await _calculatePixelFNV1A(entity);
        fileHashes[relativePath.substring(0, relativePath.length - 4)] = hash;
      }
    }

    // 保存结果到JSON文件
    final outputFile = File(outputPath);
    await outputFile.writeAsString(
      json.encode(fileHashes, toEncodable: (obj) => obj.toString()),
      mode: FileMode.write,
    );

    print('计算完成，共处理 ${fileHashes.length} 个文件');
    print('结果已保存到: ${outputFile.absolute.path}');
  } catch (e) {
    print('处理过程中发生错误: $e');
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
        pixelBytes.addAll([pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()]);
      }
    }
  }

  var hash = 0x811C9DC5;
  for (var p in pixelBytes) {
    hash ^= p;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }

  return hash;
}
