// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0 OR Apache-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/page/classtable/class_page/classtable_page.dart';
import 'package:watermeter/page/classtable/classtable_scope.dart';
import 'package:watermeter/page/classtable/data/global_classtable_source.dart';
import 'package:watermeter/page/classtable/model/classtable_source.dart';
import 'package:watermeter/page/classtable/model/classtable_widget_state.dart';

/// Intro of the classtable.
class ClasstableWindow extends StatefulWidget {
  /// Where the table's data comes from.
  ///
  /// Left null on the usual path, where this window creates the live source itself; the state takes
  /// ownership of whatever is passed and disposes it.
  final ClasstableDataSource? source;

  const ClasstableWindow({super.key, this.source});

  @override
  State<ClasstableWindow> createState() => _ClasstableWindowState();
}

class _ClasstableWindowState extends State<ClasstableWindow> {
  /// TODO: Reserve the 'default' data source at the moment, due to `routes.dart`
  late final ClasstableWidgetState _state = ClasstableWidgetState(
    source: widget.source ?? GlobalClasstableDataSource(),
  );

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ClasstableScope(state: _state, child: const ClassTablePage());
}
