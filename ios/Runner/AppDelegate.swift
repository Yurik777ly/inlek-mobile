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
        // Инициализация Yandex Maps API
        YMKMapKit.setLocale("ru_RU") // Ваш предпочтительный язык. Необязательно, по умолчанию язык системы
        YMKMapKit.setApiKey("39a54941-0819-4ad3-bec0-ea83ea36e655") // Ваш сгенерированный API ключ
        
        // Инициализация JivoSDK
        Jivo.notifications.handleLaunch(options: launchOptions)
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // Обработка регистрации устройства для получения пуш-уведомлений
    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Jivo.notifications.setPushToken(data: deviceToken)
    }
    
    // Обработка ошибки регистрации устройства для получения пуш-уведомлений
    override func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Jivo.notifications.setPushToken(data: nil)
    }
    
    // Обработка полученного пуш-уведомления
    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let result = Jivo.notifications.didReceiveRemoteNotification(userInfo: userInfo) {
            completionHandler(result)
        }
        else {
            completionHandler(.noData)
        }
    }
    
    // Обработка уведомлений, которые должны быть показаны, когда приложение активно
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let options = Jivo.notifications.willPresent(notification: notification, preferableOptions: .banner) {
            completionHandler(options)
        }
        else {
            completionHandler([])
        }
    }
    
    // Обработка нажатия на уведомление
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Jivo.notifications.didReceive(response: response)
        completionHandler()
    }
}
