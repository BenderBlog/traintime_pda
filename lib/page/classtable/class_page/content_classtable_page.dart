// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';

import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/model/xidian_ids/classtable.dart';
import 'package:watermeter/page/classtable/class_add/class_add_window.dart';
import 'package:watermeter/page/classtable/class_page/class_change_list.dart';
import 'package:watermeter/page/classtable/class_page/classtable_inline_banner.dart';
import 'package:watermeter/page/classtable/class_table_view/class_table_view.dart';
import 'package:watermeter/page/classtable/class_table_view/completed_class_style.dart';
import 'package:watermeter/page/classtable/class_table_view/current_time_indicator.dart';
import 'package:watermeter/page/classtable/classtable_constant.dart';
import 'package:watermeter/page/classtable/classtable_state.dart';
import 'package:watermeter/page/classtable/class_page/not_arranged_class_list.dart';
import 'package:watermeter/page/classtable/class_page/week_choice_view.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/network_session.dart';
import 'package:watermeter/repository/preference.dart' as preference;

part 'content_classtable_page/background_decoration.dart';
part 'content_classtable_page/class_table_action_menu.dart';
part 'content_classtable_page/class_table_paging_controller.dart';
part 'content_classtable_page/load_error_dialog.dart';
part 'content_classtable_page/visual_settings_dialogs.dart';
part 'content_classtable_page/week_selector.dart';

class ContentClassTablePage extends StatefulWidget {
  const ContentClassTablePage({super.key});

  @override
  State<StatefulWidget> createState() => _ContentClassTablePageState();
}

class _ContentClassTablePageState extends State<ContentClassTablePage> {
  late final ClassTablePagingController _pagingController;
  late BoxDecoration decoration;
  late ClassTableWidgetState classTableState;
  bool _didLoadVisualSettings = false;

  @override
  void initState() {
    super.initState();
    _pagingController = ClassTablePagingController(isMounted: () => mounted);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (!_didLoadVisualSettings) {
      CurrentTimeIndicatorConfig.loadFromPreference();
      CompletedClassStyleConfig.loadFromPreference();
      _didLoadVisualSettings = true;
    }

    classTableState = ClassTableState.of(context)!.controllers;
    _pagingController.bind(
      state: classTableState,
      viewportWidth: ClassTableState.of(context)!.constraints.minWidth,
    );
    decoration = buildClassTableBackgroundDecoration(context, classTableState);
    super.didChangeDependencies();
  }

  void _refreshVisualSettings() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ClassTableState.of(context)!.controllers;
    final hasError =
        state.errorWithoutCacheSources.isNotEmpty ||
        state.errorWithCacheSources.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "classtable.page_title")),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
        actions: [
          if (hasError)
            IconButton(
              onPressed: () => showClassTableLoadErrorDialog(context),
              icon: const Icon(Icons.error_outline),
              tooltip: FlutterI18n.translate(context, "load_error"),
            ),
          ClassTableActionMenu(
            classTableState: classTableState,
            onVisualSettingsChanged: _refreshVisualSettings,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          PreferredSize(
            preferredSize: Size.fromHeight(
              MediaQuery.sizeOf(context).height >= 500
                  ? topRowHeightBig
                  : topRowHeightSmall,
            ),
            child: ClassTableWeekSelector(
              pagingController: _pagingController,
              classTableState: classTableState,
            ),
          ),
          ClassTableInlineBanner(
            loadingSources: state.loadingSources,
            cacheSources: state.cacheSources,
          ),
          DecoratedBox(
            decoration: decoration,
            child: _classTablePage(),
          ).expanded(),
        ],
      ),
    );
  }

  Widget _classTablePage() => PageView.builder(
    scrollDirection: Axis.horizontal,
    controller: _pagingController.pageController,
    onPageChanged: _pagingController.onPageChanged,
    itemCount: classTableState.semesterLength,
    itemBuilder: (context, index) => LayoutBuilder(
      builder: (context, constraint) =>
          ClassTableView(constraint: constraint, index: index),
    ),
  );
}
