import 'dart:convert';
import 'dart:io';
import 'package:arb_utils/arb_utils.dart';

void main(List<String> args) {
  final dirPath = args.isNotEmpty ? args[0] : 'lib/l10n';
  final templateLocale = args.length > 1 ? args[1] : 'zh';
  final dir = Directory(dirPath);

  if (!dir.existsSync()) {
    stderr.writeln('Error: Directory not found: $dirPath');
    exit(1);
  }

  final arbFiles =
      dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.arb'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));

  if (arbFiles.length < 2) {
    stderr.writeln(
      'Need at least 2 .arb files to compare. Found: ${arbFiles.length}',
    );
    exit(1);
  }

  final contents = <File, String>{};
  final jsons = <File, Map<String, dynamic>>{};
  for (final f in arbFiles) {
    contents[f] = f.readAsStringSync();
    jsons[f] = jsonDecode(contents[f]!) as Map<String, dynamic>;
  }

  // Identify template by locale code
  final templateFile = arbFiles.firstWhere(
    (f) => jsons[f]!['@@locale'] == templateLocale,
    orElse: () => arbFiles.first,
  );
  final templateJson = jsons[templateFile]!;
  final templateKeys = _contentKeys(templateJson);
  final templateName = templateFile.uri.pathSegments.last;

  print('Template: $templateName (${templateJson['@@locale']})');
  print('Content keys: ${templateKeys.length}\n');

  var issues = 0;

  for (final file in arbFiles) {
    if (file.path == templateFile.path) continue;

    final arb = jsons[file]!;
    final keys = _contentKeys(arb);
    final locale = arb['@@locale'] ?? 'unknown';
    final name = file.uri.pathSegments.last;

    final diffJson =
        jsonDecode(diffARBs(contents[templateFile]!, contents[file]!))
            as Map<String, dynamic>;
    final diffKeys = _contentKeys(diffJson);

    final missing =
        diffKeys
            .where((k) => templateKeys.contains(k) && !keys.contains(k))
            .toList()
          ..sort();
    final extra =
        diffKeys
            .where((k) => !templateKeys.contains(k) && keys.contains(k))
            .toList()
          ..sort();

    print('${'─' * 60}');
    print('$name ($locale) — ${keys.length} keys');

    if (missing.isEmpty && extra.isEmpty) {
      print('  ✓ All template keys present in $locale');
      continue;
    }

    issues++;

    if (missing.isNotEmpty) {
      print('\n  Missing from $locale (${missing.length}):');
      for (final k in missing) {
        final value = templateJson[k];
        final preview = value is String ? _truncate(value, 60) : '$value';
        print('    - $k');
        print('      $templateLocale: "$preview"');
      }
    }

    if (extra.isNotEmpty) {
      print('\n  Extra in $locale (not in template) (${extra.length}):');
      for (final k in extra) {
        print('    - $k');
      }
    }
    print('');
  }

  if (issues == 0) {
    print('All translation files are in sync with the template.');
  } else {
    exit(1);
  }
}

Set<String> _contentKeys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@')).toSet();

String _truncate(String s, int len) =>
    s.length <= len ? s : '${s.substring(0, len)}…';
