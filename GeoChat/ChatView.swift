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
        let JSONString = "{\"Type\": 2,\"Data\":{\"Chat\":{\"chatID\":\"\(chat_id)\", \"Username\":\"\(UserDefaults.standard.string(forKey: "Username")!)\", \"Longitude\":\"\(TabBarController.location?.coordinate.longitude ?? 0.0)\", \"Latitude\":\"\(TabBarController.location?.coordinate.latitude ?? 0.0)\", \"Radius\":\"\(UserDefaults.standard.string(forKey: "radius")!)\"}}}"
        TabBarController.socket.write(string: JSONString)
        sendButton.isEnabled = true
    }
    
    func didDisconnect() {
        sendButton.isEnabled = false
        self.Alert(Title:"Not Connected", Message: "Cannot Load Messages")
    }
    
    func updateMessages(_ messages: String?) {
        let messageJSON = stringToJSON(message: messages!)
        print(messageJSON)
        message.insert((messageJSON["message"] as! String), at: 0)
        from.insert((messageJSON["userFrom"] as! String), at:0)
        colorBack.insert((messageJSON["colorBack"] as? NSString)!.integerValue, at:0)
        colorFront.insert((messageJSON["colorFront"] as? NSString)!.integerValue, at:0)
        tableView.reloadData()
    }
    
    func showOutgoingMessage(width: CGFloat, height: CGFloat) {
        let bubbleImageSize = CGSize(width: width, height: height)
        
        let outgoingMessageView = UIImageView(frame:
            CGRect(x: view.frame.width - bubbleImageSize.width - 20,
                   y: view.frame.height - bubbleImageSize.height - 86,
                   width: bubbleImageSize.width,
                   height: bubbleImageSize.height))
        
        let bubbleImage = UIImage(named: "Chat Bubble")?
            .resizableImage(withCapInsets: UIEdgeInsets(top: 28, left: 28, bottom: 28, right: 28),
                            resizingMode: .stretch)
        
        outgoingMessageView.image = bubbleImage
        
        view.addSubview(outgoingMessageView)
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var chat_title = ""
    var chat_id = ""
    var chat_type = ""
    var chat:[String] = []
    var message:[String] = []
    var colorBack:[Int] = []
    var colorFront:[Int] = []
    var from:[String] = []
    var date:[String] = []
    var initY = CGFloat(0)
    let keyBoardSize = CGRect(x: 0, y: 0, width: 0, height: 0)
    var frombubbleLeading = CGFloat(0)
    var frombubbleTrailing = CGFloat(0)
    var frommessageLeading = CGFloat(0)
    var frommessageTrailing = CGFloat(0)
    
    
    @IBOutlet weak var sendButton: UIButton!
    
    
    
    @IBOutlet weak var messageTextField: UITextView!
    
    
    @IBOutlet weak var messageHolder: UIView!
    
    
    @IBOutlet weak var chat_title_bar: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
        self.hideKeyboardWhenTappedAround()
        var title = ""
        if (chat_title.contains(",")) {
            let title_array = chat_title.split(separator: ",")
            let title_filtered = title_array.filter { String($0) != UserDefaults.standard.string(forKey: "Username") }
            title = String(title_filtered.joined(separator: ", "))
        } else {
            title = chat_title
        }
        chat_title_bar.title = title
        //Rotate tableview to display upside down so elements load upward instead of downward
        tableView.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi));
        //Set rowHeight to automatice
        tableView.rowHeight = UITableView.automaticDimension
        // set estimated height of row to trigger change when not eqaul estimated
        tableView.estimatedRowHeight = 140
        NotificationCenter.default.addObserver(self, selector: #selector(viewDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        if !TabBarController.socket.isConnected {
            sendButton.isEnabled = false
            self.Alert(Title:"Not Connected", Message: "Cannot Load Messages")
        }
    }
    
    func Alert (Title:String,Message: String) {
        let alert = UIAlertController(title: Title,message: Message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func viewDidBecomeActive(){
        TabBarController.mdelegate = self
        print("Will Enter Foreground")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (!TabBarController.socket.isConnected) {
            TabBarController.socket.connect()
        }
        TabBarController.mdelegate = self
        let JSONString = "{\"Type\": 2,\"Data\":{\"Chat\":{\"chatID\":\"\(chat_id)\", \"Username\":\"\(UserDefaults.standard.string(forKey: "Username")!)\"}}}"
        TabBarController.socket.write(string: JSONString)
        GetChat(chatID: chat_id)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let JSONString = "{\"Type\": 3,\"Data\":{\"Chat\":{\"chatID\":\"\(chat_id)\", \"Username\":\"\(UserDefaults.standard.string(forKey: "Username")!)\"}}}"
        TabBarController.socket.write(string: JSONString)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            self.view.frame.origin.y = 0
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= (endFrame!.height*1)
            }
        }
    }
    
    @IBAction func sendMessageAction(_ sender: Any) {
        var colorBack = 0xFFDC00
        var colorFront = 0x000000
        if (UserDefaults.standard.object(forKey: "ColorBack") != nil) {
            colorBack = UserDefaults.standard.integer(forKey: "ColorBack")
        }
        if (UserDefaults.standard.object(forKey: "ColorFront") != nil) {
            colorFront = UserDefaults.standard.integer(forKey: "ColorFront")
        }
        if (chat_type != "Direct Message")
        {
            let JSONString = "{\"Type\": 1,\"Data\":{\"Message\":{\"message\":\"\(messageTextField.text ?? "")\", \"chatID\":\"\(chat_id )\", \"userFrom\":\"\(UserDefaults.standard.string(forKey: "Username")!)\",\"colorBack\":\"\(colorBack)\",\"colorFront\":\"\(colorFront)\",\"longitude\":\"\(TabBarController.location?.coordinate.longitude ?? 0.0)\",\"latitude\":\"\(TabBarController.location?.coordinate.latitude ?? 0.0)\"}}}"
            TabBarController.socket.write(string: JSONString)
            messageTextField.text = ""
        } else {
            let JSONString = "{\"Type\": 5,\"Data\":{\"Message\":{\"message\":\"\(messageTextField.text ?? "")\", \"chatID\":\"\(chat_id )\", \"userFrom\":\"\(UserDefaults.standard.string(forKey: "Username")!)\",\"colorBack\":\"\(colorBack)\",\"colorFront\":\"\(colorFront)\",\"chatTitle\":\"\(chat_title)\",\"longitude\":\"\(TabBarController.location?.coordinate.longitude ?? 0.0)\",\"latitude\":\"\(TabBarController.location?.coordinate.latitude ?? 0.0)\"}}}"
            TabBarController.socket.write(string: JSONString)
            messageTextField.text = ""
        }
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
        
        let bubbleImage = UIImage(named: "Chat Bubble")?
            .resizableImage(withCapInsets: UIEdgeInsets(top: 27.5, left: 27.5, bottom: 27.5, right: 27.5),
                            resizingMode: .stretch)
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
            cell.messageLabel.textColor = uiColorFromHex(rgbValue: colorFront[indexPath.row])
            cell.chatBubble.image = bubbleImage
            //change color of chatBubble to Orange for User message
            cell.chatBubble.tintColor = uiColorFromHex(rgbValue: colorBack[indexPath.row]) //Orange//
        } else {
            //If message sent not sent by user flip trailing and leading distances back to normal
            cell.chatBubbleTrailing.constant = frombubbleTrailing
            cell.chatBubbleLeading.constant = frombubbleLeading
            cell.messageTrailing.constant = frommessageTrailing
            cell.messageLeading.constant = frommessageLeading
            //change color of text to white for message not sent by user
            cell.messageLabel.textColor = uiColorFromHex(rgbValue: colorFront[indexPath.row])
            cell.messageFrom.text = from[indexPath.row]
            cell.chatBubble.image = bubbleImage
            //change color of chatBubble to Pink for non-User message
            cell.chatBubble.tintColor = uiColorFromHex(rgbValue: colorBack[indexPath.row]) //Pink
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
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
        let URL_USER_GET_CHAT = AppDelegate.URLConnection + "/GetChat"
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
                            let colorBack = dictionary.value(forKey: "colorBack") as? Int
                            let colorFront = dictionary.value(forKey: "colorFront") as? Int
                            self.message.insert(message!, at: 0)
                            self.from.insert(from!, at:0)
                            self.colorBack.insert(colorBack!, at:0)
                            self.colorFront.insert(colorFront!, at:0)
                        })
                        self.tableView.reloadData()
                    }else{
                        print("Unsuccessful")
                    }
                }
        }
    }
}
