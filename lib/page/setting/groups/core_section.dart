// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get_it/get_it.dart';
import 'package:restart_app/restart_app.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:watermeter/controller/classtable_controller.dart';
import 'package:watermeter/controller/energy_controller.dart';
import 'package:watermeter/controller/exam_controller.dart';
import 'package:watermeter/controller/other_experiment_controller.dart';
import 'package:watermeter/controller/physics_experiment_controller.dart';
import 'package:watermeter/controller/theme_controller.dart';
import 'package:watermeter/external/ruisi_flutter/lib/controller/ruisi_controller.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/setting/groups/section_setting_scaffold.dart';
import 'package:watermeter/repository/custom_class_service.dart';
import 'package:watermeter/repository/ids_session/score_session.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/repository/network_client.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/repository/widget_state_sync.dart';

class CoreSection extends StatelessWidget {
  const CoreSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SectionSettingScaffold(
      title: FlutterI18n.translate(context, "setting.core_setting"),
      items: [
        ListTile(
          title: Text(FlutterI18n.translate(context, "setting.check_logger")),
          trailing: const Icon(Icons.navigate_next),
          onTap: () => context.pushReplacement(TalkerScreen(talker: log)),
        ),

        ListTile(
          title: Text(
            FlutterI18n.translate(context, "setting.clear_and_restart"),
          ),
          trailing: const Icon(Icons.navigate_next),
          onTap: () => showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => AlertDialog(
              title: Text(
                FlutterI18n.translate(
                  context,
                  "setting.clear_and_restart_dialog.title",
                ),
              ),
              content: Text(
                FlutterI18n.translate(
                  context,
                  "setting.clear_and_restart_dialog.content",
                ),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(FlutterI18n.translate(context, "cancel")),
                ),
                TextButton(
                  onPressed: () async {
                    ProgressDialog pd = ProgressDialog(context: context);
                    pd.show(
                      msg: FlutterI18n.translate(
                        context,
                        "setting.clear_and_restart_dialog.cleaning",
                      ),
                    );

                    /// Clean Cookie
                    try {
                      await NetworkCookieJars.ids.deleteAll();
                      await NetworkCookieJars.schoolnet.deleteAll();
                      await NetworkCookieJars.sport.deleteAll();
                      // I don't care.
                      // ignore: empty_catches
                    } on Exception {}

                    /// Clean cache.
                    ClassTableController.i.session.deleteCache();
                    EnergyController.i.session.deleteCache();
                    EnergyController.i.session.clearElectricityHistory();
                    ExamController.i.session.deleteCache();
                    OtherExperimentController.i.session.deleteCache();
                    PhysicsExperimentController.i.session.deleteCache();
                    ScoreSession.deleteCache();

                    if (context.mounted) {
                      showToast(
                        context: context,
                        msg: FlutterI18n.translate(
                          context,
                          "setting.clear_and_restart_dialog.clear",
                        ),
                      );
                      if (Platform.isIOS) {
                        Restart.restartApp(
                          mode: RestartMode.notificationFallback,
                          notificationTitle: FlutterI18n.translate(
                            context,
                            "restart_app.title_cache_cleared",
                          ),
                          notificationBody: FlutterI18n.translate(
                            context,
                            "restart_app.content",
                          ),
                        );
                      } else {
                        Restart.restartApp();
                      }
                    }
                  },
                  child: Text(FlutterI18n.translate(context, "confirm")),
                ),
              ],
            ),
          ),
        ),
        ListTile(
          title: Text(FlutterI18n.translate(context, "setting.logout")),
          trailing: const Icon(Icons.navigate_next),
          onTap: () => showDialog<String>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => AlertDialog(
              title: Text(
                FlutterI18n.translate(context, "setting.logout_dialog.title"),
              ),
              content: Text(
                FlutterI18n.translate(context, "setting.logout_dialog.content"),
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(FlutterI18n.translate(context, "cancel")),
                ),
                TextButton(
                  onPressed: () async {
                    ProgressDialog pd = ProgressDialog(context: context);
                    pd.show(
                      msg: FlutterI18n.translate(
                        context,
                        "setting.logout_dialog.logging_out",
                      ),
                    );

                    /// Clean Cookie
                    try {
                      await NetworkCookieJars.ids.deleteAll();
                      await NetworkCookieJars.schoolnet.deleteAll();
                      await NetworkCookieJars.sport.deleteAll();
                      // I don't care.
                      // ignore: empty_catches
                    } on Exception {}

                    /// Clean all.
                    ClassTableController.i.session.deleteCache();
                    EnergyController.i.session.deleteCache();
                    EnergyController.i.session.clearElectricityHistory();
                    ExamController.i.session.deleteCache();
                    OtherExperimentController.i.session.deleteCache();
                    PhysicsExperimentController.i.session.deleteCache();
                    ScoreSession.deleteCache();

                    for (var value in [
                      CustomClassRepository.fileName,
                      ClassTableController.decorationName,
                    ]) {
                      var file = File("${supportPath.path}/$value");
                      if (file.existsSync()) {
                        file.deleteSync();
                      }
                    }
                    try {
                      await GetIt.instance<RuisiService>().logout();
                    } catch (e, s) {
                      log.error(e, s);
                    }

                    /// Clean user information
                    await preference.prefrenceClear();

                    /// Theme back to default
                    ThemeController.i.updateTheme();

                    /// Sync widget login state
                    await syncWidgetLoginState(false);

                    /// Clean iOS widget data files
                    await clearWidgetFiles();

                    /// Restart app
                    if (context.mounted) {
                      pd.close();
                      if (Platform.isIOS) {
                        Restart.restartApp(
                          mode: RestartMode.notificationFallback,
                          notificationTitle: FlutterI18n.translate(
                            context,
                            "restart_app.title_logged_out",
                          ),
                          notificationBody: FlutterI18n.translate(
                            context,
                            "restart_app.content",
                          ),
                        );
                      } else {
                        Restart.restartApp();
                      }
                    }
                  },
                  child: Text(FlutterI18n.translate(context, "confirm")),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
