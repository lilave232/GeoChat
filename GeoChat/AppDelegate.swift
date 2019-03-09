//
//  AppDelegate.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-01-26.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import UIKit
import GoogleMaps
import UserNotifications
import Alamofire
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static let URLConnection = Constants.url
    let googleApiKey = Constants.googleApiKey

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(googleApiKey)
        registerForPushNotifications()
        UIApplication.shared.registerForRemoteNotifications()
        application.applicationIconBadgeNumber = 0
        if let payload = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? NSDictionary, let identifier = payload["storyboardID"] as? String, let tab = payload["viewInTabBar"] as? Int {
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
            
            tabBarController.selectedIndex = tab
            if (identifier == "Chat") {
                let desiredVC = storyboard.instantiateViewController(withIdentifier: identifier) as! ChatView
                if tabBarController.selectedIndex == tab{
                    desiredVC.chat_id = payload["chatID"] as! String
                    desiredVC.chat_title = payload["chatTitle"] as! String
                    // Option 1: If you want to present
                    tabBarController.selectedViewController?.show(desiredVC, sender: nil)
                    
                }
            }
            
            //self.window = UIWindow.init(frame: UIScreen.main.bounds)
            self.window?.rootViewController = tabBarController
            //self.window?.makeKeyAndVisible()
        }
        return true
    }
    
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) {
                [weak self] granted, error in
                
                print("Permission granted: \(granted)")
                guard granted else { return }
                self?.getNotificationSettings()
        }
    }
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
        ) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        if (UserDefaults.standard.object(forKey: "Username") != nil) {
            UpdateToken(Username: UserDefaults.standard.string(forKey: "Username"), Token: token)
        }
        print("Device Token: \(token)")
    }
    
    func UpdateToken(Username: String?, Token: String?) {
        let parameters: Parameters=[
            "Username":Username!,
            "Token":Token!,
        ]
        let URL_USER_UPDATE_TOKEN = AppDelegate.URLConnection + "/UpdateToken"
        Alamofire.request(URL_USER_UPDATE_TOKEN, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        print("Updated Token")
                    }else{
                        print("Token Could Not Be Updated")
                    }
                }
        }
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        if (TabBarController.socket.isConnected) {
            let JSONString = "{\"Type\": 4,\"Data\":{\"Chat\":{\"Username\":\"\(UserDefaults.standard.string(forKey: "Username")!)\"}}}"
            TabBarController.socket.write(string: JSONString)
            TabBarController.socket.disconnect(forceTimeout: 0)
            TabBarController.socket.delegate = nil
            TabBarController.mdelegate = nil
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if (TabBarController.socket.isConnected) {
            let JSONString = "{\"Type\": 4,\"Data\":{\"Chat\":{\"Username\":\"\(UserDefaults.standard.string(forKey: "Username")!)\"}}}"
            TabBarController.socket.write(string: JSONString)
            TabBarController.socket.disconnect(forceTimeout: 0)
            TabBarController.socket.delegate = nil
            TabBarController.mdelegate = nil
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if (!TabBarController.socket.isConnected && UserDefaults.standard.string(forKey: "Username") != nil) {
            TabBarController.socket.connect()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        if (TabBarController.socket.isConnected) {
            let JSONString = "{\"Type\": 4,\"Data\":{\"Chat\":{\"Username\":\"\(UserDefaults.standard.string(forKey: "Username")!)\"}}}"
            TabBarController.socket.write(string: JSONString)
            TabBarController.socket.disconnect(forceTimeout: 0)
            TabBarController.socket.delegate = nil
            TabBarController.mdelegate = nil
            self.saveContext()
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CoreData")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

