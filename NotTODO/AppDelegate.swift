import UIKit
import RealmSwift
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("許可されました！")
            } else {
                print("許可されませんでした！")
            }
        }

        var config = Realm.Configuration()
        if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.Usui.Crayon.NotTODO") {
            config.fileURL = appGroupURL.appendingPathComponent("db.realm")
        } else {
            // エラーハンドリング
            print("Error: アプリケーショングループのURLを取得できません")
            return false
        }

        config.schemaVersion = 3 // スキーマバージョンを更新
        config.migrationBlock = { migration, oldSchemaVersion in
            if oldSchemaVersion < 3 {
                // 新しいプロパティ 'repeatUntil' を追加
                migration.enumerateObjects(ofType: NotTODO.className()) { oldObject, newObject in
                    newObject!["repeatUntil"] = Date()
                }
            }
        }

        do {
            Realm.Configuration.defaultConfiguration = config

            // Realmのインスタンスを取得してマイグレーションを適用
            let _ = try Realm()
        } catch {
            // エラーハンドリング
            print("Error: Realmの設定中にエラーが発生しました - \(error.localizedDescription)")
            return false
        }

        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}
