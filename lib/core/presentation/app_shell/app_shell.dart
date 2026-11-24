// Copyright 2026 Traintime PDA authors, originally by Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'app_shell_page_interface.dart';

/// Default AppShellPage. When there is no pages passed in AppShell, it will be created to hold place.
class DefaultAppShellPage implements AppShellPageInterface {
  const DefaultAppShellPage();

  @override
  String label(BuildContext context) => 'PlaceHolder';

  @override
  Widget icon(BuildContext context) => const Icon(Icons.apps_outlined);

  @override
  Widget selectedIcon(BuildContext context) => const Icon(Icons.apps);

  @override
  Widget buildPage(BuildContext context) => const Placeholder();
}

/// The skeleton for the whole application.
class AppShell extends StatefulWidget {
  AppShell({super.key, required List<AppShellPageInterface> pages})
    : assert(pages.isNotEmpty, 'AppShell requires at least one page'),
      pages = pages.isEmpty ? const [DefaultAppShellPage()] : pages;

  final List<AppShellPageInterface> pages;

  /// The helper for the inner page get the state by build context.
  ///
  /// Used for router operation. For example:
  ///
  /// ```dart
  /// AppShell.of(context).pushDetail(detailPage);
  /// AppShell.of(context).replaceDetail(anotherPage);
  /// AppShell.of(context).popDetail();
  /// ```
  static AppShellState of(BuildContext context) {
    final state = context.findAncestorStateOfType<AppShellState>();
    if (state == null) throw StateError('No AppShell found in the widget tree');
    return state;
  }

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  /// The main area and detail area both need to 364 logic pixels to display.
  ///
  /// So when the screen width is more than 729 pixels (364 * 2 + 1), the detail area would appear.
  static const double _minPaneWidth = 364;

  /// The divider's width between two panes.
  static const double _dividerWidth = 1;

  /// The hit width of the divider.
  ///
  /// This is the difference from the v1.0 design. The origin dividerHitWidth is 1,
  /// so that it is very hard to drag the divider in v1.0.
  static const double _dividerHitWidth = 12;

  final _detailKey = GlobalKey<NavigatorState>();
  final _masterKey = GlobalKey();
  late final _detailObserver = _DetailObserver(this);
  late final _pageController = PageController();
  int _selectedIndex = 0;
  int _detailDepth = 0;
  double _masterWidth = _minPaneWidth;

  void pushDetail(Widget page) {
    _detailKey.currentState!.push(
      MaterialPageRoute<void>(builder: (_) => page),
    );
  }

  void replaceDetail(Widget page) {
    _detailKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => page),
      (route) => route.isFirst && route.isActive,
    );
  }

  void popDetail() {
    if (_detailKey.currentState?.canPop() ?? false) {
      _detailKey.currentState!.pop();
    }
  }

  void _setDetailDepth(int depth) => setState(() => _detailDepth = depth);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final master = Scaffold(
      key: _masterKey,
      extendBodyBehindAppBar: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          FocusManager.instance.primaryFocus?.unfocus();
          if (_selectedIndex != index) {
            setState(() => _selectedIndex = index);
          }
        },
        children: [
          for (final page in widget.pages)
            Builder(builder: (context) => page.buildPage(context)),
        ],
      ),
      // To avoid the invalid NavigationBar being constructed with single destination.
      bottomNavigationBar: widget.pages.length == 1
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  widget.pages.first.selectedIcon(context),
                  const SizedBox(width: 8),
                  Text(widget.pages.first.label(context)),
                ],
              ),
            )
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                if (_selectedIndex != index) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  setState(() => _selectedIndex = index);
                  _pageController.jumpToPage(index);
                }
              },
              destinations: [
                for (final page in widget.pages)
                  NavigationDestination(
                    icon: page.icon(context),
                    selectedIcon: page.selectedIcon(context),
                    label: page.label(context),
                  ),
              ],
            ),
    );

    Widget detailNavigator(Widget root) => NavigatorPopHandler(
      enabled: _detailDepth > 0,
      onPopWithResult: (result) async =>
          await _detailKey.currentState?.maybePop(result),
      child: ScaffoldMessenger(
        child: Navigator(
          key: _detailKey,
          observers: [_detailObserver],
          pages: [MaterialPage<void>(child: root)],
          onDidRemovePage: (_) {},
        ),
      ),
    );

    final placeholder = Scaffold(
      body: Center(
        child: Opacity(
          opacity: 0.25,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Image.asset('assets/Icon-App-iTunes-Background.png'),
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 2 * _minPaneWidth + _dividerWidth) {
          final width = math.min(
            math.max(_masterWidth, _minPaneWidth),
            constraints.maxWidth - _dividerWidth - _minPaneWidth,
          );
          return Stack(
            children: [
              Row(
                children: [
                  SizedBox(width: width, child: master),
                  const VerticalDivider(width: _dividerWidth),
                  Expanded(child: detailNavigator(placeholder)),
                ],
              ),
              Positioned(
                left: width - (_dividerHitWidth - _dividerWidth) / 2,
                top: 0,
                bottom: 0,
                width: _dividerHitWidth,
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeLeftRight,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (details) => setState(() {
                      _masterWidth = width + (details.primaryDelta ?? 0);
                    }),
                  ),
                ),
              ),
            ],
          );
        }
        return detailNavigator(master);
      },
    );
  }
}

class _DetailObserver extends NavigatorObserver {
  _DetailObserver(this.shell);

  final AppShellState shell;
  final Set<Route<dynamic>> _details = {};

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) {
      _details.add(route);
      shell._setDetailDepth(_details.length);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _details.remove(route);
    shell._setDetailDepth(_details.length);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_details.remove(route)) shell._setDetailDepth(_details.length);
  }
}
