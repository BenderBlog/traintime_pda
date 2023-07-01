import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

/// Used for Background Updates using Workmanager Plugin
@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    return Future.wait<bool?>([
      //TODO do background updates

      //TODO update all widgets
      HomeWidget.updateWidget(name: 'ElectricityWidgetProvider', iOSName: ''),
    ]).then((value) {
      return !value.contains(false);
    });
  });
}

/// Called when Doing Background Work initiated from Widget
/// [data] uri passed from the native
@pragma("vm:entry-point")
void backgroundCallback(Uri? data) async {
  if (data?.scheme != 'widget') {
    return;
  }
  //only for scheme 'widget'
  final widgetName = data?.queryParameters['widgetName'];
  if (widgetName == null) {
    return;
  }
  switch (widgetName) {
    case 'ElectricityWidget':
      //TODO refresh the data of electricity
      break;
    case 'ClassTableWidget':
      //TODO process events from classTableWidget
      break;
    default:
  }
}
