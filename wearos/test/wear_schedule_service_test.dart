import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:watermeter/model/fetch_result.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/model/xidian_ids/experiment.dart';
import 'package:watermeter/repository/network_session.dart' as network;
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';
import 'package:watermeter/repository/xidian_ids/school_card_session.dart';
import 'package:watermeter/repository/xidian_ids/sysj_session.dart';
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
    test('network sync preserves successful agenda and balance data', () async {
      final now = DateTime(2026, 5, 19, 8);
      final table = _singleCourseTable('数据库系统');
      var experimentNetworkCalled = false;

      final result = await loadWearHomeData(
        semesterCode: '2026-1',
        now: now,
        classTableFetcher: (_) async =>
            FetchResult.fresh(fetchTime: now, data: table),
        otherExperimentFetcher: () async {
          experimentNetworkCalled = true;
          throw StateError('experiment fetch should not run');
        },
        balanceFetcher: () async => '¥12.34',
      );

      expect(result.data.balanceText, '¥12.34');
      expect(result.data.todayItems.map((item) => item.title), ['数据库系统']);
      expect(result.failures, isEmpty);
      expect(result.hasUsableData, isTrue);
      expect(experimentNetworkCalled, isFalse);
    });

    test(
      'cached fetch result records source warning while keeping data',
      () async {
        final now = DateTime(2026, 5, 19, 8);
        final table = _singleCourseTable('操作系统');

        final result = await loadWearHomeData(
          semesterCode: '2026-1',
          now: now,
          classTableFetcher: (_) async => FetchResult.cache(
            fetchTime: now,
            data: table,
            hintKey: 'classtable.cache_hint_network_failed',
          ),
          otherExperimentFetcher: () async =>
              FetchResult.fresh(fetchTime: now, data: const <ExperimentData>[]),
          balanceFetcher: () async => '¥12.34',
        );

        expect(result.data.todayItems.map((item) => item.title), ['操作系统']);
        expect(result.failures.map((failure) => failure.source), [
          WearDataSource.classTable,
        ]);
        expect(result.failures.single.error, isA<WearCachedDataException>());
      },
    );

    test('cache-only load does not call network fetchers', () async {
      final now = DateTime(2026, 5, 19, 8);
      final table = _singleCourseTable('离线课程');
      var classNetworkCalled = false;
      var experimentNetworkCalled = false;
      var balanceNetworkCalled = false;

      final result = await loadCachedWearHomeData(
        semesterCode: '2026-1',
        now: now,
        classTableCacheLoader: (_) =>
            FetchResult.cache(fetchTime: now, data: table, hintKey: null),
        otherExperimentCacheLoader: () => null,
        classTableFetcher: (_) async {
          classNetworkCalled = true;
          throw StateError('network class fetch should not run');
        },
        otherExperimentFetcher: () async {
          experimentNetworkCalled = true;
          throw StateError('network experiment fetch should not run');
        },
        balanceFetcher: () async {
          balanceNetworkCalled = true;
          return '¥0.00';
        },
      );

      expect(result.data.todayItems.map((item) => item.title), ['离线课程']);
      expect(result.data.balanceText, isNull);
      expect(result.failures, isEmpty);
      expect(classNetworkCalled, isFalse);
      expect(experimentNetworkCalled, isFalse);
      expect(balanceNetworkCalled, isFalse);
    });
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
      ClassTableSession.schoolClassDataCache = File(
        '${tempDir.path}/${ClassTableSession.schoolClassName}',
      );
      SysjSession.otherExperimentCacheFile = File(
        '${tempDir.path}/${SysjSession.otherExperimentCacheName}',
      );
      ClassTableSession.deleteCache();
      await SysjSession.deleteCache();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('credential import clears previous user-scoped state', () async {
      SchoolCardSession.openid = 'old-openid';
      await ClassTableSession.updateCacheAndGroup(_singleCourseTable('旧课程'));
      await SysjSession.writeCache([
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
      expect(ClassTableSession.schoolClassDataCache.existsSync(), isFalse);
      expect(SysjSession.otherExperimentCacheFile.existsSync(), isFalse);
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

    test('imports credentials for future mobile-device transport', () async {
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

        expect(
          ClassTableSession.getCache()?.$2.classDetail.single.name,
          '同步课程',
        );
        expect(SysjSession.getCache()?.$2.single.name, '同步实验');
        final cachedHome = await loadCachedWearHomeData(
          semesterCode: '2026-1',
          now: DateTime(2026, 5, 19, 8),
        );
        expect(
          preference.getString(preference.Preference.currentSemester),
          '2026-1',
        );
        expect(
          cachedHome.data.todayItems.map((item) => item.title),
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
      expect(
        ClassTableSession.getCache()?.$2.classDetail.single.name,
        '扫码同步课程',
      );
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
