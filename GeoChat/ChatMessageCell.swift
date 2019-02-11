//
//  ChatMessageCell.swift
//  GeoChat
//
//  Created by Avery Pozzobon on 2019-02-09.
//  Copyright © 2019 Avery Pozzobon. All rights reserved.
//

import Foundation

import UIKit

class ChatMessageCell: UITableViewCell {
    
    @IBOutlet weak var chatBubbleTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var chatBubbleLeading: NSLayoutConstraint!
    
    @IBOutlet weak var messageTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var messageLeading: NSLayoutConstraint!
    
    @IBOutlet weak var chatBubble: UIView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    
    
    
    
}
