//
//  JSQViewController.swift
//  ks-realtimeapp
//
//  Created by khoonseng on 4/26/16.
//  Copyright © 2016 khoonseng. All rights reserved.
//

import UIKit

class JSQViewController: JSQMessagesViewController {

    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var avatars = [String: JSQMessagesAvatarImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.senderId = "uidFromFirebase"
        self.senderDisplayName = "username"
        self.inputToolbar.contentView.leftBarButtonItem.hidden = true
        self.inputToolbar.contentView.leftBarButtonItemWidth = 0
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        incomingBubble = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        outgoingBubble = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        
        createAvatar(senderId, senderDisplayName: senderDisplayName, color: UIColor.lightGrayColor())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createAvatar(senderID:String,senderDisplayName:String, color:UIColor) {
        if avatars[senderID] == nil {
            let initials = senderDisplayName.substringToIndex(senderDisplayName.startIndex.advancedBy(min(2,senderDisplayName.characters.count)))
            let avatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            avatars[senderID] = avatar
        }
    }
}
