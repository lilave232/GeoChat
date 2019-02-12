//
//  ChatView.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-02-09.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit
import Starscream
import Alamofire

class ChatView: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageReceivedDelegate {
    
    func connectChat() {
        print("Connecting to Chat")
        let JSONString = "{\"Type\": 2,\"Data\":{\"Chat\":{\"chatID\":\"\(chat_id ?? "")\", \"Username\":\"\(UserDefaults.standard.string(forKey: "Username")!)\"}}}"
        TabBarController.socket.write(string: JSONString)
    }
    
    
    
    func updateMessages(_ messages: String?) {
        let messageJSON = stringToJSON(message: messages!)
        print(messageJSON)
        message.insert((messageJSON["message"] as! String), at: 0)
        from.insert((messageJSON["userFrom"] as! String), at:0)
        color.insert((messageJSON["color"] as? NSString)!.integerValue, at:0)
        tableView.reloadData()
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var chat_title = ""
    var chat_id = ""
    var chat:[String] = []
    var message:[String] = []
    var color:[Int] = []
    var from:[String] = []
    var date:[String] = []
    var initY = CGFloat(0)
    let keyBoardSize = CGRect(x: 0, y: 0, width: 0, height: 0)
    var frombubbleLeading = CGFloat(0)
    var frombubbleTrailing = CGFloat(0)
    var frommessageLeading = CGFloat(0)
    var frommessageTrailing = CGFloat(0)
    
    @IBOutlet weak var messageTextField: UITextView!
    
    
    @IBOutlet weak var chat_title_bar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.hideKeyboardWhenTappedAround()
        chat_title_bar.title = chat_title
        //Rotate tableview to display upside down so elements load upward instead of downward
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi));
        //Set rowHeight to automatice
        tableView.rowHeight = UITableView.automaticDimension
        // set estimated height of row to trigger change when not eqaul estimated
        tableView.estimatedRowHeight = 140
        NotificationCenter.default.addObserver(self, selector: #selector(viewDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func viewDidBecomeActive(){
        TabBarController.mdelegate = self
        print("Will Enter Foreground")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        TabBarController.mdelegate = self
        let JSONString = "{\"Type\": 2,\"Data\":{\"Chat\":{\"chatID\":\"\(chat_id ?? "")\", \"Username\":\"\(UserDefaults.standard.string(forKey: "Username")!)\"}}}"
        TabBarController.socket.write(string: JSONString)
        GetChat(chatID: chat_id)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let JSONString = "{\"Type\": 3,\"Data\":{\"Chat\":{\"chatID\":\"\(chat_id ?? "")\", \"Username\":\"\(UserDefaults.standard.string(forKey: "Username")!)\"}}}"
        TabBarController.socket.write(string: JSONString)
    }
    
    
    @IBAction func sendMessageAction(_ sender: Any) {
        var color = 0xFFDC00
        if (UserDefaults.standard.object(forKey: "MessageColor") != nil) {
            color = UserDefaults.standard.integer(forKey: "MessageColor")
        }
        let JSONString = "{\"Type\": 1,\"Data\":{\"Message\":{\"message\":\"\(messageTextField.text ?? "")\", \"chatID\":\"\(chat_id )\", \"userFrom\":\"\(UserDefaults.standard.string(forKey: "Username")!)\",\"color\":\"\(color)\"}}}"
        TabBarController.socket.write(string: JSONString)
        messageTextField.text = ""
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return message.count
    }
    //On click UITableView row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Print row number of item pressed
        print(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //Access message cell class
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell")! as! ChatMessageCell
        //Set messageLabel as the message
        cell.messageLabel.sizeToFit()
        cell.messageLabel.text = message[indexPath.row]
        //Set so that cell doesn't display color when touched
        cell.selectionStyle = .none
        //Rotate cells to match rotation of tableView
        cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi));
        //Set cell defauly positions if they weren't already set
        if (frombubbleTrailing == CGFloat(0)) {
            //Set default trailing bubble distance which is message not sent by User
            frombubbleTrailing = cell.chatBubbleTrailing.constant
            //Set default leading bubble distance which is message not sent by User
            frombubbleLeading = cell.chatBubbleLeading.constant
            //Set default message trailing bubble distance when not sent by User
            frommessageTrailing = cell.messageTrailing.constant
            //Set default message leading bubble distance when not sent by User
            frommessageLeading = cell.messageLeading.constant
        }
        if (from[indexPath.row] == UserDefaults.standard.string(forKey: "Username"))
        {
            //If message sent by user flip trailing and leading distances to mirror bubbles
            cell.chatBubbleTrailing.constant = frombubbleLeading
            cell.chatBubbleLeading.constant = frombubbleTrailing
            cell.messageTrailing.constant = frommessageLeading
            cell.messageLeading.constant = frommessageTrailing
            cell.messageFrom.text = ""
            //change color of text to Black for User message
            cell.messageLabel.textColor = UIColor.black
            //change color of chatBubble to Orange for User message
            cell.chatBubble.backgroundColor = uiColorFromHex(rgbValue: color[indexPath.row]) //Orange
        } else {
            //If message sent not sent by user flip trailing and leading distances back to normal
            cell.chatBubbleTrailing.constant = frombubbleTrailing
            cell.chatBubbleLeading.constant = frombubbleLeading
            cell.messageTrailing.constant = frommessageTrailing
            cell.messageLeading.constant = frommessageLeading
            //change color of text to white for message not sent by user
            cell.messageLabel.textColor = UIColor.white
            cell.messageFrom.text = from[indexPath.row]
            //change color of chatBubble to Pink for non-User message
            cell.chatBubble.backgroundColor = uiColorFromHex(rgbValue: color[indexPath.row]) //Pink
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (keyboardSize.height*1)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
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
    func uiColorFromHex(rgbValue: Int) -> UIColor {
        
        let red =   CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(rgbValue & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func GetChat(chatID: String?) {
        let parameters: Parameters=[
            "chatID":chat_id,
        ]
        let URL_USER_GET_CHAT = AppDelegate.URLConnection + ":8081/GetChat"
        Alamofire.request(URL_USER_GET_CHAT, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        let array = jsonData.value(forKey: "chats") as! [NSDictionary]
                        array.forEach(
                        {(dictionary) in
                            let message = dictionary.value(forKey: "message") as? String
                            let from = dictionary.value(forKey: "userFrom") as? String
                            let color = dictionary.value(forKey: "color") as? Int
                            self.message.insert(message!, at: 0)
                            self.from.insert(from!, at:0)
                            self.color.insert(color!, at:0)
                        })
                        self.tableView.reloadData()
                    }else{
                        print("Unsuccessful")
                    }
                }
        }
    }
}
