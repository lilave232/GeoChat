//
//  FriendsPickerCell.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-02-27.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

protocol addFriendProtocol: class {
    func addFriend(User:String)
    func removeFriend(User:String)
}

class FriendsPickerCell: UITableViewCell {
    
    @IBOutlet weak var Label: UILabel!
    
    var delegate: addFriendProtocol?
    
    @IBOutlet weak var slider: UISwitch!
    
    @IBAction func sliderChanged(_ sender: Any) {
        if (slider.isOn) {
            delegate?.addFriend(User: Label.text!)
        } else {
            delegate?.removeFriend(User: Label.text!)
        }
    }
    
}
