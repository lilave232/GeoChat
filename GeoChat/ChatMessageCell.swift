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
    
    @IBOutlet weak var chatBubbleBottom: NSLayoutConstraint!
    
    @IBOutlet weak var messageTrailing: NSLayoutConstraint!
    
    @IBOutlet weak var messageLeading: NSLayoutConstraint!
    
    @IBOutlet weak var chatBubble: UIImageView!
    
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var messageFrom: UILabel!
    
    
    /*
    let outgoingMessageView = UIImageView(frame:
    CGRect(x: 0,
    y: 0,
    width: 100,
    height: cell.frame.height))
    let bubbleImage = UIImage(named: "Chat Bubble")?
    .resizableImage(withCapInsets: UIEdgeInsets(top: 27.5, left: 27.5, bottom: 27.5, right: 27.5),
    resizingMode: .stretch)
    outgoingMessageView.image = bubbleImage
    outgoingMessageView.contentMode = .scaleToFill
    outgoingMessageView.translatesAutoresizingMaskIntoConstraints = false
    cell.contentView.addSubview(outgoingMessageView)
    let leftSideConstraint = NSLayoutConstraint(item: outgoingMessageView, attribute: .left, relatedBy: .equal, toItem: cell.contentView, attribute: .left, multiplier: 1.0, constant: frombubbleTrailing)
    let bottomConstraint = NSLayoutConstraint(item: outgoingMessageView, attribute: .bottom, relatedBy: .equal, toItem: cell.contentView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
    let rightSideConstraint = NSLayoutConstraint(item: outgoingMessageView, attribute: .right, relatedBy: .equal, toItem: cell.contentView, attribute: .right, multiplier: 1.0, constant: -frombubbleLeading)
    let topConstraint = NSLayoutConstraint(item: outgoingMessageView, attribute: .top, relatedBy: .equal, toItem: cell.contentView, attribute: .top, multiplier: 1.0, constant: cell.chatBubbleTop.constant)
    cell.contentView.addConstraints([leftSideConstraint, bottomConstraint, topConstraint, rightSideConstraint])
    print(cell.subviews.count)
    */
    
    
}
