import Flutter
import UIKit
import YandexMapsMobile
import UserNotifications
import JivoSDK

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        // Инициализация Yandex Maps API
        YMKMapKit.setLocale("ru_RU") // Ваш предпочтительный язык. Необязательно, по умолчанию язык системы
        YMKMapKit.setApiKey("39a54941-0819-4ad3-bec0-ea83ea36e655") // Ваш сгенерированный API ключ
        
        GeneratedPluginRegistrant.register(with: self)

        // Инициализация JivoSDK
        Jivo.notifications.handleLaunch(options: launchOptions)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
   override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Jivo.notifications.setPushToken(data: deviceToken)
    }
    
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let result = Jivo.notifications.didReceiveRemoteNotification(userInfo: userInfo) {
            completionHandler(result)
        }
        else {
            completionHandler(.noData)
        }
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let options = Jivo.notifications.willPresent(notification: notification, preferableOptions: [.alert, .sound, .badge]) {
            completionHandler(options)
        }
        else {
            completionHandler([])
        }
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Jivo.notifications.didReceive(response: response)
        completionHandler()
    }
    
    // Обработка Universal Links
    override func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if let url = userActivity.webpageURL {
                print("Received Universal Link: \(url)")
                // Flutter app_links plugin автоматически обработает этот URL
            }
        }
        return super.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
    
    // Обработка URL схем (для обратной совместимости)
    override func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("Received URL: \(url)")
        // Flutter app_links plugin автоматически обработает этот URL
        return super.application(app, open: url, options: options)
    }
}
