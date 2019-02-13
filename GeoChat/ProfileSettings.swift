//
//  ProfileSettings.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-02-12.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ProfileSettings: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var UsernameLabel: UILabel!
    
    @IBOutlet weak var BackgroundColorButton: UIButton!
    
    var Friends:[String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    @IBAction func showFriendsView(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc1 = mainStoryboard.instantiateViewController(withIdentifier: "FriendsView") as! FriendsTableView
        vc1.Friends = Friends
        self.show(vc1, sender:nil)
    }
    
    @IBAction func changeBackgroundAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc1 = mainStoryboard.instantiateViewController(withIdentifier: "ColorPicker") as! ColorPicker
        vc1.setting = "ColorBack"
        self.show(vc1, sender:nil)
    }
    
    @IBOutlet weak var ForegroundColorButton: UIButton!
    
    
    @IBAction func changeForegroundAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc1 = mainStoryboard.instantiateViewController(withIdentifier: "ColorPicker") as! ColorPicker
        vc1.setting = "ColorFront"
        self.show(vc1, sender: nil)
    }
    
    @IBOutlet weak var previewBackground: UIView!
    
    @IBOutlet weak var previewForeground: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UsernameLabel.text = UserDefaults.standard.string(forKey: "Username")
        if (UserDefaults.standard.object(forKey: "ColorBack") != nil) {
            BackgroundColorButton.backgroundColor = uiColorFromHex(rgbValue: UserDefaults.standard.integer(forKey: "ColorBack"))
            previewBackground.backgroundColor = uiColorFromHex(rgbValue: UserDefaults.standard.integer(forKey: "ColorBack"))
        }
        if (UserDefaults.standard.object(forKey: "ColorFront") != nil) {
            ForegroundColorButton.backgroundColor = uiColorFromHex(rgbValue: UserDefaults.standard.integer(forKey: "ColorFront"))
            previewForeground.textColor = uiColorFromHex(rgbValue: UserDefaults.standard.integer(forKey: "ColorFront"))
        }
        GetFriends(Username: UsernameLabel.text)
        self.tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell")! as! FriendsCell
        cell.Friend.text = Friends[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let Unfriend = UITableViewRowAction(style: .normal, title: "Unfriend") { action, index in
            self.RemoveFriend(Username: UserDefaults.standard.string(forKey: "Username"), Friend: self.Friends[editActionsForRowAt.row])
            self.Friends.remove(at: editActionsForRowAt.row)
            self.tableView.reloadData()
        }
        Unfriend.backgroundColor = .red
        
        let Message = UITableViewRowAction(style: .normal, title: "Message") { action, index in
            print("favorite button tapped")
        }
        Message.backgroundColor = .blue
        
        return [Message, Unfriend]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func GetFriends(Username: String?) {
        let parameters: Parameters=[
            "Username":Username!,
        ]
        let URL_USER_GET_FRIENDS = AppDelegate.URLConnection + ":8081/GetFriends"
        Alamofire.request(URL_USER_GET_FRIENDS, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                self.Friends = []
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        let array = jsonData.value(forKey: "chats") as! [NSDictionary]
                        array.forEach(
                            {(dictionary) in
                                let friend = dictionary.value(forKey: "Friend") as? String
                                self.Friends.append(friend!)
                        })
                    }else{
                        print("Error Or No Friends")
                    }
                    self.tableView.reloadData()
                }
        }
    }
    
    func RemoveFriend(Username: String?, Friend: String?) {
        let parameters: Parameters=[
            "Username":Username!,
            "Friend":Friend!,
        ]
        let URL_USER_REMOVE_FRIEND = AppDelegate.URLConnection + ":8081/RemoveFriend"
        Alamofire.request(URL_USER_REMOVE_FRIEND, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        self.GetFriends(Username: Username!)
                    }else{
                        print("Friend Could Not Be Removed")
                    }
                    self.tableView.reloadData()
                }
        }
    }
    
    func uiColorFromHex(rgbValue: Int) -> UIColor {
        
        let red =   CGFloat((rgbValue & 0xFF0000) >> 16) / 0xFF
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 0xFF
        let blue =  CGFloat(rgbValue & 0x0000FF) / 0xFF
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
