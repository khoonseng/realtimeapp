//
//  MessageTableViewController.swift
//  ks-realtimeapp
//
//  Created by khoonseng on 4/23/16.
//  Copyright © 2016 khoonseng. All rights reserved.
//

import UIKit

struct User {
    let uid: String?
    let name: String?
}

/*
//this static class is removed. will change to dynamic class based on firebase
struct Message {
    let message: String?
    let uid: String?
}*/


class MessageTableViewController: UITableViewController {

    var firebase = Firebase(url: "https://ks-realtimeapp.firebaseio.com")
    var childAddedHandler = FirebaseHandle()
    var listOfMessages = NSMutableDictionary()
    
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
        
        childAddedHandler = firebase.childByAppendingPath("posts").observeEventType(.Value, withBlock: { (snapshot:FDataSnapshot!) in
            self.firebaseUpdate(snapshot)
        })
        
        childAddedHandler = firebase.observeEventType(.ChildChanged, withBlock: { (snapshot:FDataSnapshot!) in
            self.firebaseUpdate(snapshot)
        })
        
    }
    
    func firebaseUpdate(snapshot: FDataSnapshot) {
        if let newMessages = snapshot.value as? NSDictionary {
            print(newMessages)
            for newMessage in newMessages {
                let key = newMessage.key as! String
                let messageExist = (self.listOfMessages[key] != nil)
                if !messageExist {
                    self.listOfMessages.setValue(newMessage.value, forKey: key)
                }
                
                /* removed as this is using static array.
                 let message = newMessage.value
                 let appMessage = Message(message: message["message"] as? String, uid: message["sender"] as? String)
                 self.listOfMessages.append(appMessage)*/
            }
        }
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in // to avoid memory leak
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return listOfMessages.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)

        //convert NSDictionary keys to array
        let arrayOfKeys = listOfMessages.allKeys
        let key = arrayOfKeys[indexPath.row]
        let value = listOfMessages[key as! String]
        cell.textLabel?.text = (value as! NSDictionary)["message"] as? String
        
        return cell
    }
    

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
