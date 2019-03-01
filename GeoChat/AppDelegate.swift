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
        }
    }


}

