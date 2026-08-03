import 'package:flutter_test/flutter_test.dart';

import 'dart:convert';
import 'package:device_calendar_plus/device_calendar_plus.dart';
import 'package:watermeter/repository/system_calendar_sync_service.dart';

void main() {
  test('buildICalendarString with Chinese chars', () {
    final events = [
      CalendarEventDraft(
        title: '思想政治理论实践课@信远楼',
        description: '课程名称：思想政治理论实践课 - 老师：张三',
        startDate: DateTime(2025, 9, 1, 8, 30),
        endDate: DateTime(2025, 9, 1, 10, 0),
        location: '信远楼101',
        recurrenceRule: WeeklyRecurrence(
          daysOfWeek: [DayOfWeek.monday],
          end: UntilEnd(DateTime.utc(2026, 1, 10)),
        ),
      ),
      CalendarEventDraft(
        title: '考试信息：高等数学@教学楼A',
        description: '考试：高等数学 - 期末考试',
        startDate: DateTime(2026, 1, 15, 9, 0),
        endDate: DateTime(2026, 1, 15, 11, 0),
        location: '教学楼A-301',
      ),
    ];

    final icalStr = buildICalendarString(events);

    // 1) String content is intact
    expect(icalStr, contains('思想政治理论实践课'));
    expect(icalStr, contains('信远楼101'));
    expect(icalStr, contains('高等数学'));
    expect(icalStr, contains('RRULE:FREQ=WEEKLY;INTERVAL=1;BYDAY=MO'));

    // 2) codeUnits (UTF-16) differs from utf8.encode (UTF-8) for non-ASCII
    final codeUnitsBytes = icalStr.codeUnits;
    final utf8Bytes = utf8.encode(icalStr);
    expect(codeUnitsBytes, isNot(equals(utf8Bytes)));

    // 3) utf8 bytes decode back to the same string
    expect(utf8.decode(utf8Bytes), equals(icalStr));

    // 4) Decoding codeUnits as utf8 should NOT round-trip
    //    (this is the bug: writing UTF-16 bytes to a file that expects UTF-8)
    final brokenRoundtrip = utf8.decode(codeUnitsBytes, allowMalformed: true);
    expect(brokenRoundtrip, isNot(contains('思想政治理论实践课')));

    // 5) Specific: "思" = U+601D, UTF-8 = E6 80 9D
    final needle = utf8.encode('思想政治');
    expect(_containsBytes(utf8Bytes, needle), isTrue,
        reason: 'UTF-8 bytes must contain proper Chinese encoding');

    // 6) Valid iCal structure
    expect(icalStr, startsWith('BEGIN:VCALENDAR'));
    expect(icalStr, endsWith('END:VCALENDAR\n'));
    expect(icalStr, contains('BEGIN:VEVENT'));
    expect(icalStr, contains('END:VEVENT'));
  });
}

bool _containsBytes(List<int> haystack, List<int> needle) {
  if (needle.length > haystack.length) return false;
  for (int i = 0; i <= haystack.length - needle.length; i++) {
    bool found = true;
    for (int j = 0; j < needle.length; j++) {
      if (haystack[i + j] != needle[j]) {
        found = false;
        break;
      }
    }
    if (found) return true;
  }
  return false;
}
