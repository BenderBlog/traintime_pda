import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
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
    // 计算所有文件的MD5并收集结果
    final Map<String, String> fileHashes = {};
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        // 获取相对路径作为文件名标识
        final relativePath = path.relative(entity.path, from: directoryPath);
        print('正在计算: $relativePath');
        
        // 计算MD5
        final md5Hash = await _calculateFileMd5(entity);
        fileHashes[relativePath.substring(0, relativePath.length - 4)] = md5Hash;
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

/// 计算单个文件的MD5哈希值
Future<String> _calculateFileMd5(File file) async {
  final inputStream = file.openRead();
  final digest = await md5.bind(inputStream).first;
  return digest.toString();
}