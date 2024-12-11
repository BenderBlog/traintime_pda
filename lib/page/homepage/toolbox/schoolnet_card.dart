// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:sn_progress_dialog/progress_dialog.dart';
import 'package:watermeter/page/homepage/small_function_card.dart';
import 'package:watermeter/page/public_widget/context_extension.dart';
import 'package:watermeter/page/setting/dialogs/schoolnet_password_dialog.dart';
import 'package:watermeter/repository/preference.dart' as preference;
import 'package:watermeter/page/public_widget/captcha_input_dialog.dart';
import 'package:watermeter/repository/schoolnet_session.dart';

class SchoolnetCard extends StatelessWidget {
  const SchoolnetCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SmallFunctionCard(
      onTap: () async {
        if (preference
            .getString(
              preference.Preference.schoolNetQueryPassword,
            )
            .isEmpty) {
          await showDialog(
            context: context,
            builder: (context) => const SchoolNetPasswordDialog(),
          );
        }
        if (context.mounted) {
          ProgressDialog pd = ProgressDialog(context: context);
          pd.show(
              msg: FlutterI18n.translate(
            context,
            "school_net.fetching",
          ));
          await SchoolnetSession()
              .getNetworkUsage(
                  captchaFunction: (memoryImage) => showDialog<String>(
                        context: context,
                        builder: (context) =>
                            CaptchaInputDialog(image: memoryImage),
                      ).then((value) => value ?? ""))
              .then((value) {
            pd.close();
            if (context.mounted) {
              String toShow = FlutterI18n.translate(
                  context, "school_net.basic_message",
                  translationParams: {
                    "used": value.used,
                    "rest": value.rest,
                    "charged": value.charged,
                  });
              for (var i in value.ipList) {
                toShow += "\n";
                toShow += FlutterI18n.translate(
                  context,
                  "school_net.detail_message",
                  translationParams: {
                    "ip": i.$1,
                    "time": i.$3,
                    "amount": i.$2,
                  },
                );
              }
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  scrollable: true,
                  title: Text(FlutterI18n.translate(
                    context,
                    "school_net.dialog_title",
                  )),
                  content: Text(toShow),
                  actions: [
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(FlutterI18n.translate(
                        context,
                        "confirm",
                      )),
                    )
                  ],
                ),
              );
            }
          }).onError((e, __) {
            pd.close();
            if (context.mounted) {
              if (e.toString() == "EmptyPasswordException") {
                Fluttertoast.showToast(
                  msg: FlutterI18n.translate(
                    context,
                    "school_net.empty_password",
                  ),
                );
              } else if (e is NotInitalizedException) {
                Fluttertoast.showToast(
                  msg: FlutterI18n.translate(
                    context,
                    "school_net.error_fetch",
                    translationParams: {
                      "msg": e.msg ?? "Unknown",
                    },
                  ),
                );
              } else {
                Fluttertoast.showToast(
                  msg: FlutterI18n.translate(
                    context,
                    "school_net.error_other",
                    translationParams: {
                      "msg": e.toString(),
                    },
                  ),
                );
              }
            }
          });
        }
      },
      icon: MingCuteIcons.mgc_wifi_line,
      nameKey: "homepage.toolbox.schoolnet",
    );
  }
}
