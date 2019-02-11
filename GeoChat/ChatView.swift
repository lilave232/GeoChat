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
        tableView.reloadData()
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var chat_title = ""
    var chat_id = ""
    var chat:[String] = []
    var message:[String] = []
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let JSONString = "{\"Type\": 3,\"Data\":{\"Chat\":{\"chatID\":\"\(chat_id ?? "")\", \"Username\":\"\(UserDefaults.standard.string(forKey: "Username")!)\"}}}"
        TabBarController.socket.write(string: JSONString)
    }
    
    
    @IBAction func sendMessageAction(_ sender: Any) {
        let JSONString = "{\"Type\": 1,\"Data\":{\"Message\":{\"message\":\"\(messageTextField.text ?? "")\", \"chatID\":\"\(chat_id )\", \"userFrom\":\"\(UserDefaults.standard.string(forKey: "Username")!)\"}}}"
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
            //change color of text to Black for User message
            cell.messageLabel.textColor = UIColor.black
            //change color of chatBubble to Orange for User message
            cell.chatBubble.backgroundColor = UIColor(red:0.97, green:0.66, blue:0.24, alpha:1.0) //Orange
        } else {
            //If message sent not sent by user flip trailing and leading distances back to normal
            cell.chatBubbleTrailing.constant = frombubbleTrailing
            cell.chatBubbleLeading.constant = frombubbleLeading
            cell.messageTrailing.constant = frommessageTrailing
            cell.messageLeading.constant = frommessageLeading
            //change color of text to white for message not sent by user
            cell.messageLabel.textColor = UIColor.white
            //change color of chatBubble to Pink for non-User message
            cell.chatBubble.backgroundColor = UIColor(red:0.96, green:0.43, blue:0.83, alpha:1.0) //Pink
        }
        return cell
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
}
