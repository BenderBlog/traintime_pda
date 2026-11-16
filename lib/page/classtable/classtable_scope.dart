// Copyright 2026 Traintime PDA Authours, originally by BenderBlog Rodriguez.
// SPDX-License-Identifier: MPL-2.0

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/page/classtable/model/classtable_widget_state.dart';

class ClasstableScope extends InheritedNotifier<ClasstableWidgetState> {
  const ClasstableScope({
    super.key,
    required ClasstableWidgetState state,
    required super.child,
  }) : super(notifier: state);

  static ClasstableWidgetState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ClasstableScope>();
    assert(scope != null, "No ClasstableScope above this context.");
    return scope!.notifier!;
  }

  /// The state, without subscribing the calling widget to its changes.
  static ClasstableWidgetState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<ClasstableScope>();
    assert(scope != null, "No ClasstableScope above this context.");
    return scope!.notifier!;
  }
}
