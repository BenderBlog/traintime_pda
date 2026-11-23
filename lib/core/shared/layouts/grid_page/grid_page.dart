// Copyright 2026 Hazuki Keatsu
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:watermeter/core/preferences/preference_store_interface.dart';
import 'package:watermeter/core/presentation/app_shell/app_shell_page_interface.dart';
import 'package:watermeter/generated/translations.g.dart';

import 'grid_page_card_interface.dart';
import 'staggered_grid.dart';

int _validatedFlex(GridPageCardInterface card) {
  final flex = card.flex();
  if (flex < 1 || flex > 4) {
    throw ArgumentError.value(flex, 'cards', 'Flex must be between 1 and 4');
  }
  return flex;
}

/// Just for avoid repetitive parameter name.
class GridPageIcons {
  final Icon icon;
  final Icon selectedIcon;

  const GridPageIcons({required this.icon, required this.selectedIcon});
}

/// Shared home grid. Card content and persistent storage are injected.
class GridPage extends StatefulWidget implements AppShellPageInterface {
  GridPage({
    super.key,
    required this.icons,
    required this.navigationLabel,
    required List<GridPageCardInterface> cards,
    required this.preferences,
  }) : // The unmodifiable List makes the dynamic modification of cards unavailable
       cards = List.unmodifiable(cards) {
    final ids = <String>{};
    for (final card in this.cards) {
      if (card.id.isEmpty || !ids.add(card.id)) {
        throw ArgumentError.value(
          card.id,
          'cards',
          'IDs must be unique and nonempty',
        );
      }
      _validatedFlex(card);
    }
  }

  final List<GridPageCardInterface> cards;
  final GridPageIcons icons;
  final String navigationLabel;
  final PreferenceStoreInterface preferences;

  @override
  String label(BuildContext context) => navigationLabel;
  @override
  Widget icon(BuildContext context) => icons.icon;
  @override
  Widget selectedIcon(BuildContext context) => icons.selectedIcon;
  @override
  Widget buildPage(BuildContext context) => this;
  @override
  State<GridPage> createState() => _GridPageState();
}

