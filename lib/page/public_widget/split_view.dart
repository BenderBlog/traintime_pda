// Copyright 2024 BenderBlog Rodriguez and contributors.
// SPDX-License-Identifier: MPL-2.0

// From https://github.com/TerminalStudio/flutter_split_view/blob/main/lib/flutter_split_view.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/split_page_placeholder.dart';
import 'package:watermeter/repository/logger.dart';

const _kDefaultWidth = 300.0;

const _kDefaultBreakpoint = 600.0;

typedef PageBuilder = Page Function({
  required LocalKey key,
  required Widget child,
  String? title,
  Object? arguments,
  String? restorationId,
  bool? fullscreenDialog,
});

MaterialPage<void> _materialPageBuilder({
  required LocalKey key,
  required Widget child,
  String? title,
  Object? arguments,
  String? restorationId,
  bool? fullscreenDialog,
}) =>
    MaterialPage<void>(
      name: title,
      arguments: arguments,
      key: key,
      restorationId: restorationId,
      child: child,
      fullscreenDialog: fullscreenDialog ?? false,
    );

CupertinoPage<void> _cupertinoPageBuilder({
  required LocalKey key,
  required Widget child,
  String? title,
  Object? arguments,
  String? restorationId,
  bool? fullscreenDialog,
}) =>
    CupertinoPage<void>(
      title: title,
      arguments: arguments,
      key: key,
      restorationId: restorationId,
      child: child,
      fullscreenDialog: fullscreenDialog ?? false,
    );

class _PageConfig {
  final Widget child;
  final String? name;
  final Object? arguments;
  final String? restorationId;
  final bool? fullscreenDialog;

  _PageConfig({
    required this.child,
    this.name,
    this.arguments,
    this.restorationId,
    this.fullscreenDialog,
  });
}

/// A widget that splits the screen into two views automatically when the
/// device's width is greater than [breakpoint].
class SplitView extends StatefulWidget {
  const SplitView.material(
      {super.key,
      required this.child,
      this.childWidth = _kDefaultWidth,
      this.breakpoint = _kDefaultBreakpoint,
      this.placeholder,
      this.title,
      this.hideDivider})
      : pageBuilder = _materialPageBuilder;

  const SplitView.cupertino(
      {super.key,
      required this.child,
      this.childWidth = _kDefaultWidth,
      this.breakpoint = _kDefaultBreakpoint,
      this.placeholder,
      this.title,
      this.hideDivider})
      : pageBuilder = _cupertinoPageBuilder;

  const SplitView.custom(
      {super.key,
      required this.child,
      this.childWidth = _kDefaultWidth,
      this.breakpoint = _kDefaultBreakpoint,
      this.placeholder,
      this.title,
      required this.pageBuilder,
      this.hideDivider});

  static SplitViewState of(BuildContext context) {
    final state = context.findAncestorStateOfType<SplitViewState>();
    assert(state != null, 'No SplitViewState found in the context');
    return state!;
  }

  /// The width threshold at which the secondary view will be shown.
  final double breakpoint;

  /// The root page.
  final Widget child;

  /// Width of the child when it is in the main view.
  final double childWidth;

  /// Title of the root page, used for the back button in Cupertino.
  final String? title;

  /// Placeholder widget to show when the secondary view is visible and no page
  /// is selected.
  final Widget? placeholder;

  final PageBuilder pageBuilder;

  /// If true hides the vertical divider
  final bool? hideDivider;

  @override
  SplitViewState createState() => SplitViewState();
}

class SplitViewState extends State<SplitView> {
  var _pages = <Page>[];

  final _pageConfigs = <_PageConfig>[];

  var _splitted = false;

  @override
  void initState() {
    _pageConfigs.add(
      _PageConfig(child: widget.child, name: widget.title),
    );
    _updatePages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) {
        _splitted = constrains.maxWidth >= widget.breakpoint;

        if (!_splitted) {
          return Navigator(
            pages: _pages,
            onPopPage: _onPopPage,
          );
        }

        return Row(
          children: <Widget>[
            SizedBox(
              width: widget.childWidth,
              child: Navigator(
                pages: [_pages.first],
                onPopPage: _onPopPage,
              ),
            ),
            if (!(widget.hideDivider == true))
              const VerticalDivider(
                width: 1,
              ),
            Expanded(
              child: ClipRect(
                clipBehavior: Clip.hardEdge,
                child: _buildSecondaryView(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSecondaryView() {
    if (_pages.length == 1) {
      return widget.placeholder ?? const SplitPagePlaceholder();
    }

    return Navigator(
      pages: _pages.sublist(1),
      onPopPage: _onPopPage,
    );
  }

  void push(
    Widget page, {
    String? title,
    Object? arguments,
    String? restorationId,
    bool? fullscreenDialog,
  }) {
    final pageConfig = _PageConfig(
      child: page,
      name: title,
      arguments: arguments,
      restorationId: restorationId,
      fullscreenDialog: fullscreenDialog,
    );

    _pageConfigs.add(pageConfig);

    setState(_updatePages);
  }

  void pop() {
    if (_pageConfigs.length == 1) {
      return;
    }

    _pageConfigs.removeLast();

    setState(_updatePages);
  }

  /// Number of pages in the stack.
  int get pageCount => _pageConfigs.length;

  /// Replaces the page at [index] with [page].
  void replace({
    required int index,
    required Widget page,
    String? title,
    Object? arguments,
    String? restorationId,
    bool? fullscreenDialog,
  }) {
    _pageConfigs[index] = _PageConfig(
      child: NavigatorPopHandler(
        onPop: () {
          log.i("Poping");
          SplitView.of(context).pop();
        },
        child: page,
      ),
      name: title,
      arguments: arguments,
      restorationId: restorationId,
      fullscreenDialog: fullscreenDialog,
    );

    setState(_updatePages);
  }

  /// Pops the pages until the [index]-th is reached.
  void popUntil(int index) {
    if (index < 0 || index >= pageCount) {
      throw ArgumentError('Index $index is out of bounds');
    }

    while (pageCount - 1 > index) {
      _pageConfigs.removeLast();
    }

    setState(_updatePages);
  }

  /// Sets the page displayed at seconday view. This clears all other pages on
  /// top of the page displayed at secondary view (aka 2nd page in the stack).
  void setSecondary(
    Widget page, {
    String? title,
    Object? arguments,
    String? restorationId,
    bool? fullscreenDialog,
  }) {
    _pageConfigs.removeRange(1, _pageConfigs.length);

    _pageConfigs.add(
      _PageConfig(
        child: page,
        name: title,
        arguments: arguments,
        restorationId: restorationId,
        fullscreenDialog: fullscreenDialog,
      ),
    );

    setState(_updatePages);
  }

  bool get isSecondaryVisible {
    return _splitted;
  }

  void _updatePages() {
    final pages = <Page>[];
    for (var i = 0; i < _pageConfigs.length; i++) {
      final pageConfig = _pageConfigs[i];
      final pageKey = ValueKey(i);
      final page = widget.pageBuilder(
        key: pageKey,
        child: pageConfig.child,
        title: pageConfig.name,
        arguments: pageConfig.arguments,
        restorationId: pageConfig.restorationId,
      );
      pages.add(page);
    }
    _pages = pages;
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    if (_pageConfigs.length <= 1) {
      return false;
    }
    if (route.didPop(result)) {
      _pageConfigs.removeLast();
      _updatePages();
      return true;
    }
    return false;
  }
}
