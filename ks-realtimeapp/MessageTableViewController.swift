//
//  MessageTableViewController.swift
//  ks-realtimeapp
//
//  Created by khoonseng on 4/23/16.
//  Copyright © 2016 khoonseng. All rights reserved.
//

import UIKit

struct Message {
    let message: String?
    let uid: String?
}


class MessageTableViewController: UITableViewController {

    var firebase = Firebase(url: "https://ks-realtimeapp.firebaseio.com")
    var childAddedHandler = FirebaseHandle()
    var listOfMessages = Array<Message>()
    
    @IBAction func logOut(sender: AnyObject) {
        firebase.childByAppendingPath("users").childByAppendingPath(self.firebase.authData.uid).updateChildValues(["isOnline":false])
        firebase.unauth()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addMessage(sender: AnyObject) {
    
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //send messages between 2 view controllers using completion block and prepareForSegue
        if let messageController = segue.destinationViewController as? MessageViewController {
            messageController.onMessageAvailable = {[weak self]
                (data) in
                if let weakSelf = self {
                    weakSelf.receiveMessageToSendToFirebase(data)
                }
            }
        }
    }
    
    func receiveMessageToSendToFirebase(data:String) {
        let details = ["message":data, "sender": firebase.authData.uid]
        firebase.childByAppendingPath("posts").childByAutoId().setValue(details)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        childAddedHandler = firebase.observeEventType(.ChildAdded, withBlock: { (snapshot:FDataSnapshot!) in
            if let newMessages = snapshot.value as? NSDictionary {
                print(newMessages)
                for newMessage in newMessages {
                    let message = newMessage.value
                    let appMessage = Message(message: message["message"] as? String, uid: message["sender"] as? String)
                    self.listOfMessages.append(appMessage)
                }
                print (self.listOfMessages)
            }
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
