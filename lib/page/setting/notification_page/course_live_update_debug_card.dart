// Copyright 2026 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

// Debug card for the Live Update (the Android 16 notification which the system
// shows on the status bar, in the "island" of the vendors which have one, and on
// the lock screen) of the ongoing class.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/display_corner.dart';
import 'package:watermeter/repository/notification/course_live_update_service.dart';
import 'package:watermeter/repository/notification/course_reminder_service.dart';

/// 实时更新 / 灵动岛调试组件
class CourseLiveUpdateDebugCard extends StatefulWidget {
  const CourseLiveUpdateDebugCard({super.key});

  @override
  State<CourseLiveUpdateDebugCard> createState() =>
      _CourseLiveUpdateDebugCardState();
}

class _CourseLiveUpdateDebugCardState extends State<CourseLiveUpdateDebugCard> {
  bool _isSupported = false;
  bool _hasNotificationPermission = false;
  bool _isBusy = false;

  DisplayCornerRadii _corners = DisplayCornerRadii.zero;
  EdgeInsets _systemInsets = EdgeInsets.zero;

  List<CourseLiveUpdateEvent> _upcoming = [];
  Map<String, dynamic> _diagnostics = const {};

  /// 岛上的课程徽标样式,由平台侧保存,这里只是它的镜像。
  CourseLiveUpdateBadgeStyle _badgeStyle = CourseLiveUpdateBadgeStyle.none;

  /// 上课前多久上岛(分钟),同样由平台侧保存。设置本身在「通知设置」页里。
  int _leadMinutes = kDefaultLiveUpdateLeadMinutes;

  /// 岛的总开关,也在「通知设置」页里。
  bool _isEnabled = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (mounted) {
      setState(() => _isBusy = true);
    }

    final service = CourseLiveUpdateService.instance;
    final supported = await service.isSupported();
    final permission = supported
        ? await CourseReminderService().checkNotificationPermission()
        : false;
    final diagnostics = supported
        ? await service.diagnostics()
        : const <String, dynamic>{};
    await DisplayCorner.refresh();

    if (!mounted) {
      return;
    }

