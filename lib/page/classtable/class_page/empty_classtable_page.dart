import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/public_widget/empty_list_view.dart';
import 'package:watermeter/page/public_widget/toast.dart';

class EmptyClassTablePage extends StatelessWidget {
  const EmptyClassTablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "classtable.page_title")),
        leading: IconButton(
          icon: Icon(
            Platform.isIOS || Platform.isMacOS
                ? Icons.arrow_back_ios
                : Icons.arrow_back,
          ),
          onPressed: () =>
              Navigator.of(ClassTableState.of(context)!.parentContext).pop(),
        ),
      ),
      body: [
        EmptyListView(
          type: EmptyListViewType.defaultimg,
          text: FlutterI18n.translate(
            context,
            ClassTableState.of(
                  context,
                )!.controllers.examController.data.subject.isEmpty
                ? "classtable.empty_class_message"
                : "classtable.empty_class_with_exam",
            translationParams: {
              "semester_code": ClassTableState.of(
                context,
              )!.controllers.semesterCode,
            },
          ),
        ),
        TextButton.icon(
          onPressed: () async {
            showToast(
              context: context,
              msg: FlutterI18n.translate(
                context,
                "classtable.refresh_classtable.ready",
              ),
            );
            await ClassTableState.of(
              context,
            )!.controllers.updateClasstable(context).then((data) {
              if (context.mounted) {
                showToast(
                  context: context,
                  msg: FlutterI18n.translate(
                    context,
                    "classtable.refresh_classtable.success",
                  ),
                );
              }
            });
          },
          icon: const Icon(Icons.update),
          label: Text(
            FlutterI18n.translate(
              context,
              "classtable.popup_menu.refresh_classtable",
            ),
          ),
        ),
      ].toColumn(),
    );
  }
}
