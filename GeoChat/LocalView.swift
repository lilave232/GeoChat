//
//  SecondViewController.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-01-26.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation


class LocalView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var local_chats:[NSDictionary] = []
    @IBOutlet weak var tableView: UITableView!
    var controller: TabBarController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controller = self.tabBarController as? TabBarController
        local_chats = []
        local_chats = controller!.local_chats
        tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("LOCAL VIEW SHOWING")
        if (TabBarController.location != nil) {
            GetChats(location: TabBarController.location!.coordinate)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return local_chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocalChatCell", for: indexPath) as! ChatNameCell
        //let coord = CLLocation(latitude: local_chats[indexPath.row].value(forKey: "Latitude") as! Double, longitude: local_chats[indexPath.row].value(forKey: "Longitude") as! Double).coordinate
        let width = Double(30)
        let height = 1.86 * width
        let id = (local_chats[indexPath.row].value(forKey: "chat_id") as! String)
        let image = (local_chats[indexPath.row].value(forKey: "Image") as! String)
        let title = (local_chats[indexPath.row].value(forKey: "chat_name") as! String)
        let created_date = UTCToLocal(date: String((local_chats[indexPath.row].value(forKey: "created_at") as! String).split(separator: ".")[0]))
        var latest_message = "No Messages"
        var sent_by = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'"
        var date = dateFormatter.date(from: created_date)
        var time_of_message = ""
        if (local_chats[indexPath.row].value(forKey: "Latest_Message") as? String != nil) {
            latest_message = (local_chats[indexPath.row].value(forKey: "Latest_Message") as! String)
        }
        if (local_chats[indexPath.row].value(forKey: "Sent_By") as? String != nil){
            sent_by = (local_chats[indexPath.row].value(forKey: "Sent_By") as! String)
        }
        if (local_chats[indexPath.row].value(forKey: "Time_Of_Message") as? String != nil){
            time_of_message = UTCToLocal(date: String((local_chats[indexPath.row].value(forKey: "Time_Of_Message") as! String).split(separator: ".")[0]))
            date = dateFormatter.date(from: time_of_message)
        } else {
            time_of_message = created_date
        }
        let diff = Calendar.current.dateComponents([.day], from: Date(), to: date!)
        if diff.day == 0 {
            time_of_message = DateToTime(date: time_of_message)
        } else {
            time_of_message = String(time_of_message.split(separator: "T")[0])
        }
        //let pinImage = UIImage(named:image)
        cell.chatName.text = title
        cell.chatText.text = latest_message
        cell.chatTime.text = time_of_message
        cell.iconImage.image = UIImage(named: image)
        //getLatestMessage(chatID: id)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = mainStoryboard.instantiateViewController(withIdentifier: "Chat") as! ChatView
        let title = (local_chats[indexPath.row].value(forKey: "chat_name") as! String)
        let id = (local_chats[indexPath.row].value(forKey: "chat_id") as! String)
        vc.chat_title = title
        vc.chat_id = id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        var return_arr:[UITableViewRowAction] = []
        if ((self.local_chats[editActionsForRowAt.row].value(forKey: "username")  as! String) == UserDefaults.standard.string(forKey: "Username")){
            let Delete = UITableViewRowAction(style: .normal, title: "Delete Chat") { action, index in
                let id = (self.local_chats[editActionsForRowAt.row].value(forKey: "chat_id") as! String)
                self.local_chats.remove(at: editActionsForRowAt.row)
                self.tableView.reloadData()
                self.DeleteChat(chatID: id)
            }
            Delete.backgroundColor = .red
            return_arr.append(Delete)
        }
        if (!TabBarController.subscribed.contains {$0.value(forKey: "chatID") as! String == (local_chats[editActionsForRowAt.row].value(forKey: "chat_id") as! String)})
        {
            let Subscribe = UITableViewRowAction(style: .normal, title: "Subscribe") { action, index in
                let id = (self.local_chats[editActionsForRowAt.row].value(forKey: "chat_id") as! String)
                self.Subscribe(chatID: id)
            }
            Subscribe.backgroundColor = .blue
            return_arr.append(Subscribe)
        } else {
            let Unsubscribe = UITableViewRowAction(style: .normal, title: "Unsubscribe") { action, index in
                let id = (self.local_chats[editActionsForRowAt.row].value(forKey: "chat_id") as! String)
                self.Unsubscribe(chatID: id)
            }
            Unsubscribe.backgroundColor = .blue
            return_arr.append(Unsubscribe)
        }
        return return_arr
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //convert UTC to Local
    func UTCToLocal(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'"
        
        return dateFormatter.string(from: dt!)
    }
    
    func DateToTime(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'"
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "hh:mm a"
        
        return dateFormatter.string(from: dt!)
    }
    
    
    func GetChats(location: CLLocationCoordinate2D) {
        self.controller!.local_chats = []
        let parameters: Parameters=[
            "Username":UserDefaults.standard.object(forKey: "Username")!,
            "Longitude":location.longitude,
            "Latitude":location.latitude,
            "Radius":UserDefaults.standard.double(forKey: "radius")
        ]
        let URL_USER_UPDATE_LOCATION = AppDelegate.URLConnection + "/GetMapChats"
        Alamofire.request(URL_USER_UPDATE_LOCATION, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        let array = jsonData.value(forKey: "chats") as! [NSDictionary]
                        self.controller!.local_chats = array
                        print("Checked Chats")
                        self.local_chats = self.controller!.local_chats
                    }else{
                        print("Unsuccessful")
                    }
                    self.tableView.reloadData()
                }
        }
    }
    func Subscribe(chatID: String) {
        self.controller!.local_chats = []
        let parameters: Parameters=[
            "member":UserDefaults.standard.object(forKey: "Username")!,
            "chatID":chatID,
        ]
        let URL_USER_SUBSCRIBE = AppDelegate.URLConnection + "/Subscribe"
        Alamofire.request(URL_USER_SUBSCRIBE, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        print("Subscribed")
                        self.GetChats(location: TabBarController.location!.coordinate)
                        self.GetSubscribed()
                    }else{
                        print("Unsuccessful")
                    }
                }
                self.tableView.reloadData()
        }
    }
    func DeleteChat(chatID: String) {
        let parameters: Parameters=[
            "chatID":chatID,
        ]
        let URL_USER_DELETE_CHAT = AppDelegate.URLConnection + "/DeleteChat"
        Alamofire.request(URL_USER_DELETE_CHAT, method: .post, parameters: parameters).responseJSON
            {
                response in
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        print("Deleted")
                        self.GetChats(location: TabBarController.location!.coordinate)
                        self.GetSubscribed()
                    }else{
                        print("Deleted")
                    }
                }
                //self.tableView.reloadData()
        }
    }
    func Unsubscribe(chatID: String) {
        let parameters: Parameters=[
            "member":UserDefaults.standard.object(forKey: "Username")!,
            "chatID":chatID,
        ]
        let URL_USER_UNSUBSCRIBE = AppDelegate.URLConnection + "/Unsubscribe"
        Alamofire.request(URL_USER_UNSUBSCRIBE, method: .post, parameters: parameters).responseJSON
        {
            response in
            if let result = response.result.value {
                let jsonData = result as! NSDictionary
                if(!(jsonData.value(forKey: "error") as! Bool)){
                    print("Unsubscribed")
                    self.GetChats(location: TabBarController.location!.coordinate)
                    self.GetSubscribed()
                }else{
                    print("Unsuccessful")
                }
            }
            self.tableView.reloadData()
        }
    }
    func GetSubscribed() {
        TabBarController.subscribed = []
        let parameters: Parameters=[
            "Username":UserDefaults.standard.object(forKey: "Username")!,
        ]
        let URL_USER_GET_SUBSCRIBED = AppDelegate.URLConnection + "/GetSubscribedChats"
        Alamofire.request(URL_USER_GET_SUBSCRIBED, method: .post, parameters: parameters).responseJSON
            {
                response in
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        let array = jsonData.value(forKey: "chats") as! [NSDictionary]
                        print("Checked Chats")
                        TabBarController.subscribed = array
                        self.tableView.reloadData()
                    }else{
                        print("Unsuccessful")
                    }
                }
        }
    }
}

