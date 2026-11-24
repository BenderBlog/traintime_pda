// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:async';

import 'package:catcher_2/catcher_2.dart';
import 'package:material_ui/material_ui.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/core/logging/talker_app_logger.dart';
import 'package:watermeter/core/logging/talker_report_handler.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/integration/setup/start_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Init logger
  final logger = TalkerAppLogger(TalkerFlutter.init());

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
    PageReportMode(showStackTrace: true),
    [
      EmailManualHandler(
        ["superbart_chen@qq.com"],
        emailTitle: "PDA 发生故障",
        emailHeader: "请作者尽快修复",
      ),
      ConsoleHandler(),
    ],
    localizationOptions: [
      LocalizationOptions.buildDefaultChineseOptions(),
      LocalizationOptions.buildDefaultEnglishOptions(),
    ],
    logger: PDACatcher2Logger(logger),
  );

  Catcher2(
    runAppFunction: () => unawaited(startApp(logger)),
    debugConfig: options,
    profileConfig: options,
    releaseConfig: options,
    enableLogger: false,
  );
}
