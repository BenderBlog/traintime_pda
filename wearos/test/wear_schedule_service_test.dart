import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/repository/network_session.dart' as network;
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/xidian_ids/school_card_session.dart';
import 'package:watermeter/wearos/wear_cache_store.dart';
import 'package:watermeter/wearos/wear_companion_sync.dart';
import 'package:watermeter/wearos/wear_schedule_service.dart';

void main() {
  group('Wear agenda conversion', () {
    test('course items use target date week and class-period times', () {
      final table = ClassTableData(
        semesterLength: 2,
        semesterCode: '2026-1',
        termStartDay: '2026-05-18 00:00:00',
        classDetail: [ClassDetail(name: '编译原理', code: 'CS301', number: '01')],
        timeArrangement: [
          TimeArrangement(
            source: Source.school,
            index: 0,
            weekList: [true, false],
            teacher: '张老师',
            classroom: 'B-101',
            day: DateTime.tuesday,
            start: 1,
            stop: 2,
          ),
        ],
      );

      final firstWeekItems = WearAgendaBuilder.courseItemsForDay(
        table,
        DateTime(2026, 5, 19),
      );
      final secondWeekItems = WearAgendaBuilder.courseItemsForDay(
        table,
        DateTime(2026, 5, 26),
      );

      expect(firstWeekItems, hasLength(1));
      expect(firstWeekItems.single.kind, WearAgendaKind.course);
      expect(firstWeekItems.single.title, '编译原理');
      expect(firstWeekItems.single.subtitle, '张老师');
      expect(firstWeekItems.single.location, 'B-101');
      expect(firstWeekItems.single.start, DateTime(2026, 5, 19, 8, 30));
      expect(firstWeekItems.single.end, DateTime(2026, 5, 19, 10, 5));
      expect(secondWeekItems, isEmpty);
    });

    test('other experiment items keep target-day ranges', () {
      final experiments = [
        ExperimentData(
          type: ExperimentType.others,
          name: '电工实习',
          classroom: '工程坊',
          timeRanges: [(DateTime(2026, 5, 19, 14), DateTime(2026, 5, 19, 16))],
          teacher: '王老师',
        ),
        ExperimentData(
          type: ExperimentType.others,
          name: '工程训练',
          classroom: '工程坊',
          timeRanges: [(DateTime(2026, 5, 20, 14), DateTime(2026, 5, 20, 16))],
          teacher: '刘老师',
        ),
      ];

      final items = WearAgendaBuilder.experimentItemsForDay(
        experiments,
        DateTime(2026, 5, 19),
      );

      expect(items, hasLength(1));
      expect(items.single.kind, WearAgendaKind.otherExperiment);
      expect(items.single.title, '电工实习');
      expect(items.single.subtitle, '王老师');
      expect(items.single.location, '工程坊');
      expect(items.single.start, DateTime(2026, 5, 19, 14));
      expect(items.single.end, DateTime(2026, 5, 19, 16));
    });

    test('school card reset clears cached openid between users', () {
      SchoolCardSession.openid = 'previous-user-openid';

      SchoolCardSession.resetOpenId();

      expect(SchoolCardSession.openid, isEmpty);
    });
  });

  group('Wear home loading', () {
    test(
      'cache-only load builds the agenda without network fetchers',
      () async {
        final now = DateTime(2026, 5, 19, 8);
        final table = _singleCourseTable('离线课程');

        final data = await loadCachedWearHomeData(
          semesterCode: '2026-1',
          now: now,
          classTableCacheLoader: (_) => table,
          otherExperimentCacheLoader: () => null,
        );

        expect(data.todayItems.map((item) => item.title), ['离线课程']);
      },
    );
  });

  group('Wear companion sync interface', () {
    late Directory tempDir;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.empty();
      preference.prefs = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(),
      );
      tempDir = await Directory.systemTemp.createTemp('wear-sync-test-');
      network.supportPath = tempDir;
      WearClassTableCache.file = File(
        '${tempDir.path}/${WearClassTableCache.fileName}',
      );
      WearExperimentCache.file = File(
        '${tempDir.path}/${WearExperimentCache.fileName}',
      );
      await WearClassTableCache.clear();
      await WearExperimentCache.clear();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('credential import clears previous user-scoped state', () async {
      SchoolCardSession.openid = 'old-openid';
      await WearClassTableCache.write(_singleCourseTable('旧课程'));
      await WearExperimentCache.write([
        ExperimentData(
          type: ExperimentType.others,
          name: '旧实验',
          classroom: '实验楼',
          timeRanges: [(DateTime(2026, 5, 19, 10), DateTime(2026, 5, 19, 11))],
          teacher: '旧老师',
        ),
      ]);
      await preference.setString(
        preference.Preference.currentSemester,
        'old-term',
      );
      await preference.setBool(preference.Preference.role, true);
      await preference.setBool(
        preference.Preference.isUserDefinedSemester,
        true,
      );

      await WearLocalCompanionSyncPort().importCredentials(
        const WearCredentialSyncPayload(
          idsAccount: '2200000001',
          idsPassword: 'new-secret',
        ),
      );

      expect(SchoolCardSession.openid, isEmpty);
      expect(WearClassTableCache.file.existsSync(), isFalse);
      expect(WearExperimentCache.file.existsSync(), isFalse);
      expect(
        preference.getString(preference.Preference.currentSemester),
        isEmpty,
      );
      expect(preference.getBool(preference.Preference.role), isFalse);
      expect(
        preference.getBool(preference.Preference.isUserDefinedSemester),
        isFalse,
      );
      expect(
        preference.getString(preference.Preference.idsAccount),
        '2200000001',
      );
    });

    test('imports credentials for watch payment authentication', () async {
      await WearLocalCompanionSyncPort().importCredentials(
        const WearCredentialSyncPayload(
          idsAccount: '2200000000',
          idsPassword: 'secret',
          isPostGraduate: true,
          currentSemester: '2026-1',
        ),
      );

      expect(
        preference.getString(preference.Preference.idsAccount),
        '2200000000',
      );
      expect(preference.getString(preference.Preference.idsPassword), 'secret');
      expect(preference.getBool(preference.Preference.role), isTrue);
      expect(
        preference.getString(preference.Preference.currentSemester),
        '2026-1',
      );
    });

    test(
      'imports class table and other experiments into local caches',
      () async {
        final table = _singleCourseTable('同步课程');
        final experiment = ExperimentData(
          type: ExperimentType.others,
          name: '同步实验',
          classroom: '实验楼',
          timeRanges: [(DateTime(2026, 5, 19, 10), DateTime(2026, 5, 19, 11))],
          teacher: '同步老师',
        );

        await WearLocalCompanionSyncPort().importSchedule(
          WearScheduleSyncPayload(
            classTable: table,
            otherExperiments: [experiment],
          ),
        );

        expect(WearClassTableCache.read()?.$2.classDetail.single.name, '同步课程');
        expect(WearExperimentCache.read()?.$2.single.name, '同步实验');
        final cachedHome = await loadCachedWearHomeData(
          semesterCode: '2026-1',
          now: DateTime(2026, 5, 19, 8),
        );
        expect(
          preference.getString(preference.Preference.currentSemester),
          '2026-1',
        );
        expect(
          cachedHome.todayItems.map((item) => item.title),
          contains('同步课程'),
        );
      },
    );

    test('imports bundled native sync payload from companion phone', () async {
      final table = _singleCourseTable('扫码同步课程');
      final envelope = WearCompanionSyncEnvelope.fromJson({
        'schemaVersion': 1,
        'sessionId': 'session-123',
        'credentials': {
          'idsAccount': '2200000002',
          'idsPassword': 'synced-secret',
          'isPostGraduate': false,
          'currentSemester': 'fallback-term',
        },
        'schedule': {'classTable': table.toJson()},
        'paymentQr': {'pngBase64': 'AQID', 'fetchedAtEpochMs': 1785816000000},
      });

      await envelope.importInto(const WearLocalCompanionSyncPort());

      expect(
        preference.getString(preference.Preference.idsAccount),
        '2200000002',
      );
      expect(
        preference.getString(preference.Preference.idsPassword),
        'synced-secret',
      );
      expect(
        preference.getString(preference.Preference.currentSemester),
        '2026-1',
      );
      expect(WearClassTableCache.read()?.$2.classDetail.single.name, '扫码同步课程');
      expect(
        File('${network.supportPath.path}/WearPaymentQr.png').readAsBytesSync(),
        [1, 2, 3],
      );
    });

    test('rejects malformed native sync payloads', () {
      expect(
        () => WearCompanionSyncEnvelope.fromJson({
          'schemaVersion': 1,
          'sessionId': 'session-123',
          'schedule': {'classTable': _singleCourseTable('缺少凭据').toJson()},
        }),
        throwsFormatException,
      );
      expect(
        () => WearCompanionSyncEnvelope.fromJson({
          'schemaVersion': 1,
          'sessionId': 'session-123',
          'credentials': {'idsAccount': '2200000002', 'idsPassword': 'secret'},
        }),
        throwsFormatException,
      );
    });
  });
}

ClassTableData _singleCourseTable(String name) {
  return ClassTableData(
    semesterLength: 1,
    semesterCode: '2026-1',
    termStartDay: '2026-05-18 00:00:00',
    classDetail: [ClassDetail(name: name)],
    timeArrangement: [
      TimeArrangement(
        source: Source.school,
        index: 0,
        weekList: [true],
        teacher: '赵老师',
        classroom: 'A-301',
        day: DateTime.tuesday,
        start: 3,
        stop: 4,
      ),
    ],
  );
}
