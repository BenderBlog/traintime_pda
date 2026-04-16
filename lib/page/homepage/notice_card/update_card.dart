// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:signals/signals_flutter.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/controller/update_notice_controller.dart';
import 'package:watermeter/page/homepage/home_card_padding.dart';
import 'package:watermeter/page/setting/dialogs/update_dialog.dart';

class UpdateCard extends StatelessWidget {
  const UpdateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final state = UpdateNoticeController.i.updateMessageStateSignal.value;
      if (state.isLoading || state.isRefreshing) {
        return Text(FlutterI18n.translate(context, "setting.fetching_update"))
            .paddingDirectional(horizontal: 16, vertical: 14)
            .withHomeCardStyle(context);
      } else if (state.hasError) {
        return Text(FlutterI18n.translate(context, "setting.fetch_failed"))
            .paddingDirectional(horizontal: 16, vertical: 14)
            .withHomeCardStyle(context);
      } else {
        switch (UpdateNoticeController.i.isNewVersionAvaliableComputed.value) {
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
                      builder: (context) =>
                          UpdateDialog(updateMessage: state.value!),
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
