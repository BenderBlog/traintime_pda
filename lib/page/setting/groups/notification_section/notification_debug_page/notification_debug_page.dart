import 'package:material_ui/material_ui.dart';
import 'package:watermeter/generated/translations.g.dart';
import 'package:watermeter/page/public_widget/safe_scroll_padding.dart';
import 'package:watermeter/page/setting/groups/notification_section/notification_debug_page/course_live_update_debug_card.dart';
import 'package:watermeter/page/setting/groups/notification_section/notification_debug_page/notification_test_widget.dart';
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
    return Scaffold(
      appBar: AppBar(title: Text(context.t.setting.notificationDebugPage)),
      body: ListView(
        padding: const EdgeInsets.all(16).withSafeBottom(context),
        children: [
          const CourseLiveUpdateDebugCard(),
          if (services.isEmpty)
            const Center(child: Text('暂无通知服务'))
          else
            ...services.map(
              (service) => NotificationTestWidget(notificationService: service),
            ),
        ],
      ),
    );
  }
}
