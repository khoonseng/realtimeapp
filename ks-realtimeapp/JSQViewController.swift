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
    let firebase = Firebase(url: "https://ks-realtimeapp.firebaseio.com")
    var userConnection = Firebase()
    var keys = [String]()
    var imageToSend: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupCollectUsers()
        setup()
        
    }
    
    func setupCollectUsers() {
        firebase.childByAppendingPath("users").observeSingleEventOfType(FEventType.Value) { (snapshot: FDataSnapshot!) in
            print("Single -> \(snapshot)")
        }
        firebase.childByAppendingPath("users").observeEventType(FEventType.ChildChanged) { (snapshot: FDataSnapshot!) in
            print("Observer -> \(snapshot)")
        }
    }
    
    func setup() {
        //print("id: \(senderId) userName: \(senderDisplayName)")
        
        userConnection = Firebase(url: "https://ks-realtimeapp.firebaseio.com/users/\(senderId)/isOnline")
        userConnection.onDisconnectSetValue("false")
        
        //self.senderId = "uidFromFirebase"
        //self.senderDisplayName = "username"
        
        //accessory button
        //self.inputToolbar.contentView.leftBarButtonItem.hidden = true
        //self.inputToolbar.contentView.leftBarButtonItemWidth = 0
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        incomingBubble = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        outgoingBubble = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        
        createAvatar(senderId, senderDisplayName: senderDisplayName, color: UIColor.lightGrayColor())
        
        firebase.childByAppendingPath("JSQNode").queryLimitedToLast(50).observeSingleEventOfType(FEventType.Value) { (snapshot:FDataSnapshot!) in
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
        
        firebase.childByAppendingPath("JSQNode").queryLimitedToLast(1).observeEventType(FEventType.ChildAdded) { (snapshot:FDataSnapshot!) in
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
        firebase.childByAppendingPath("JSQNode").childByAutoId().setValue(["message":text, "senderId": senderId, "senderDisplayName": senderDisplayName, "date":date.timeIntervalSince1970, "messageType":"txt"])
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
    
    //MARK:
    override func didPressAccessoryButton(sender: UIButton!) {
        //print("Accessory button pressed")
        
        let alertController = UIAlertController(title: "Select Image", message: nil, preferredStyle: .ActionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (alertAction : UIAlertAction) in
            print("Selected Camera")
            self.getImageFrom(.Camera)
        }
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (alertAction : UIAlertAction) in
            print("Selected Gallery")
            self.getImageFrom(.PhotoLibrary)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (alertAction : UIAlertAction) in
            print("Selected Cancel")
        }
        
        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func getImageFrom(source: UIImagePickerControllerSourceType) { //source is camera or gallery
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.modalPresentationStyle = .CurrentContext
            imagePicker.sourceType = source
            imagePicker.allowsEditing = false
            if source == .Camera {
                imagePicker.cameraDevice = .Rear
            }
            self.presentViewController(imagePicker, animated: true, completion: nil)
        } else {
            print("The selected source is not available in this device")
        }
    }
}

extension JSQViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissPicker(picker)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        if picker.sourceType == UIImagePickerControllerSourceType.Camera || picker.sourceType == UIImagePickerControllerSourceType.PhotoLibrary {
            imageToSend = ImageHelper.resizeImage(image)
            
            /*
             convert image to string as firebase does not store image
            
             Firebase has 10MB size limitation for each field
             Recommend to use a Content Delivery Network to store images, and store the url in Firebase
             There is also storage limit on Firebase database
             */
            
        }
        dismissPicker(picker)
    }
    
    func dismissPicker(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        picker.delegate = nil
    }
}
