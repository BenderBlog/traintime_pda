// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'package:catcher_2/catcher_2.dart';
import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';
import 'package:watermeter/app/app.dart';
import 'package:watermeter/app/schedule_orchestrator.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart' as repo_general;
import 'package:watermeter/repository/notification/notification_registrar.dart';
import 'package:watermeter/repository/preference.dart' as preference;

Future<void> bootstrapApp() async {
  log.info(
    "Traintime PDA Codebase is written by BenderBlog Rodriguez and contributors",
  );

  repo_general.supportPath = await getApplicationSupportDirectory();
  await _initializePreferences();
  preference.packageInfo = await PackageInfo.fromPlatform();

  final username = preference.getString(preference.Preference.idsAccount);
  final password = preference.getString(preference.Preference.idsPassword);
  final isFirst = username.isEmpty || password.isEmpty;
  log.info("isFirstLogin: $isFirst");

  configureCourseReminderApplicationBindings();

  Catcher2(
    rootWidget: XDYouApp(isFirst: isFirst),
    debugConfig: preference.catcherOptions,
    releaseConfig: preference.catcherOptions,
    navigatorKey: preference.debuggerKey,
  );

  await _initializeNotificationServices();
}

Future<void> _initializePreferences() async {
  const sharedPreferencesOptions = SharedPreferencesOptions();
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getKeys().isNotEmpty) {
    await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
      legacySharedPreferencesInstance: prefs,
      sharedPreferencesAsyncOptions: sharedPreferencesOptions,
      migrationCompletedKey: 'pdaMigrationCompleted',
    );
  }

  preference.prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );
}

Future<void> _initializeNotificationServices() async {
  try {
    await NotificationServiceRegistrar().initializeAllServices();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final services = NotificationServiceRegistrar().getAllServices();
      await Future.wait(
        services.map((service) => service.handleAppLaunchFromNotification()),
      );
    });
  } catch (e) {
    log.error('Failed to initialize notification services', e);
  }
}
