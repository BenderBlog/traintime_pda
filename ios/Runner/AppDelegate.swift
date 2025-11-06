import UIKit
import Flutter
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      // This is required to make any communication available in the action isolate.
      FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
          GeneratedPluginRegistrant.register(with: registry)
      }

      if #available(iOS 10.0, *) {
        UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
      }

      GeneratedPluginRegistrant.register(with: self)
      
      let controller = window?.rootViewController as! FlutterViewController
      let api = ApiImplementation()
      SaveToGroupIdSwiftApiSetup.setUp(binaryMessenger: controller.binaryMessenger, api: api)
      
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  @available(iOS 12.0, *)
  override func userNotificationCenter(
      _ center: UNUserNotificationCenter,
      openSettingsFor notification: UNNotification?
  ) {
      let controller = window?.rootViewController as! FlutterViewController
      let channel = FlutterMethodChannel(
          name: "com.example.flutter_local_notifications_example/settings",
          binaryMessenger: controller.binaryMessenger)

      channel.invokeMethod("showNotificationSettings", arguments: nil)
  }
}
