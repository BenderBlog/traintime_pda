import 'package:flutter/material.dart';
import 'package:watermeter/page/setting/notification_page/notification_test_widget.dart';
import 'package:watermeter/repository/notification/notification_registrar.dart';

class NotificationDebugPage extends StatefulWidget {
  const NotificationDebugPage({super.key});

  @override
  State<StatefulWidget> createState() => _NotificationDebugPageState();
}

class _NotificationDebugPageState extends State<NotificationDebugPage> {
  @override
  Widget build(BuildContext context) {
    final services = NotificationServiceRegistrar().getAllServices();
    if (services.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('通知服务调试页面')),
        body: const Center(child: Text('暂无通知服务')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text('通知服务调试页面')),
      body: Center(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: NotificationServiceRegistrar()
              .getAllServices()
              .map(
                (service) =>
                    NotificationTestWidget(notificationService: service),
              )
              .toList(),
        ),
      ),
    );
  }
}
