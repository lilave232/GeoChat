//
//  AddFriendsCell.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-02-12.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class AddFriendsCell: UITableViewCell {
    
    var grey = true
    
    @IBOutlet weak var friendsLabel: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBAction func addAction(_ sender: Any) {
        addButton.isEnabled = false
        if (grey) {
            AddFriend(Username: UserDefaults.standard.string(forKey: "Username"), Friend: friendsLabel.text)
        } else {
            RemoveFriend(Username: UserDefaults.standard.string(forKey: "Username"), Friend: friendsLabel.text)
        }
    }
    
    func RemoveFriend(Username: String?, Friend: String?) {
        let parameters: Parameters=[
            "Username":Username!,
            "Friend":Friend!,
        ]
        let URL_USER_REMOVE_FRIEND = AppDelegate.URLConnection + "/RemoveFriend"
        Alamofire.request(URL_USER_REMOVE_FRIEND, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        self.grey = true
                        self.addButton.tintColor = UIColor.lightGray
                    }else{
                        print("Friend Could Not Be Removed")
                    }
                }
                self.addButton.isEnabled = true
        }
    }
    
    func AddFriend(Username: String?, Friend: String?) {
        let parameters: Parameters=[
            "Username":Username!,
            "Friend":Friend!,
        ]
        let URL_USER_REMOVE_FRIEND = AppDelegate.URLConnection + "/AddFriends"
        Alamofire.request(URL_USER_REMOVE_FRIEND, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        self.addButton.tintColor = UIColor.green
                        self.grey = false
                    }else{
                        print("Friend Could Not Be Added")
                    }
                }
                self.addButton.isEnabled = true
        }
    }
    
}
