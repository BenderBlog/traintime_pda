import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/util/legacy_to_async_migration_util.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_session.dart' as network;
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/xidian_ids/ids_session.dart';
import 'package:watermeter/repository/xidian_ids/classtable_session.dart';
import 'package:watermeter/wearos/wear_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  log.info('Starting XDYou Wear.');
  network.supportPath = await getApplicationSupportDirectory();

  const options = SharedPreferencesOptions();
  final legacyPrefs = await SharedPreferences.getInstance();
  if (legacyPrefs.getKeys().isNotEmpty) {
    await migrateLegacySharedPreferencesToSharedPreferencesAsyncIfNecessary(
      legacySharedPreferencesInstance: legacyPrefs,
      sharedPreferencesAsyncOptions: options,
      migrationCompletedKey: 'pdaMigrationCompleted',
    );
  }

  preference.prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );

  final semester = preference.getString(preference.Preference.currentSemester);
  var isCompanionPaired = false;
  try {
    isCompanionPaired =
        await const MethodChannel(
          'io.github.benderblog.traintime_pda/wear_companion_sync',
        ).invokeMethod<bool>('isCompanionPaired') ??
        false;
  } on PlatformException {
    // Treat a missing/unavailable native pairing record as unpaired.
  }
  final isFirst =
      !isCompanionPaired || semester.isEmpty || !ClassTableSession.isCacheExist;
  loginState = isFirst ? IDSLoginState.manual : IDSLoginState.none;

  runApp(WearApp(isFirst: isFirst));
}
