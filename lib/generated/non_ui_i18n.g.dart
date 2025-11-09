// GENERATED CODE - DO NOT MODIFY BY HAND
// This file is auto-generated from non_ui_i18n YAML files
// Generated at: 2025-11-09T17:11:25.860991

/// Static i18n class for non-UI translations
/// Supports multiple locales without BuildContext
class NonUII18n {
  NonUII18n._();

  /// Available locales
  static const List<String> supportedLocales = ["en_US", "zh_CN", "zh_TW"];

  /// All locale data
  static const Map<String, Map<String, dynamic>> _localeData = {
    "en_US": {
      "course_reminder": {
        "title": "Pre-class Reminder: {name}",
        "body": "Class starts in {minutes} minutes",
        "location": "Location: {location}",
        "teacher": "Teacher: {teacher}",
      },
    },
    "zh_CN": {
      "course_reminder": {
        "title": "课前提醒：{name}",
        "body": "{time} 分钟后开始上课",
        "location": "地点：{location}",
        "teacher": "教师：{teacher}",
      },
    },
    "zh_TW": {
      "course_reminder": {
        "title": "課前提醒：{name}",
        "body": "{time} 分鐘後開始上課",
        "location": "地點：{location}",
        "teacher": "教師：{teacher}",
      },
    },
  };

  /// Get translation by locale and key
  static String _get(String locale, String key) {
    final localeMap = _localeData[locale];
    if (localeMap == null) return "";

    final keys = key.split(".");
    dynamic current = localeMap;
    for (final k in keys) {
      if (current is Map) {
        current = current[k];
      } else {
        return "";
      }
    }
    return current?.toString() ?? "";
  }

  /// Get translation with parameters
  /// Example: NonUII18n.translate("zh_CN", "course_reminder.title", translationParams: {"name": "Maths"} )
  static String translate(String locale, String key, {Map<String, dynamic>? translateParams}) {
    var result = _get(locale, key);
    if (result.isEmpty) return "";
    if (translateParams != null) {
      translateParams.forEach((k, v) {
       result = result.replaceAll("{$k}", v.toString());
      });
    }
    return result;
  }

}
