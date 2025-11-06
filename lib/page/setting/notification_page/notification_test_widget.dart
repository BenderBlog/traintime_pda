// Copyright 2025 Hazuki Keatsu and contributors
// Copyright 2025 Traintime PDA authors.
// SPDX-License-Identifier: MPL-2.0

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:watermeter/page/public_widget/re_x_card.dart';
import 'package:watermeter/page/public_widget/toast.dart';
import 'package:watermeter/repository/notification/course_reminder.dart';
import 'package:watermeter/repository/notification/notification_base.dart';

/// 通知测试组件 - 用于调试通知功能
class NotificationTestWidget extends StatefulWidget {
  const NotificationTestWidget({super.key});

  @override
  State<NotificationTestWidget> createState() => _NotificationTestWidgetState();
}

class _NotificationTestWidgetState extends State<NotificationTestWidget> {
  final NotificationBase _notificationBase = NotificationBase();
  final CourseReminder _courseReminder = CourseReminder();

  List<PendingNotificationRequest> _allNotifications = [];
  List<PendingNotificationRequest> _courseNotifications = [];
  List<PendingNotificationRequest> _otherNotifications = [];
  bool _isLoading = false;

  final TextEditingController _idController = TextEditingController();
  final TextEditingController _titleController = TextEditingController(
    text: '测试通知标题',
  );
  final TextEditingController _bodyController = TextEditingController(
    text: '这是一条测试通知内容',
  );
  final TextEditingController _delayController = TextEditingController(
    text: '5',
  );

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  @override
  void dispose() {
    _idController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    _delayController.dispose();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _allNotifications = await _notificationBase.getPendingNotifications();

      const int notificationIdPrefix = 10000;
      final int minId = notificationIdPrefix * 10000;
      final int maxId = minId + 100000;

      _courseNotifications = _allNotifications.where((n) {
        return n.id >= minId && n.id < maxId;
      }).toList();

      _otherNotifications = _allNotifications.where((n) {
        return n.id < minId || n.id >= maxId;
      }).toList();

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        showToast(context: context, msg: '加载失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelNotification(int id) async {
    try {
      await _notificationBase.cancelNotification(id);
      if (mounted) {
        showToast(context: context, msg: '已取消通知 ID: $id');
      }
      await _loadNotifications();
    } catch (e) {
      if (mounted) {
        showToast(context: context, msg: '取消失败: $e');
      }
    }
  }

  Future<void> _cancelAll() async {
    try {
      await _courseReminder.cancelAllCourseNotifications();
      if (mounted) {
        showToast(context: context, msg: '已清除所有课程通知');
      }
      await _loadNotifications();
    } catch (e) {
      if (mounted) {
        showToast(context: context, msg: '取消失败: $e');
      }
    }
  }

  Future<void> _sendTest(NotificationMode mode) async {
    try {
      final now = DateTime.now();
      final testId = mode == NotificationMode.normal ? 99990 : 99991;

      final payload = {
            'type': 'course_reminder',
            'className': 'test',
            'weekIndex': 1,
            'weekday': 1,
            'startClass': 1,
          };

      await _notificationBase.scheduleNotification(
        id: testId,
        title: '测试通知 (${mode == NotificationMode.normal ? '普通' : '增强'})',
        body: '${mode.name}模式测试\n${now.hour}:${now.minute}:${now.second}',
        scheduledTime: now.add(const Duration(seconds: 2)),
        mode: mode,
        payload: jsonEncode(payload),
      );

      if (mounted) {
        showToast(context: context, msg: '已安排测试通知(2秒后)');
      }
      await _loadNotifications();
    } catch (e) {
      if (mounted) {
        showToast(context: context, msg: '发送失败: $e');
      }
    }
  }

  Future<void> _createCustom() async {
    try {
      final idText = _idController.text.trim();
      if (idText.isEmpty) {
        showToast(context: context, msg: '请输入ID');
        return;
      }

      final id = int.tryParse(idText);
      if (id == null) {
        showToast(context: context, msg: 'ID必须是数字');
        return;
      }

      final delay = int.tryParse(_delayController.text) ?? 5;

      await _notificationBase.scheduleNotification(
        id: id,
        title: _titleController.text,
        body: _bodyController.text,
        scheduledTime: DateTime.now().add(Duration(seconds: delay)),
        mode: NotificationMode.normal,
      );

      if (mounted) {
        showToast(context: context, msg: '已创建 ID:$id ($delay秒后)');
      }
      await _loadNotifications();
    } catch (e) {
      if (mounted) {
        showToast(context: context, msg: '创建失败: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ReXCard(
      title: Text(
        '通知调试工具(Release 模式隐藏)',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ).padding(bottom: 8).center(),
      remaining: const [],
      bottomRow: _isLoading
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 刷新按钮
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _loadNotifications,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('刷新', style: TextStyle(fontSize: 13)),
                  ),
                ),
                const SizedBox(height: 8),

                // 通知统计
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        '总通知数',
                        _allNotifications.length.toString(),
                        Icons.notifications,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatItem(
                        '课程通知',
                        _courseNotifications.length.toString(),
                        Icons.school,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(),

                // 其他通知列表
                if (_otherNotifications.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '其他通知列表',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ..._otherNotifications.map(
                    (n) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'ID: ${n.id}',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                  ),
                                  onPressed: () => _cancelNotification(n.id),
                                  tooltip: '删除',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            if (n.title != null) ...[
                              const SizedBox(height: 4),
                              const Text('标题:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              Text(
                                n.title!,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                            if (n.body != null) ...[
                              const SizedBox(height: 4),
                              const Text('内容:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              Text(
                                n.body!,
                                style: const TextStyle(fontSize: 11),
                                overflow: TextOverflow.clip,
                              ),
                            ],
                            if (n.payload != null) ...[
                              const SizedBox(height: 4),
                              const Text('载荷:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              Text(
                                n.payload!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                                overflow: TextOverflow.clip,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                ],

                // 课程通知列表
                if (_courseNotifications.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '课程通知列表',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ..._courseNotifications.map(
                    (n) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'ID: ${n.id}',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                  ),
                                  onPressed: () => _cancelNotification(n.id),
                                  tooltip: '删除',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            if (n.title != null) ...[
                              const SizedBox(height: 4),
                              const Text('标题:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              Text(
                                n.title!,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                            if (n.body != null) ...[
                              const SizedBox(height: 4),
                              const Text('内容:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              Text(
                                n.body!,
                                style: const TextStyle(fontSize: 11),
                                overflow: TextOverflow.clip,
                              ),
                            ],
                            if (n.payload != null) ...[
                              const SizedBox(height: 4),
                              const Text('载荷:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              Text(
                                n.payload!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                                overflow: TextOverflow.clip,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _cancelAll,
                      icon: const Icon(Icons.delete_sweep, size: 18),
                      label: const Text('清除全部课程通知'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ] else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        '暂无课程通知',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ),

                const Divider(height: 24),

                // 快速测试
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    '快速测试',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _sendTest(NotificationMode.normal),
                        icon: const Icon(
                          Icons.notifications_outlined,
                          size: 18,
                        ),
                        label: const Text('普通', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _sendTest(NotificationMode.enhanced),
                        icon: const Icon(Icons.notifications_active, size: 18),
                        label: const Text('增强', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    '发送测试通知（2秒后触发，ID: 99990/99991），payLoad=[\'type\': \'course_reminder\']',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ),

                const Divider(height: 24),

                // 自定义通知
                const Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Text(
                    '创建自定义通知',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _idController,
                        decoration: const InputDecoration(
                          labelText: 'ID',
                          hintText: '12345',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _delayController,
                        decoration: const InputDecoration(
                          labelText: '延迟(秒)',
                          hintText: '5',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: '标题',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _bodyController,
                  decoration: const InputDecoration(
                    labelText: '内容',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  maxLines: 2,
                  style: const TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _createCustom,
                    icon: const Icon(Icons.add_alert, size: 18),
                    label: const Text('创建通知', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color ?? Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
