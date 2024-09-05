import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      GeneratedPluginRegistrant.register(with: self)
      
      let controller = window?.rootViewController as! FlutterViewController
      let api = ApiImplementation()
      SaveToGroupIdSwiftApiSetup.setUp(binaryMessenger: controller.binaryMessenger, api: api)
      
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
