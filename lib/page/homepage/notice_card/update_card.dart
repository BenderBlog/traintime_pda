// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/homepage/home_card_padding.dart';
import 'package:watermeter/page/setting/dialogs/update_dialog.dart';
import 'package:watermeter/repository/pda_service_session.dart';

class UpdateCard extends StatelessWidget {
  const UpdateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (updateState.value == true) {
        return Text(FlutterI18n.translate(context, "setting.fetching_update"))
            .paddingDirectional(horizontal: 16, vertical: 14)
            .withHomeCardStyle(context);
      } else if (updateError.value != null) {
        return Text(FlutterI18n.translate(context, "setting.fetch_failed"))
            .paddingDirectional(horizontal: 16, vertical: 14)
            .withHomeCardStyle(context);
      } else {
        switch (isNewVersionAvaliable(updateMessage.value!)) {
          case null:
            return Text(
                  FlutterI18n.translate(context, "setting.current_testing"),
                )
                .paddingDirectional(horizontal: 16, vertical: 14)
                .withHomeCardStyle(context);
          case true:
            return Text(FlutterI18n.translate(context, "setting.new_version"))
                .paddingDirectional(horizontal: 16, vertical: 14)
                .withHomeCardStyle(
                  context,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Obx(
                        () => UpdateDialog(updateMessage: updateMessage.value!),
                      ),
                    );
                  },
                );
          case false:
            return SizedBox(height: 0);
        }
      }
    });
  }
}
