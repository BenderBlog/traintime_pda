import UIKit
import Flutter
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    /// 启动原生通知代理和 Apple Watch 通信，然后继续 Flutter 初始化。
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        configureNotificationCenter()
        activateWatchConnectivity()
        return super.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
    }

    /// Flutter 隐式引擎创建后注册插件和所有 Pigeon Host API。
    func didInitializeImplicitFlutterEngine(
        _ engineBridge: FlutterImplicitEngineBridge
    ) {
        configureBackgroundPluginRegistrant()
        registerGeneratedPlugins(with: engineBridge)
        registerHostAPIs(with: engineBridge)
    }

    /// 让前台通知和本地通知插件都使用当前 AppDelegate。
    private func configureNotificationCenter() {
        UNUserNotificationCenter.current().delegate =
            self as UNUserNotificationCenterDelegate
    }

    /// 尽早激活 WCSession，使 Flutter 首次生成课表时可以立即发布。
    private func activateWatchConnectivity() {
        PhoneWatchConnectivityManager.shared.activate()
    }

    /// 后台通知 isolate 也必须注册 Flutter 插件。
    private func configureBackgroundPluginRegistrant() {
        FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
            GeneratedPluginRegistrant.register(with: registry)
        }
    }

    /// 注册 Flutter 自动生成的插件。
    private func registerGeneratedPlugins(
        with engineBridge: FlutterImplicitEngineBridge
    ) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }

    /// 注册文件共享与 Apple Watch 同步两个原生 Host API。
    private func registerHostAPIs(
        with engineBridge: FlutterImplicitEngineBridge
    ) {
        let messenger = engineBridge.applicationRegistrar.messenger()
        let api = ApiImplementation()
        SaveToGroupIdSwiftApiSetup.setUp(
            binaryMessenger: messenger,
            api: api
        )
        WatchSyncSwiftApiSetup.setUp(
            binaryMessenger: messenger,
            api: WatchSyncApiImplementation()
        )
    }

    /// App 在前台时以横幅和通知中心列表展示课程提醒。
    override func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .badge, .sound])
    }
}
