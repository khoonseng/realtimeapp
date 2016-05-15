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
    var messages = [JSQMessage]()
    let firebase = Firebase(url: "https://ks-realtimeapp.firebaseio.com/JSQNode")
    var userConnection = Firebase()
    var keys = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        print("id: \(senderId) userName: \(senderDisplayName)")
        
        userConnection = Firebase(url: "https://ks-realtimeapp.firebaseio.com/users/\(senderId)/isOnline")
        userConnection.onDisconnectSetValue("false")
        
        //self.senderId = "uidFromFirebase"
        //self.senderDisplayName = "username"
        self.inputToolbar.contentView.leftBarButtonItem.hidden = true
        self.inputToolbar.contentView.leftBarButtonItemWidth = 0
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        incomingBubble = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        outgoingBubble = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        
        createAvatar(senderId, senderDisplayName: senderDisplayName, color: UIColor.lightGrayColor())
        
        firebase.queryLimitedToLast(50).observeSingleEventOfType(FEventType.Value) { (snapshot:FDataSnapshot!) in
            //print(snapshot)
            
            let values = snapshot.value
            for value in values as! NSDictionary {
                if !self.keys.contains(snapshot.key){ //check if value not equals to current post
                    self.keys.append(value.key as! String)
                    if let message = value.value as? NSDictionary {
                        let date = message["date"] as! NSTimeInterval
                        let receiveSenderID = message["senderId"] as! String
                        let receiveDisplayName = message["senderDisplayName"] as! String
                        self.createAvatar(receiveSenderID, senderDisplayName: receiveDisplayName, color: UIColor.jsq_messageBubbleGreenColor())
                        let jsqMessage = JSQMessage(senderId: receiveSenderID, senderDisplayName: receiveDisplayName, date: NSDate(timeIntervalSince1970: date), text: message["message"] as! String)
                        self.messages.append(jsqMessage)
                    }
                }
            }
            //sort ascending
            self.messages.sortInPlace({ ($0.date.compare($1.date) == NSComparisonResult.OrderedAscending)})
            self.collectionView.reloadData()
        }
        
        firebase.queryLimitedToLast(1).observeEventType(FEventType.ChildAdded) { (snapshot:FDataSnapshot!) in
            //print(snapshot)
            if !self.keys.contains(snapshot.key){                
                self.keys.append(snapshot.key)
                if let message = snapshot.value as? NSDictionary {
                    let date = message["date"] as! NSTimeInterval
                    let receiveSenderID = message["senderId"] as! String
                    let receiveDisplayName = message["senderDisplayName"] as! String
                    self.createAvatar(receiveSenderID, senderDisplayName: receiveDisplayName, color: UIColor.jsq_messageBubbleGreenColor())
                    let jsqMessage = JSQMessage(senderId: receiveSenderID, senderDisplayName: receiveDisplayName, date: NSDate(timeIntervalSince1970: date), text: message["message"] as! String)
                    self.messages.append(jsqMessage)
                    if receiveSenderID != self.senderId {
                        JSQSystemSoundPlayer.jsq_playMessageReceivedSound()
                    }
                }
                
                self.finishReceivingMessageAnimated(true)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        //let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        firebase.childByAutoId().setValue(["message":text, "senderId": senderId, "senderDisplayName": senderDisplayName, "date":date.timeIntervalSince1970, "messageType":"txt"])
        //messages.append(message)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
    }
    
    func createAvatar(senderID:String,senderDisplayName:String, color:UIColor) {
        if avatars[senderID] == nil {
            let initials = senderDisplayName.substringToIndex(senderDisplayName.startIndex.advancedBy(min(2,senderDisplayName.characters.count)))
            let avatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(initials, backgroundColor: color, textColor: UIColor.blackColor(), font: UIFont.systemFontOfSize(14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
            avatars[senderID] = avatar
        }
    }
    
    //Override CollectionView Delegates
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.row]
        if message.senderId == senderId {
            return outgoingBubble
        }
        return incomingBubble
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = messages[indexPath.row]
        return avatars[message.senderId]
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        let message = messages[indexPath.row]
        if message.senderId == senderId {
            cell.textView.textColor = UIColor.blackColor()
        } else {
            cell.textView.textColor = UIColor.whiteColor()
        }
        cell.textView.linkTextAttributes = [NSForegroundColorAttributeName:(cell.textView.textColor)!]
        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = messages[indexPath.row]
        if indexPath.row <= 1 {
            return NSAttributedString(string: message.senderDisplayName)
        }
        
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
}
