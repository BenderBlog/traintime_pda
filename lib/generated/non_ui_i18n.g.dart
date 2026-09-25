// GENERATED CODE - DO NOT MODIFY BY HAND
// This file is auto-generated from non_ui_i18n YAML files
// Generated at: 2026-09-20T00:46:07.953893

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
        "body": "Class starts in {time} minutes",
        "location": "Location: {location}",
        "teacher": "Teacher: {teacher}",
      },
      "course_live_update": {
        "period": "Period {start}-{stop}",
        "period_single": "Period {start}",
        "next_class": "Next {time} · {location}",
        "upcoming_start": "Starts soon",
        "no_location": "No classroom",
      },
    },
    "zh_CN": {
      "course_reminder": {
        "title": "课前提醒：{name}",
        "body": "{time} 分钟后开始上课",
        "location": "地点：{location}",
        "teacher": "教师：{teacher}",
      },
      "course_live_update": {
        "period": "第 {start}-{stop} 节",
        "period_single": "第 {start} 节",
        "next_class": "下一节 {time} · {location}",
        "upcoming_start": "即将开始",
        "no_location": "未知教室",
      },
    },
    "zh_TW": {
      "course_reminder": {
        "title": "課前提醒：{name}",
        "body": "{time} 分鐘後開始上課",
        "location": "地點：{location}",
        "teacher": "教師：{teacher}",
      },
      "course_live_update": {
        "period": "第 {start}-{stop} 節",
        "period_single": "第 {start} 節",
        "next_class": "下一節 {time} · {location}",
        "upcoming_start": "即將開始",
        "no_location": "未知教室",
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
  static String translate(
    String locale,
    String key, {
    Map<String, dynamic>? translateParams,
  }) {
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
