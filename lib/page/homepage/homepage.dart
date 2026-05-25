// Copyright 2023-2025 BenderBlog Rodriguez and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:watermeter/page/homepage/homepage_edit_mode.dart';
import 'package:watermeter/page/homepage/homepage_widget_registry.dart';
import 'package:watermeter/page/homepage/info_widget/classtable_card.dart';
import 'package:watermeter/page/homepage/notice_card/update_card.dart';
import 'package:watermeter/page/homepage/staggered_grid.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/page/homepage/refresh.dart';
import 'package:watermeter/repository/notification/course_reminder_service.dart';
import 'package:watermeter/repository/logger.dart';
import 'package:watermeter/page/login/jc_captcha.dart';

class MainPage extends StatefulWidget {
  final Function()? changePage;

  const MainPage({super.key, this.changePage});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  bool _editMode = false;
  late List<HomepageWidgetEntry> _allEntries;
  final Map<String, double> _shakeAmplitudes = {};
  final Set<String> _fadingEntries = {};

  static const _gridColumns = 4;

  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _shakeAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
    );
    _allEntries = getOrderedEntries();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await CourseReminderService().initialize();
        await CourseReminderService().validateAndUpdateNotifications();
        log.info(
          "Notifications validated and updated after homepage initialization.",
        );
      } catch (e, stackTrace) {
        log.error(
          "Failed to validate notifications after homepage initialization",
          e,
          stackTrace,
        );
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _exitEditMode() {
    setState(() {
      _editMode = false;
      _shakeAmplitudes.clear();
      _fadingEntries.clear();
      _shakeController.stop();
      _allEntries = getOrderedEntries();
    });
  }

  void _onSwap(String draggedId, String targetId) {
    setState(() {
      final from = _allEntries.indexWhere((e) => e.id == draggedId);
      final to = _allEntries.indexWhere((e) => e.id == targetId);
      if (from == -1 || to == -1) return;
      final item = _allEntries.removeAt(from);
      _allEntries.insert(to > from ? to - 1 : to, item);
      saveOrder(_allEntries.map((e) => e.id).toList());
    });
  }

  Widget _buildShake(String id, Widget child) {
    final amplitude = _shakeAmplitudes[id] ?? 0.85;
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (_, child) => Transform.rotate(
        angle: _shakeAnimation.value * amplitude,
        child: child!,
      ),
      child: child,
    );
  }

  void _showHiddenSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        final hidden = getHiddenEntries();
        if (hidden.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              FlutterI18n.translate(context, "homepage.hide_empty"),
              textAlign: TextAlign.center,
            ),
          );
        }
        return ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                FlutterI18n.translate(context, "homepage.hidden_title"),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final entry in hidden)
              ListTile(
                title: Text(FlutterI18n.translate(context, entry.titleKey)),
                trailing: IconButton(
                  icon: const Icon(Icons.visibility),
                  onPressed: () async {
                    await unhideEntry(entry.id);
                    if (context.mounted) {
                      Navigator.pop(context);
                      setState(() => _allEntries = getOrderedEntries());
                    }
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final gridEntries = _allEntries.toList();
    final displayEntries = filterHidden(gridEntries);

    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, "homepage.title")),
        actions: [
          if (_editMode) ...[
            IconButton(
              icon: const Icon(Icons.visibility),
              tooltip: FlutterI18n.translate(context, "homepage.manage_hidden"),
              onPressed: _showHiddenSheet,
            ),
            IconButton(
              icon: const Icon(Icons.restore),
              tooltip: FlutterI18n.translate(context, "homepage.edit_reset"),
              onPressed: () async {
                await resetAll();
                setState(() => _allEntries = getOrderedEntries());
              },
            ),
          ],
          Padding(
            padding: EdgeInsetsGeometry.only(right: 8),
            child: IconButton(
              icon: Icon(_editMode ? Icons.check : Icons.edit),
              tooltip: FlutterI18n.translate(
                context,
                _editMode ? "homepage.edit_done" : "homepage.edit_mode",
              ),
              onPressed: () {
                if (_editMode) {
                  _exitEditMode();
                } else {
                  setState(() {
                    _editMode = true;
                    _shakeAmplitudes.clear();
      _fadingEntries.clear();
                    for (final entry in _allEntries) {
                      _shakeAmplitudes[entry.id] =
                          0.7 + Random().nextDouble() * 0.3;
                    }
                  });
                  _shakeController.repeat(reverse: true);
                }
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          showToast(
            context: context,
            msg: FlutterI18n.translate(context, "homepage.loading_message"),
          );
          await update(
            context: context,
            sliderCaptcha: (String cookieStr) {
              return SliderCaptchaClientProvider(
                cookie: cookieStr,
              ).solve(context);
            },
          );
          if (context.mounted) {
            showToast(
              context: context,
              msg: FlutterI18n.translate(context, "homepage.loaded"),
            );
          }
        },
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: [
            const UpdateCard(),
            const ClassTableCard(),
            if (_editMode)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  FlutterI18n.translate(context, "homepage.edit_hint"),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // ---- 统一网格 ----
            StaggeredGrid(
              crossAxisCount: _gridColumns,
              rowHeight: 80,
              builder: (colWidth) => [
                for (final entry in displayEntries)
                  StaggeredGridCell(
                    crossAxisCellCount: entry.gridSpan,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _fadingEntries.contains(entry.id) ? 0.0 : 1.0,
                      child: _editMode
                          ? _buildShake(
                            entry.id,
                            Stack(
                              fit: StackFit.expand,
                              children: [
                                DraggableCard(
                                  id: entry.id,
                                  onSwap: _onSwap,
                                  feedbackWidth: entry.gridSpan * colWidth,
                                  feedbackHeight: 80,
                                  child: entry.builder(context, _editMode),
                                ),
                                // 隐藏按钮：右上角（课程表不显示）
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _fadingEntries.add(entry.id));
                                      Future.delayed(
                                        const Duration(milliseconds: 300),
                                        () async {
                                          await hideEntry(entry.id);
                                          _fadingEntries.remove(entry.id);
                                          if (context.mounted) {
                                            setState(() =>
                                                _allEntries = getOrderedEntries());
                                          }
                                        },
                                      );
                                    },
                                    child: ClipOval(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.surfaceContainerHighest,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : entry.builder(context, _editMode),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