class _GridPageState extends State<GridPage>
    with SingleTickerProviderStateMixin {
  late List<GridPageCardInterface> _ordered;
  late Set<String> _hidden;
  final Map<String, double> _shakeAmplitudes = {};
  late final AnimationController _shakeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
  );
  late final Animation<double> _shake = Tween<double>(
    begin: -0.02,
    end: 0.02,
  ).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  bool _editing = false;

  String get _orderKey => 'order';
  String get _hiddenKey => 'hidden';

  List<String> _readIds(String key) {
    try {
      final decoded = jsonDecode(widget.preferences.getString(key) ?? '[]');
      if (decoded is List && decoded.every((value) => value is String)) {
        return decoded.cast<String>();
      }
    } on FormatException {
      // Corrupt saved data falls back to the supplied cards.
    }
    return [];
  }

  void _load() {
    final byId = {for (final card in widget.cards) card.id: card};
    _ordered = [
      // remove() will return the deleted value
      // So the ordered cards are put into _ordered here.
      for (final id in _readIds(_orderKey)) ?byId.remove(id),
      // The unordered or the newly inserted cards will be put into here.
      ...byId.values,
    ];
    _hidden = _readIds(_hiddenKey).toSet();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _move(String fromId, String toId) async {
    final next = [..._ordered];
    final from = next.indexWhere((card) => card.id == fromId);
    final to = next.indexWhere((card) => card.id == toId);
    if (from < 0 || to < 0 || from == to) return;
    final card = next.removeAt(from);
    next.insert(to, card);
    final known = {for (final card in widget.cards) card.id};
    final moved = next.map((card) => card.id).iterator;
    final saved = <String>[];
    final seenUnknown = <String>{};
    for (final id in _readIds(_orderKey)) {
      if (known.contains(id)) {
        if (moved.moveNext()) saved.add(moved.current);
      } else if (seenUnknown.add(id)) {
        saved.add(id);
      }
    }
    while (moved.moveNext()) {
      saved.add(moved.current);
    }
    await widget.preferences.setString(_orderKey, jsonEncode(saved));
    if (mounted) setState(() => _ordered = next);
  }

  Future<void> _hide(String id) async {
    final next = {..._hidden, id};
    await widget.preferences.setString(_hiddenKey, jsonEncode(next.toList()));
    if (mounted) setState(() => _hidden = next);
  }

  Future<void> _unhide(String id) async {
    final next = {..._hidden}..remove(id);
    await widget.preferences.setString(_hiddenKey, jsonEncode(next.toList()));
    if (mounted) setState(() => _hidden = next);
  }

  Future<void> _reset() async {
    await widget.preferences.setString(_orderKey, '[]');
    await widget.preferences.setString(_hiddenKey, '[]');
    if (mounted) setState(_load);
  }

  void _showHidden() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        final hidden = _ordered
            .where((card) => _hidden.contains(card.id))
            .toList();
        return SafeArea(
          child: hidden.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(sheetContext.t.core.gridPage.hideEmpty),
                )
              : ListView(
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        sheetContext.t.core.gridPage.manageHidden,
                        style: Theme.of(sheetContext).textTheme.titleMedium,
                      ),
                    ),
                    for (final card in hidden)
                      ListTile(
                        title: Text(card.title(sheetContext)),
                        trailing: IconButton(
                          icon: const Icon(Icons.visibility),
                          tooltip: card.title(sheetContext),
                          onPressed: () async {
                            await _unhide(card.id);
                            if (sheetContext.mounted) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _ordered
        .where((card) => !_hidden.contains(card.id))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.core.gridPage.title),
        actions: [
          if (_editing) ...[
            IconButton(
              icon: const Icon(Icons.visibility),
              tooltip: context.t.core.gridPage.manageHidden,
              onPressed: _showHidden,
            ),
            IconButton(
              icon: const Icon(Icons.restore),
              tooltip: context.t.core.gridPage.editReset,
              onPressed: _reset,
            ),
          ],
          IconButton(
            icon: Icon(_editing ? Icons.check : Icons.edit),
            tooltip: _editing
                ? context.t.core.gridPage.editDone
                : context.t.core.gridPage.editMode,
            onPressed: () {
              if (_editing) {
                _shakeController.stop();
                setState(() {
                  _editing = false;
                  _shakeAmplitudes.clear();
                });
              } else {
                final random = math.Random();
                setState(() {
                  _editing = true;
                  for (final card in _ordered) {
                    _shakeAmplitudes[card.id] = 0.7 + random.nextDouble() * 0.3;
                  }
                });
                _shakeController.repeat(reverse: true);
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          _Grid(
            cards: visible,
            editing: _editing,
            shake: _shake,
            shakeAmplitudes: _shakeAmplitudes,
            onMove: _move,
            onHide: _hide,
          ),
        ],
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({
    required this.cards,
    required this.editing,
    required this.shake,
    required this.shakeAmplitudes,
    required this.onMove,
    required this.onHide,
  });

  final List<GridPageCardInterface> cards;
  final bool editing;
  final Animation<double> shake;
  final Map<String, double> shakeAmplitudes;
  final Future<void> Function(String, String) onMove;
  final Future<void> Function(String) onHide;

  @override
  Widget build(BuildContext context) => StaggeredGrid(
    crossAxisCount: 4,
    rowHeight: 80,
    builder: (colWidth) => [
      for (final card in cards)
        StaggeredGridCell(
          crossAxisCellCount: card.flex(),
          child: Builder(
            builder: (context) {
              final cardWidth = card.flex() * colWidth;
              final child = card.buildCard(context, editing);
              final cell = SizedBox(
                key: ValueKey(card.id),
                width: cardWidth,
                height: 80,
                child: editing
                    ? DragTarget<String>(
                        onWillAcceptWithDetails: (details) =>
                            details.data != card.id,
                        onAcceptWithDetails: (details) =>
                            onMove(details.data, card.id),
                        builder: (context, candidates, rejects) =>
                            LongPressDraggable<String>(
                              data: card.id,
                              feedback: Material(
                                color: Colors.transparent,
                                child: SizedBox(
                                  width: cardWidth,
                                  height: 80,
                                  child: Opacity(opacity: 0.8, child: child),
                                ),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.15,
                                child: child,
                              ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: candidates.isNotEmpty
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                    width: 2,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    child,
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: const Icon(Icons.close, size: 16),
                                        tooltip: card.title(context),
                                        onPressed: () => onHide(card.id),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                      )
                    : child,
              );
              return editing
                  ? AnimatedBuilder(
                      animation: shake,
                      builder: (context, child) => Transform.rotate(
                        angle: shake.value * (shakeAmplitudes[card.id] ?? 0.85),
                        child: child,
                      ),
                      child: cell,
                    )
                  : cell;
            },
          ),
        ),
    ],
  );
}
