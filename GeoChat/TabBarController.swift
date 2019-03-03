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
protocol NewMessageLocalViewDelegate: class {
    func updateChats()
}
protocol NewMessageSubscribedViewDelegate: class {
    func updateChats()
}
protocol MapsDelegate: class {
    func updateMap()
}

class TabBarController: UITabBarController, WebSocketDelegate {
    static var mdelegate: MessageReceivedDelegate?
    static var MapDelegate: MapsDelegate?
    static var NewMessageLocalDelegate: NewMessageLocalViewDelegate?
    static var NewMessageSubscribedDelegate: NewMessageSubscribedViewDelegate?
    static var socket = WebSocket(url: URL(string: AppDelegate.URLConnection + "/")!, protocols: ["echo-protocol"])
    weak var messageDelegate: MessageReceivedDelegate?
    static var location: CLLocation? = nil
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("Connected")
        TabBarController.mdelegate?.connectChat()
        if (TabBarController.location != nil)
        {
            print(TabBarController.location!)
            let JSONString = "{\"Type\": 0,\"Data\":{\"User\":{\"Username\":\"\(UserDefaults.standard.string(forKey: "Username")! )\",\"Longitude\":\"\(TabBarController.location?.coordinate.longitude ?? 0.0)\",\"Latitude\":\"\(TabBarController.location?.coordinate.latitude ?? 0.0)\",\"Radius\":\"\(Float(UserDefaults.standard.double(forKey: "radius")))\"}}}"
            TabBarController.socket.write(string: JSONString)
        }
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        TabBarController.mdelegate = nil
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        let message = stringToJSON(message: text)
        print(message)
        if (message["type"] as! Int == 0)
        {
            TabBarController.mdelegate?.updateMessages(text)
        }
        if (message["type"] as! Int == 1)
        {
            TabBarController.MapDelegate?.updateMap()
        }
        if (message["type"] as! Int == 2)
        {
            print("Update Chats")
            TabBarController.NewMessageLocalDelegate?.updateChats()
            TabBarController.NewMessageSubscribedDelegate?.updateChats()
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        
    }
    
    func stringToJSON(message: String) -> [String:AnyObject] {
        var jsonData:[String:AnyObject]? = nil
        do{
            if let json = message.data(using: String.Encoding.utf8){
                jsonData = try JSONSerialization.jsonObject(with: json, options: .allowFragments) as? [String:AnyObject]
            }
        }catch {
            print(error.localizedDescription)
            jsonData = ["String":"Empty" as AnyObject]
        }
        return jsonData!
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
        print("Set Delegate To Server 1")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Set Delegate To Server 2")
        TabBarController.socket.delegate = self
        if (!TabBarController.socket.isConnected) {
            TabBarController.socket.connect()
        } else {
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
}
