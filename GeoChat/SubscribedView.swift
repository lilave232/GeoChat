//
//  SubscribedView.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-02-14.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class SubscribedView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var chats:[NSDictionary] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        chats = TabBarController.subscribed
        GetChats()
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscribedCell", for: indexPath) as! SubscribedCell
        //let coord = CLLocation(latitude: local_chats[indexPath.row].value(forKey: "Latitude") as! Double, longitude: local_chats[indexPath.row].value(forKey: "Longitude") as! Double).coordinate
        //let width = Double(30)
        //let height = 1.86 * width
        //let id = (chats[indexPath.row].value(forKey: "chat_id") as! String)
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        var title = ""
        if ((chats[indexPath.row].value(forKey: "chat_name") as! String).contains(",")) {
            let title_array = (chats[indexPath.row].value(forKey: "chat_name") as! String).split(separator: ",")
            let title_filtered = title_array.filter { String($0) != UserDefaults.standard.string(forKey: "Username") }
            title = String(title_filtered.joined(separator: ", "))
        } else {
            title = (chats[indexPath.row].value(forKey: "chat_name") as! String)
        }
        let image = (chats[indexPath.row].value(forKey: "Image") as! String)
        let created_date = UTCToLocal(date: String((chats[indexPath.row].value(forKey: "created_at") as! String).split(separator: ".")[0]))
        var latest_message = "No Messages"
        var sent_by = ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'"
        var date = dateFormatter.date(from: created_date)
        var time_of_message = ""
        if (chats[indexPath.row].value(forKey: "Latest_Message") as? String != nil) {
            latest_message = (chats[indexPath.row].value(forKey: "Latest_Message") as! String)
        }
        if (chats[indexPath.row].value(forKey: "Sent_By") as? String != nil){
            sent_by = (chats[indexPath.row].value(forKey: "Sent_By") as! String)
        }
        if (chats[indexPath.row].value(forKey: "Time_Of_Message") as? String != nil){
            time_of_message = UTCToLocal(date: String((chats[indexPath.row].value(forKey: "Time_Of_Message") as! String).split(separator: ".")[0]))
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
        let id = (chats[indexPath.row].value(forKey: "chat_id") as! String)
        let type = (chats[indexPath.row].value(forKey: "Private") as! String)
        vc.chat_title = chats[indexPath.row].value(forKey: "chat_name") as! String
        vc.chat_id = id
        vc.chat_type = type
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        let UnSubscribe = UITableViewRowAction(style: .normal, title: "Unsubscribe") { action, index in
            let id = (self.chats[editActionsForRowAt.row].value(forKey: "chat_id") as! String)
            let type = (self.chats[editActionsForRowAt.row].value(forKey: "Private") as! String)
            var title = ""
            if ((self.chats[editActionsForRowAt.row].value(forKey: "chat_name") as! String).contains(",")) {
                let title_array = (self.chats[editActionsForRowAt.row].value(forKey: "chat_name") as! String).split(separator: ",")
                let title_filtered = title_array.filter { String($0) != UserDefaults.standard.string(forKey: "Username") }
                title = String(title_filtered.joined(separator: ","))
            } else {
                title = (self.chats[editActionsForRowAt.row].value(forKey: "chat_name") as! String)
            }
            if (type == "Direct Message") {
                self.UnsubscribePrivate(chatID: id, chatTitle: title)
            } else {
                self.Unsubscribe(chatID: id)
            }
            self.chats.remove(at: editActionsForRowAt.row)
            self.tableView.reloadData()
        }
        let type = (self.chats[editActionsForRowAt.row].value(forKey: "Private") as! String)
        if (type == "Direct Message") {
            UnSubscribe.title = "Leave Chat"
            UnSubscribe.backgroundColor = .red
        } else {
            UnSubscribe.backgroundColor = .blue
        }
        
        return [UnSubscribe]
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
    
    func GetChats() {
        TabBarController.subscribed = []
        let parameters: Parameters=[
            "Username":UserDefaults.standard.object(forKey: "Username")!,
        ]
        let URL_USER_GET_SUBSCRIBED = AppDelegate.URLConnection + "/GetSubscribedChats"
        Alamofire.request(URL_USER_GET_SUBSCRIBED, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        let array = jsonData.value(forKey: "chats") as! [NSDictionary]
                        //print("Checked Chats")
                        TabBarController.subscribed = array
                    }else{
                        print("Unsuccessful")
                    }
                    self.tableView.reloadData()
                }
                self.chats = TabBarController.subscribed
                self.tableView.reloadData()
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
                        self.GetChats()
                    }else{
                        print("Unsuccessful")
                    }
                }
        }
    }
    ///UnsubscribePrivate
    func UnsubscribePrivate(chatID: String, chatTitle:String) {
        let parameters: Parameters=[
            "member":UserDefaults.standard.object(forKey: "Username")!,
            "chatID":chatID,
            "chatTitle":chatTitle,
        ]
        let URL_USER_UNSUBSCRIBE = AppDelegate.URLConnection + "/UnsubscribePrivate"
        Alamofire.request(URL_USER_UNSUBSCRIBE, method: .post, parameters: parameters).responseJSON
            {
                response in
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        print("Unsubscribed")
                        self.GetChats()
                    }else{
                        print("Unsuccessful")
                    }
                }
        }
    }
}
