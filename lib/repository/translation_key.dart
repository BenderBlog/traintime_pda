// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:watermeter/generated/translations.g.dart';

/// Resolves paths supplied by models or selected at runtime through Slang.
/// Static translations should use the generated properties directly.
extension TranslationKey on Translations {
  String resolveKey(String key, {Map<String, Object> params = const {}}) {
    final parts = key.split('.');
    if (parts.length == 1) parts.insert(0, 'common');
    final path = parts
        .map((part) {
          final words = part.split('_');
          final name =
              words.first +
              words
                  .skip(1)
                  .map(
                    (word) => word.isEmpty
                        ? ''
                        : word[0].toUpperCase() + word.substring(1),
                  )
                  .join();
          return name == 'default' ? 'kDefault' : name;
        })
        .join('.');

    final value = this[path];
    if (value is String) return value;
    if (value is Function) {
      // 带占位符的翻译在 slang 里是函数。这里必须把调用方给的参数传进去：
      // 之前是无参调用，凡是有必填参数的键（例如 "xx 秒后可重新获取"）都会抛
      // NoSuchMethodError: Closure call with mismatched arguments，二次认证弹窗
      // 因此直接崩掉。另外整段包一层兜底：翻译解析失败不该让界面挂掉。
      try {
        return Function.apply(value, const [], {
              for (final entry in params.entries)
                Symbol(entry.key): entry.value,
            })
            as String;
      } catch (_) {
        return key;
      }
    }
    // Errors returned by external services may already be human-readable.
    return key;
  }
}
