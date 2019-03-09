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
    func didDisconnect()
}
protocol NewMessageLocalViewDelegate: class {
    func updateChats()
    func didDisconnect()
}
protocol NewMessageSubscribedViewDelegate: class {
    func updateChats()
}
protocol MapsDelegate: class {
    func updateMap()
    func didDisconnect()
    func didConnect()
}

class TabBarController: UITabBarController, WebSocketDelegate {
    static var mdelegate: MessageReceivedDelegate?
    static var MapDelegate: MapsDelegate?
    static var NewMessageLocalDelegate: NewMessageLocalViewDelegate?
    static var NewMessageSubscribedDelegate: NewMessageSubscribedViewDelegate?
    static var socket = WebSocket(url: URL(string: AppDelegate.URLConnection + "/")!, protocols: ["echo-protocol"])
    weak var messageDelegate: MessageReceivedDelegate?
    static var location: CLLocation? = nil
    var window = UIApplication.shared.keyWindow!
    var v2:UIView? = nil
    var label:UILabel? = nil
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("Connected")
        if (label != nil) {
            window.isHidden = true
            label = nil
        }
        TabBarController.mdelegate?.connectChat()
        TabBarController.MapDelegate?.didConnect()
        if (TabBarController.location != nil)
        {
            print(TabBarController.location!)
            let JSONString = "{\"Type\": 0,\"Data\":{\"User\":{\"Username\":\"\(UserDefaults.standard.string(forKey: "Username")! )\",\"Longitude\":\"\(TabBarController.location?.coordinate.longitude ?? 0.0)\",\"Latitude\":\"\(TabBarController.location?.coordinate.latitude ?? 0.0)\",\"Radius\":\"\(Float(UserDefaults.standard.double(forKey: "radius")))\"}}}"
            TabBarController.socket.write(string: JSONString)
        }
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        if CheckInternet.Connection() {
            TabBarController.NewMessageLocalDelegate?.didDisconnect()
            TabBarController.MapDelegate?.didDisconnect()
            TabBarController.mdelegate?.didDisconnect()
            showNoConnection(Message: "Our Servers Are Down")
        } else {
            TabBarController.NewMessageLocalDelegate?.didDisconnect()
            TabBarController.MapDelegate?.didDisconnect()
            TabBarController.mdelegate?.didDisconnect()
            showNoConnection(Message: "You Are Not Connected To Internet")
        }
        TabBarController.mdelegate = nil
        /*
        while !TabBarController.socket.isConnected {
            TabBarController.socket.connect()
        }*/
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
    
    
    static var local_chats: [NSDictionary]! = []
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
    func Alert (Title:String,Message: String) {
        let alert = UIAlertController(title: Title,message: Message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Set Delegate To Server 2")
        TabBarController.socket.delegate = self
        TabBarController.socket.connect()
    }
    
    func showNoConnection(Message:String) {
        //UIApplication.shared.statusBarFrame.height
        v2 = UIView(frame: CGRect(x: 0, y: 0, width: window.frame.width, height: UIApplication.shared.statusBarFrame.height))
        v2!.backgroundColor = UIColor.red
        let bannerWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: window.frame.width, height: UIApplication.shared.statusBarFrame.height))
        bannerWindow.layer.masksToBounds = true
        bannerWindow.backgroundColor = .clear
        bannerWindow.rootViewController = self
        bannerWindow.windowLevel = UIWindow.Level.statusBar
        bannerWindow.addSubview(v2!)
        self.window = bannerWindow
        window.isHidden = false
        label = UILabel(frame: CGRect(x: 0, y:0,width: window.frame.width, height: UIApplication.shared.statusBarFrame.height))
        label!.font = UIFont(name: "System", size: 2)
        label!.textAlignment = .center
        label!.textColor = .white
        label!.text = Message
        v2!.addSubview(label!)
        //self.Alert(Title:"Servers Are Down", Message: "Cannot Add Friends")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
}
