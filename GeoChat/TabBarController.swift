//
//  TabBarController.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-02-08.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit
import Starscream
import CoreLocation

protocol MessageReceivedDelegate: class {
    func updateMessages(_ messages: String?)
    func connectChat()
}

class TabBarController: UITabBarController, WebSocketDelegate {
    static var mdelegate: MessageReceivedDelegate?
    static var socket = WebSocket(url: URL(string: AppDelegate.URLConnection + "/")!, protocols: ["echo-protocol"])
    weak var messageDelegate: MessageReceivedDelegate?
    static var location: CLLocation? = nil
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("Connected")
        let JSONString = "{\"Type\": 0,\"Data\":{\"User\":{\"Username\":\"\(UserDefaults.standard.string(forKey: "Username")! ?? "")\"}}}"
        TabBarController.socket.write(string: JSONString)
        TabBarController.mdelegate?.connectChat()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        TabBarController.mdelegate = nil
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        TabBarController.mdelegate?.updateMessages(text)
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
    
    var local_chats: [NSDictionary]! = []
    static var subscribed: [NSDictionary]! = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(viewDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func viewDidBecomeActive(){
        TabBarController.socket.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TabBarController.socket.delegate = self
        if (!TabBarController.socket.isConnected) {
            TabBarController.socket.connect()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
}
