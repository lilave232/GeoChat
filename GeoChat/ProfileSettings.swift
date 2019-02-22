//
//  Settings.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-02-22.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class ProfileSettings: UITableViewController {
    @IBOutlet weak var UsernameLabel: UILabel!
    
    @IBOutlet weak var BackgroundColorButton: UIButton!
    
    var Friends:[String] = []
    
    @IBOutlet weak var fullscreenLabel: UIButton!
    
    @IBOutlet weak var addFriendsLabel: UIButton!
    
    @IBOutlet weak var requestsLabel: UIButton!
    
    @IBOutlet weak var kilometersLabel: UILabel!
    
    
    @IBAction func showFriendsView(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc1 = mainStoryboard.instantiateViewController(withIdentifier: "FriendsView") as! FriendsTableView
        vc1.Friends = Friends
        self.show(vc1, sender:nil)
    }
    
    @IBAction func changeBackgroundAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc1 = mainStoryboard.instantiateViewController(withIdentifier: "ColorPicker") as! colorPicker_1Sample
        vc1.setting = "ColorBack"
        self.show(vc1, sender:nil)
    }
    
    @IBOutlet weak var kilometersSlider: UISlider!
    
    @IBAction func distanceChanged(_ sender: Any) {
        if (kilometersSlider.value > 1000) {
            kilometersLabel.text = String(format: "%.01f",Double(kilometersSlider.value/1000)) + "km"
        } else {
            kilometersLabel.text = String(format: "%.01f",Double(kilometersSlider.value)) + "m"
        }
        UserDefaults.standard.set(Double(kilometersSlider.value),forKey:"radius")
    }
    
    
    
    @IBOutlet weak var ForegroundColorButton: UIButton!
    
    
    @IBAction func changeForegroundAction(_ sender: Any) {
        let mainStoryboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc1 = mainStoryboard.instantiateViewController(withIdentifier: "ColorPicker") as! colorPicker_1Sample
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
        kilometersSlider.value = Float(UserDefaults.standard.double(forKey: "radius"))
        if (kilometersSlider.value > 1000) {
            kilometersLabel.text = String(format: "%.01f",Double(kilometersSlider.value/1000)) + "km"
        } else {
            kilometersLabel.text = String(format: "%.01f",Double(kilometersSlider.value)) + "m"
        }
        fullscreenLabel.titleLabel?.numberOfLines = 1
        fullscreenLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        fullscreenLabel.titleLabel?.minimumScaleFactor = 0.8
        
        addFriendsLabel.titleLabel?.numberOfLines = 1
        addFriendsLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        addFriendsLabel.titleLabel?.minimumScaleFactor = 0.8
        
        requestsLabel.titleLabel?.numberOfLines = 1
        requestsLabel.titleLabel?.adjustsFontSizeToFitWidth = true
        requestsLabel.titleLabel?.minimumScaleFactor = 0.8
        
        
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
    }
    
    func GetFriends(Username: String?) {
        let parameters: Parameters=[
            "Username":Username!,
        ]
        let URL_USER_GET_FRIENDS = AppDelegate.URLConnection + "/GetFriends"
        Alamofire.request(URL_USER_GET_FRIENDS, method: .post, parameters: parameters).responseJSON
            {
                response in
                print(response)
                self.Friends = []
                if let result = response.result.value {
                    let jsonData = result as! NSDictionary
                    if(!(jsonData.value(forKey: "error") as! Bool)){
                        let requests = jsonData.value(forKey: "pending") as! Int
                        self.requestsLabel.setTitle("Requests(" + String(requests) + ")", for: .normal)
                        let array = jsonData.value(forKey: "values") as! [NSDictionary]
                        array.forEach(
                            {(dictionary) in
                                let friend = dictionary.value(forKey: "Friend") as? String
                                self.Friends.append(friend!)
                        })
                    }else{
                        let requests = 0
                        self.requestsLabel.setTitle("Requests(" + String(requests) + ")", for: .normal)
                        print("Error Or No Friends")
                    }
                }
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
                        self.GetFriends(Username: Username!)
                    }else{
                        print("Friend Could Not Be Removed")
                    }
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
