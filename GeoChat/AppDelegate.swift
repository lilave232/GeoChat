//
//  AppDelegate.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-01-26.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    static let URLConnection = "http://192.168.0.35"
    let googleApiKey = "AIzaSyCe1BfQ2Bdcb50fExIsxnGXgH9CzbbJ3nk"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(googleApiKey)
        return true
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

