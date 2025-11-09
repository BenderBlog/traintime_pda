// Copyright 2025 Hazuki Keatsu and contributors
// SPDX-License-Identifier: MPL-2.0

import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:yaml/yaml.dart';

/// Builder for generating static i18n maps from YAML files
/// 
/// This generator converts all YAML files in assets/non_ui_i18n/
/// to a single Dart file with static Maps for use without BuildContext.
class NonUII18nBuilder implements Builder {
  static const _triggerFile = 'assets/non_ui_i18n/README.md';
  static const _localePattern = 'assets/non_ui_i18n/*.yaml';
  static const _outputPath = 'lib/generated/non_ui_i18n.g.dart';
  
  @override
  Map<String, List<String>> get buildExtensions => const {
        _triggerFile: [_outputPath]
      };

  @override
  Future<void> build(BuildStep buildStep) async {
    log.info('Starting non-UI i18n generation...');
    
    // Collect all locale files
    final localeDataMap = <String, Map>{};
    final glob = Glob(_localePattern);
    
    await for (final input in buildStep.findAssets(glob)) {
      final content = await buildStep.readAsString(input);
      final yamlMap = loadYaml(content) as Map;
      
      // Extract locale from filename (e.g., zh_CN.yaml -> zh_CN)
      final filename = input.pathSegments.last;
      final locale = filename.replaceAll('.yaml', '');
      
      localeDataMap[locale] = yamlMap;
      log.info('Loaded locale: $locale');
    }

    if (localeDataMap.isEmpty) {
      log.warning('No locale files found!');
      return;
    }

    log.info('Loaded ${localeDataMap.length} locales');

    // Generate unified Dart code
    final buffer = StringBuffer();
    _writeHeader(buffer);
    _writeClass(buffer, localeDataMap);

    // Create output file
    final outputId = AssetId(
      buildStep.inputId.package,
      _outputPath,
    );
    await buildStep.writeAsString(outputId, buffer.toString());
    
    log.info('Generated non-UI i18n file successfully');
  }

  void _writeHeader(StringBuffer buffer) {
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('// This file is auto-generated from non_ui_i18n YAML files');
    buffer.writeln('// Generated at: ${DateTime.now().toIso8601String()}');  
    buffer.writeln();
  }

  void _writeClass(StringBuffer buffer, Map<String, Map> localeDataMap) {
    buffer.writeln('/// Static i18n class for non-UI translations');
    buffer.writeln('/// Supports multiple locales without BuildContext');
    buffer.writeln('class NonUII18n {');
    buffer.writeln('  NonUII18n._();');
    buffer.writeln();
    
    // Write available locales
    buffer.writeln('  /// Available locales');
    buffer.write('  static const List<String> supportedLocales = [');
    buffer.write(localeDataMap.keys.map((l) => '"$l"').join(', '));
    buffer.writeln('];');
    buffer.writeln();
    
    // Write locale data maps
    buffer.writeln('  /// All locale data');
    buffer.writeln('  static const Map<String, Map<String, dynamic>> _localeData = {');
    localeDataMap.forEach((locale, data) {
      buffer.writeln('    "$locale": {');
      _writeMapContent(buffer, data, 3);
      buffer.writeln('    },');
    });
    buffer.writeln('  };');
    buffer.writeln();
    
    // Write get method
    buffer.writeln('  /// Get translation by locale and key');
    buffer.writeln('  static String _get(String locale, String key) {');
    buffer.writeln('    final localeMap = _localeData[locale];');
    buffer.writeln('    if (localeMap == null) return "";');
    buffer.writeln();
    buffer.writeln('    final keys = key.split(".");');
    buffer.writeln('    dynamic current = localeMap;');
    buffer.writeln('    for (final k in keys) {');
    buffer.writeln('      if (current is Map) {');
    buffer.writeln('        current = current[k];');
    buffer.writeln('      } else {');
    buffer.writeln('        return "";');
    buffer.writeln('      }');
    buffer.writeln('    }');
    buffer.writeln('    return current?.toString() ?? "";');
    buffer.writeln('  }');
    buffer.writeln();
    
    // Write getWithParams method
    buffer.writeln('  /// Get translation with parameters');
    buffer.writeln('  /// Example: NonUII18n.translate("zh_CN", "course_reminder.title", translationParams: {"name": "Maths"} )');
    buffer.writeln('  static String translate(String locale, String key, {Map<String, dynamic>? translateParams}) {');
    buffer.writeln('    var result = _get(locale, key);');
    buffer.writeln('    if (result.isEmpty) return "";');
    buffer.writeln('    if (translateParams != null) {');
    buffer.writeln('      translateParams.forEach((k, v) {');
    buffer.writeln(r'       result = result.replaceAll("{$k}", v.toString());');
    buffer.writeln('      });');
    buffer.writeln('    }');
    buffer.writeln('    return result;');
    buffer.writeln('  }');
    buffer.writeln();
    
    buffer.writeln('}');
  }

  void _writeMapContent(StringBuffer buffer, Map map, int indent) {
    final indentStr = '  ' * indent;
    map.forEach((key, value) {
      if (value is Map) {
        buffer.writeln('$indentStr"$key": {');
        _writeMapContent(buffer, value, indent + 1);
        buffer.writeln('$indentStr},');
      } else if (value is List) {
        buffer.writeln('$indentStr"$key": [');
        for (final item in value) {
          if (item is String) {
            buffer.writeln('$indentStr  "${_escapeString(item)}",');
          } else {
            buffer.writeln('$indentStr  $item,');
          }
        }
        buffer.writeln('$indentStr],');
      } else if (value is String) {
        buffer.writeln('$indentStr"$key": "${_escapeString(value)}",');
      } else {
        buffer.writeln('$indentStr"$key": $value,');
      }
    });
  }

  String _escapeString(String str) {
    return str
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"')
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r')
        .replaceAll('\t', r'\t');
  }
}

/// Builder factory for build_runner
Builder nonUII18nBuilder(BuilderOptions options) =>
    NonUII18nBuilder();