    final media = MediaQuery.of(context);
    setState(() {
      _isSupported = supported;
      _hasNotificationPermission = permission;
      _diagnostics = diagnostics;
      _corners = DisplayCorner.radii;
      _systemInsets = media.viewPadding;
      _badgeStyle = CourseLiveUpdateBadgeStyle.fromIndex(
        diagnostics["badgeStyle"],
      );
      final lead =
          (diagnostics["leadMinutes"] as int?) ?? kDefaultLiveUpdateLeadMinutes;
      _leadMinutes = kLiveUpdateLeadMinuteOptions.contains(lead)
          ? lead
          : kDefaultLiveUpdateLeadMinutes;
      _isEnabled = diagnostics["enabled"] as bool? ?? true;
      _upcoming = supported
          ? service.collectEvents(daysToSchedule: 1)
          : const [];
      _isBusy = false;
    });
  }

  String _importanceName(Object? importance) {
    switch (importance) {
      case 0:
        return "无（NONE）";
      case 1:
        return "最低（MIN，不会被提升）";
      case 2:
        return "低（LOW）";
      case 3:
        return "默认（DEFAULT）";
      case 4:
        return "高（HIGH）";
      case 5:
        return "最高（MAX）";
      default:
        return "未知（$importance）";
    }
  }

  /// Shows the island for the class which comes next.
  ///
  /// With [realTime] the class keeps its own start and end, so the countdown,
  /// the progress bar and the period line agree with the classtable. Without
  /// it the class is squeezed into two minutes, which is the quick way of
  /// seeing the progress bar move.
  Future<void> _showPreview({required bool realTime}) async {
    setState(() => _isBusy = true);

    final next = _upcoming.isEmpty ? null : _upcoming.first;
    final useRealTime = realTime && next != null;

    final shown = await CourseLiveUpdateService.instance.showPreview(
      title: next?.title ?? "测试课程",
      body: next != null && next.body.isNotEmpty ? next.body : "B-106 · XDYou",
      periodText: next?.periodText ?? "第 3-4 节",
      nextText: next?.nextText ?? "",
      start: useRealTime ? next.start : null,
      end: useRealTime ? next.end : null,
      minutes: 2,
      periods: next?.periods ?? 2,
      color: next?.color ?? 0xFF4A6CF7,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isBusy = false);
    showToast(
      context: context,
      msg: !shown
          ? "发送失败：当前设备不支持或未授权"
          : useRealTime
          ? "已按「${next.title}」的真实时间显示，倒计时应与课表一致"
          : "已显示 2 分钟快测（时间被压缩过，不用对课表）",
    );
  }

  Future<void> _stopPreview() async {
    await CourseLiveUpdateService.instance.stopPreview();
    if (mounted) {
      showToast(context: context, msg: "已结束测试课程");
    }
  }

  /// 换一种课程徽标。
  ///
  /// 岛上正显示着课的时候,只把那一节按新样式重发一次 —— 再发一节新的会变成两个岛。
  /// 什么都没显示时才用下一节课做个预览。
  Future<void> _setBadgeStyle(CourseLiveUpdateBadgeStyle style) async {
    setState(() => _badgeStyle = style);

    final service = CourseLiveUpdateService.instance;
    await service.setBadgeStyle(style);

    final refreshed = await service.refreshCurrent();
    if (!refreshed && mounted) {
      await _showPreview(realTime: true);
    } else if (mounted) {
      showToast(context: context, msg: "已按新样式重发岛上正在上的那节课");
    }
  }

  Future<void> _scheduleNow() async {
    setState(() => _isBusy = true);
    await CourseLiveUpdateService.instance.scheduleFromCourseData(
      daysToSchedule: 1,
    );
    if (!mounted) {
      return;
    }
    setState(() => _isBusy = false);
    await _refresh();
    if (mounted) {
      showToast(context: context, msg: "已按未来 24 小时的课表排程");
    }
  }

  Future<void> _cancelAll() async {
    setState(() => _isBusy = true);
    await CourseLiveUpdateService.instance.cancelAll();
    if (!mounted) {
      return;
    }
    setState(() => _isBusy = false);
    showToast(context: context, msg: "已清空排程与显示");
  }

  String _formatTime(DateTime time) =>
      "${time.hour.toString().padLeft(2, "0")}:"
      "${time.minute.toString().padLeft(2, "0")}";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.smartphone,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                const Text(
                  "实时更新 / 灵动岛（Live Update）",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_isBusy)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 18),
                    onPressed: _refresh,
                    tooltip: "刷新",
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            _infoRow(
              "平台支持",
              _isSupported ? "支持" : "不支持（需 Android 16+ / iOS 16.2+）",
            ),
            _infoRow(
              "通知权限",
              _hasNotificationPermission ? "已开启" : "未开启（去系统设置里给通知权限）",
            ),
            if (_diagnostics.containsKey("canPostPromoted"))
              _infoRow(
                "系统允许实时更新",
                _diagnostics["canPostPromoted"] == true
                    ? "是"
                    : "否（在系统设置里给本应用打开“实时更新 / 实况通知 / 原子通知”）",
              ),
            if (_diagnostics.containsKey("promotableCharacteristics"))
              _infoRow(
                "通知满足提升条件",
                _diagnostics["promotableCharacteristics"] == true ? "是" : "否",
              ),
            if (_diagnostics.containsKey("promoted"))
              _infoRow(
                "当前已被提升",
                _diagnostics["promoted"] == true
                    ? "是（岛上应该出现了）"
                    : "否（点“显示测试课程”后回到桌面，再回来刷新）",
              ),
            if (_diagnostics.containsKey("enabled"))
              _infoRow(
                "岛的总开关",
                _isEnabled ? "开（在「通知设置」页里改）" : "关（在「通知设置」页里打开）",
              ),
            if (_diagnostics.containsKey("leadMinutes"))
              _infoRow(
                "上岛提前量",
                _leadMinutes == 0
                    ? "上课时才出现（在「通知设置」页改）"
                    : "上课前 $_leadMinutes 分钟（在「通知设置」页改）",
              ),
            if (_diagnostics.containsKey("targetSdk"))
              _infoRow("目标 SDK", "API ${_diagnostics["targetSdk"]}"),
            if (_diagnostics.containsKey("channelImportance"))
              _infoRow(
                "通知渠道重要性",
                _importanceName(_diagnostics["channelImportance"]),
              ),
            if (_diagnostics.containsKey("activities"))
              _infoRow("进行中的灵动岛", "${_diagnostics["activities"]} 个"),
            _infoRow(
              "系统底部安全区",
              "${_systemInsets.bottom.toStringAsFixed(1)} dp",
            ),
            _infoRow(
              "屏幕圆角半径",
              "左上 ${_corners.topLeft.toStringAsFixed(1)} / "
                  "右上 ${_corners.topRight.toStringAsFixed(1)} / "
                  "左下 ${_corners.bottomLeft.toStringAsFixed(1)} / "
                  "右下 ${_corners.bottomRight.toStringAsFixed(1)} dp",
            ),

            /// 徽标由平台侧的代码决定，iOS 上没有这个设置。
            if (Platform.isAndroid) ...[
              const Divider(height: 20),

              const Text(
                "岛上的课程徽标",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<CourseLiveUpdateBadgeStyle>(
                  segments: [
                    for (final style in CourseLiveUpdateBadgeStyle.values)
                      ButtonSegment(value: style, label: Text(style.label)),
                  ],
                  selected: {_badgeStyle},
                  showSelectedIcon: false,
                  onSelectionChanged: (values) => _setBadgeStyle(values.first),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "只影响展开的通知，折叠的小胶囊里始终写课程简称。"
                "开关和提前多久上岛在「通知设置」页里。",
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isBusy
                        ? null
                        : () => _showPreview(realTime: true),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text("预览下一节课"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isBusy ? null : _stopPreview,
                    icon: const Icon(Icons.stop, size: 18),
                    label: const Text("结束测试"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isBusy
                        ? null
                        : () => _showPreview(realTime: false),
                    icon: const Icon(Icons.bolt, size: 18),
                    label: const Text("2 分钟快测"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isBusy ? null : _scheduleNow,
                    icon: const Icon(Icons.schedule, size: 18),
                    label: const Text("按课表排程 24h"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isBusy ? null : _cancelAll,
                icon: const Icon(Icons.delete_sweep, size: 18),
                label: const Text("清空排程与显示"),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              ),
            ),

            if (_diagnostics["canPostPromoted"] == false) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => CourseLiveUpdateService.instance
                      .openNotificationSettings(),
                  icon: const Icon(Icons.settings, size: 18),
                  label: const Text("打开通知设置（开启实时更新）"),
                ),
              ),
            ],

            const Divider(height: 20),

            Text(
              "未来 24 小时的课程（共 ${_upcoming.length} 节）",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            if (_upcoming.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "没有可用于排程的课程数据",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              )
            else
              ..._upcoming
                  .take(12)
                  .map(
                    (event) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Color(event.color),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "${_formatTime(event.start)} - ${_formatTime(event.end)}",
                            style: const TextStyle(
                              fontSize: 12,
                              fontFamily: "monospace",
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event.title,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (event.end.isBefore(DateTime.now()))
                            const Text(
                              "已结束",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

            const SizedBox(height: 8),
            Text(
              Platform.isIOS
                  ? "iOS 只能在 App 运行时开启灵动岛：点“显示测试课程”后回桌面/锁屏看顶部，"
                        "或上课前打开一次 App。"
                  : "上岛要点：① 系统为 Android 16 及以上，且厂商做了这套实时通知"
                        "（小米叫超级岛，OPPO 叫流体云，vivo 叫原子岛，荣耀叫灵动胶囊，"
                        "三星叫 Now Bar）；"
                        "② 系统里给本应用开着“实时更新 / 实况通知 / 原子通知”这类开关；"
                        "③ 点“显示测试课程”后请回桌面或锁屏看状态栏 —— App 在前台时系统通常不显示岛屿；"
                        "④ 回到本页点右上角刷新，“当前已被提升”会变成“是”。",
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
