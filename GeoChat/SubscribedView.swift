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
import CoreData

class SubscribedView: UIViewController, UITableViewDelegate, UITableViewDataSource, NewMessageSubscribedViewDelegate {
    
    func updateChats() {
        print("Chat Deleted")
        chats = TabBarController.subscribed
        GetChatFromDB()
        self.tableView.reloadData()
    }
    
    var chats:[NSDictionary] = []
    var chatsDB:[NSDictionary] = []
    var chatsOnline:[NSDictionary] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let DB = DBHandler()
    let DateHandler = DateFunctions()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //DB.deleteAllRecords(entity: "Subscribed")
        //deleteAllRecords(entity: "Subscribed")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //chats = TabBarController.subscribed
        GetChatFromDB()
        //GetChats()
        self.tableView.reloadData()
        if (!TabBarController.socket.isConnected) {
            TabBarController.socket.connect()
        }
        TabBarController.NewMessageSubscribedDelegate = self
        let JSONString = "{\"Type\": 0,\"Data\":{\"User\":{\"Username\":\"\(UserDefaults.standard.string(forKey: "Username")! )\",\"Longitude\":\"\(TabBarController.location?.coordinate.longitude ?? 0.0)\",\"Latitude\":\"\(TabBarController.location?.coordinate.latitude ?? 0.0)\",\"Radius\":\"\(Float(UserDefaults.standard.double(forKey: "radius")))\"}}}"
        TabBarController.socket.write(string: JSONString)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscribedCell", for: indexPath) as! SubscribedCell
        var title = ""
        if ((chats[indexPath.row].value(forKey: "chat_name") as! String).contains(",")) {
            let title_array = (chats[indexPath.row].value(forKey: "chat_name") as! String).split(separator: ",")
            let title_filtered = title_array.filter { String($0) != UserDefaults.standard.string(forKey: "Username") }
            title = String(title_filtered.joined(separator: ", "))
        } else {
            title = (chats[indexPath.row].value(forKey: "chat_name") as! String)
        }
        let image = (chats[indexPath.row].value(forKey: "Image") as! String)
        let created_date = DateHandler.UTCToLocal(date: String((chats[indexPath.row].value(forKey: "created_at") as! String).split(separator: ".")[0]))
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
            time_of_message = DateHandler.displayDate(date: chats[indexPath.row].value(forKey: "Time_Of_Message") as! String)
        } else {
            time_of_message = created_date
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
    
    func GetChats() {
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
                        self.chatsOnline = array
                    }else{
                        self.chatsOnline = []
                        print("Unsuccessful")
                    }
                    self.chats = self.chatsOnline
                    self.adjustDB()
                    self.tableView.reloadData()
                }
        }
    }
    
    func GetChatFromDB() {
        self.chatsDB = []
        self.chats = []
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Subscribed")
        //request.predicate = NSPredicate(format: "age = %@", "12")
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                let id = (data.value(forKey: "chat_id") as! String)
                let chat_name = data.value(forKey: "chat_name") as! String
                let created_at = data.value(forKey: "created_at") as! String
                let image = data.value(forKey: "image") as! String
                let type = data.value(forKey: "type") as! String
                var latest_message:String? = nil
                if (data.value(forKey: "latest_message") as? String != nil) {
                    latest_message = (data.value(forKey: "latest_message") as! String)
                }
                var sent_by:String? = nil
                if (data.value(forKey: "sent_by") as? String != nil){
                    sent_by = (data.value(forKey: "sent_by") as! String)
                }
                var time_of_message:String? = nil
                if (data.value(forKey: "time_of_message") as? String != nil){
                    time_of_message = data.value(forKey: "time_of_message") as? String
                }
                let arr:NSDictionary = ["chat_id":id,"chat_name":chat_name,"created_at":created_at,"Image":image,"Latest_Message":(latest_message ?? nil) as Any,"Sent_By":(sent_by ?? nil) as Any,"Time_Of_Message":(time_of_message ?? nil) as Any,"Private":type]
                
                chats.append(arr)
                chatsDB.append(arr)
                //self.FriendsDB.append(data.value(forKey: "username") as! String)
            }
        } catch {
            print("Failed")
        }
        chats = chats.sorted(by: { (dictOne, dictTwo) -> Bool in
            return self.DateHandler.getDateFormatted(dateString: String((dictOne.value(forKey: "Time_Of_Message") as! String).split(separator: ".")[0]), formatting: "yyyy'-'MM'-'dd'T'HH':'mm':'ss'") > self.DateHandler.getDateFormatted(dateString: String((dictTwo.value(forKey: "Time_Of_Message") as! String).split(separator: ".")[0]), formatting: "yyyy'-'MM'-'dd'T'HH':'mm':'ss'")
        })
        context.reset()
        self.tableView.reloadData()
        //context.reset()
        GetChats()
    }
    
    func adjustDB() {
        for chat in chatsOnline {
            if (chatsDB.contains(where: { (chatObject) -> Bool in
                if ((chatObject.value(forKey: "chat_id") as! String) == (chat.value(forKey: "chat_id") as! String)) {
                    return true
                } else {
                    return false
                }
            })) {
                print("Found ID")
                if (chatsDB.contains(where: { (chatObject) -> Bool in
                    if ((chatObject.value(forKey: "Time_Of_Message") as! String) != (chat.value(forKey: "Time_Of_Message") as! String)) {
                        return true
                    } else {
                        return false
                    }
                })) {
                    let time_of_message = chat.value(forKey: "Time_Of_Message") as! String
                    let latest_message = chat.value(forKey: "Latest_Message") as! String
                    let sent_by = chat.value(forKey: "Sent_By") as! String
                    let id = chat.value(forKey: "chat_id") as! String
                    let context = appDelegate.persistentContainer.viewContext
                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Subscribed")
                    request.predicate = NSPredicate(format: "chat_id = %@", id)
                    request.fetchLimit = 1
                    request.returnsObjectsAsFaults = false
                    
                    do {
                        let result = try context.fetch(request)
                        for data in result as! [NSManagedObject] {
                            data.setValue(time_of_message, forKey: "time_of_message")
                            data.setValue(latest_message, forKey: "latest_message")
                            data.setValue(sent_by, forKey: "sent_by")
                            do {
                                try context.save()
                                print("Updated Chat")
                            } catch {
                                print("Failed Updating")
                            }
                            context.reset()
                        }
                    } catch {
                        print("Failed")
                    }
                }
            } else {
                var title = ""
                if ((chat.value(forKey: "chat_name") as! String).contains(",")) {
                    let title_array = (chat.value(forKey: "chat_name") as! String).split(separator: ",")
                    let title_filtered = title_array.filter { String($0) != UserDefaults.standard.string(forKey: "Username") }
                    title = String(title_filtered.joined(separator: ", "))
                } else {
                    title = (chat.value(forKey: "chat_name") as! String)
                }
                let id = (chat.value(forKey: "chat_id") as! String)
                let image = (chat.value(forKey: "Image") as! String)
                let created_date = chat.value(forKey: "created_at") as! String
                let type = chat.value(forKey: "Private") as! String
                var latest_message:String? = nil
                var sent_by:String? = nil
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'"
                var date = dateFormatter.date(from: created_date)
                var time_of_message:String? = nil
                if (chat.value(forKey: "Latest_Message") as? String != nil) {
                    latest_message = (chat.value(forKey: "Latest_Message") as! String)
                }
                if (chat.value(forKey: "Sent_By") as? String != nil){
                    sent_by = (chat.value(forKey: "Sent_By") as! String)
                }
                if (chat.value(forKey: "Time_Of_Message") as? String != nil){
                    time_of_message = chat.value(forKey: "Time_Of_Message") as! String
                } else {
                    time_of_message = created_date
                }
                let context = appDelegate.persistentContainer.viewContext
                let entity = NSEntityDescription.entity(forEntityName: "Subscribed", in: context)
                let newChat = NSManagedObject(entity: entity!, insertInto: context)
                newChat.setValue(id, forKey: "chat_id")
                newChat.setValue(title, forKey: "chat_name")
                newChat.setValue(created_date, forKey: "created_at")
                newChat.setValue(image, forKey: "image")
                newChat.setValue(latest_message, forKey: "latest_message")
                newChat.setValue(sent_by, forKey: "sent_by")
                newChat.setValue(time_of_message, forKey: "time_of_message")
                newChat.setValue(type, forKey: "type")
                do {
                    try context.save()
                    print("Friend Added")
                } catch {
                    print("Failed saving")
                }
                context.reset()
            }
        }
        for chat in chatsDB {
            if (!chatsOnline.contains(where: { (chatObject) -> Bool in
                if ((chatObject.value(forKey: "chat_id") as! String) == (chat.value(forKey: "chat_id") as! String)) {
                    return true
                } else {
                    return false
                }
            })) {
                print(chatsDB)
                print("Delete Chat")
                let context = self.appDelegate.persistentContainer.viewContext
                let chatFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Subscribed")
                chatFetch.fetchLimit = 1
                chatFetch.predicate = NSPredicate(format: "chat_id = %@", (chat.value(forKey: "chat_id") as! String))
                if let result = try? context.fetch(chatFetch) {
                    for object in result as! [NSManagedObject] {
                        context.delete(object)
                        do {
                            try context.save()
                        } catch {
                            
                        }
                    }
                }
                context.reset()
            } else {
                print("Do Nothing")
            }
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
                self.chats = TabBarController.subscribed
                self.GetChatFromDB()
                self.tableView.reloadData()
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
                        if (jsonData.value(forKey: "message") as! String == "Chat Deleted"){
                            let JSONString = "{\"Type\": 7,\"Data\":{\"Users\":\"\(chatTitle)\"}}"
                            TabBarController.socket.write(string: JSONString)
                        }
                        let context = self.appDelegate.persistentContainer.viewContext
                        let chatFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Subscribed")
                        chatFetch.fetchLimit = 1
                        chatFetch.predicate = NSPredicate(format: "chat_id = %@", (chatID))
                        if let result = try? context.fetch(chatFetch) {
                            for object in result as! [NSManagedObject] {
                                context.delete(object)
                                do {
                                    try context.save()
                                } catch {
                                    
                                }
                            }
                        }
                        context.reset()
                    }else{
                        print("Unsuccessful")
                    }
                }
                self.GetChatFromDB()
        }
    }
    
    func updateDB(chat:NSDictionary) {
        
    }
    
    func deleteAllRecords(entity:String) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
}
