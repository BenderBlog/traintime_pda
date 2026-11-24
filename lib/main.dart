// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:catcher_2/catcher_2.dart';
import 'package:material_ui/material_ui.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/core/logging/talker_app_logger.dart';
import 'package:watermeter/core/logging/talker_report_handler.dart';
import 'package:watermeter/core/presentation/crush_page/pda_page_report_mode.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/integration/setup/start_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Init logger
  final talker = TalkerFlutter.init(
    logger: TalkerLogger(output: (message) => debugPrint(message)),
  );
  final logger = TalkerAppLogger(talker);

  // Init slang
  LocaleSettings.useDeviceLocaleSync();
  final t = LocaleSettings.instance.getTranslations(
    LocaleSettings.currentLocale,
  );

  // Init catcher_2
  Catcher2.addDefaultErrorWidget(
    showStacktrace: true,
    title: t.common.unexpectProblemTitle,
    description: t.common.unexpectProblemHint,
    maxWidthForSmallMode: 150,
  );
  final options = Catcher2Options(
    PdaPageReportMode(showStackTrace: true),
    [ConsoleHandler()],
    localizationOptions: [
      LocalizationOptions.buildDefaultChineseOptions(),
      LocalizationOptions.buildDefaultEnglishOptions(),
    ],
    logger: PDACatcher2Logger(logger),
  );

  logger.info("[main] All the inits before startApp are accomplished.");

  Catcher2(
    runAppFunction: () => unawaited(startApp(logger, talker)),
    debugConfig: options,
    profileConfig: options,
    releaseConfig: options,
    enableLogger: false,
  );
}
