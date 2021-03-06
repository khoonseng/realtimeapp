//
//  LoginViewController.swift
//  ks-realtimeapp
//
//  Created by khoonseng on 4/22/16.
//  Copyright © 2016 khoonseng. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    var firebase = Firebase(url: "https://ks-realtimeapp.firebaseio.com")
    var username = String()
    var newUser = false
    
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    
    @IBAction func loginButton(sender: AnyObject) {
        authenticateUser()
    }
    
    
    @IBAction func signUpButton(sender: AnyObject) {
        if checkFields() {
            firebase.createUser(email.text, password: password.text) { (error:NSError!) in
                if error != nil {
                    print(error.localizedDescription)
                    self.displayMessage(error)
                } else {
                    print("new user created")
                    self.createUsername()
                }
            }
        }
    }
    
    func authenticateUser() {
        if checkFields() {
            print("Start authentication...")
            firebase.authUser(email.text, password: password.text) { (error:NSError!, authData:FAuthData!) in
                if error != nil {
                    print(error.localizedDescription)
                    self.displayMessage(error)
                } else {
                    print("user logged " + authData.description)
                    let uid = authData.uid
                    if self.newUser {
                        self.firebase.childByAppendingPath("users").childByAppendingPath(uid).setValue(["isOnline":true, "name":self.username])
                        self.performSegueWithIdentifier("segueJSQ", sender: self)
                    } else {
                        self.firebase.childByAppendingPath("users").childByAppendingPath(uid).updateChildValues(["isOnline":true])
                        self.retrieveUserName()
                    }
                    
                }
            }
        }
    }
    
    func retrieveUserName() {
        self.firebase.childByAppendingPath("users").childByAppendingPath(firebase.authData.uid).observeSingleEventOfType(FEventType.Value) { (snapshot: FDataSnapshot!) in
            //print(snapshot)
            self.username = (snapshot.value as! NSDictionary)["name"] as! String
            //self.id = (snapshot.value as! NSDictionary)["name"] as! String
            print(self.username)
            self.firebase.childByAppendingPath("users").childByAppendingPath(self.firebase.authData.uid).updateChildValues(["isOnline":true])
            self.performSegueWithIdentifier("segueJSQ", sender: self)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueJSQ" {
            let uid = self.firebase.authData.uid
            if let viewController = segue.destinationViewController as? JSQViewController {
                firebase.childByAppendingPath("users").childByAppendingPath(uid).updateChildValues(["isOnline":true])
                viewController.senderId = self.firebase.authData.uid
                viewController.senderDisplayName = self.username
            }
        }
    }
    
    func checkFields() -> Bool {
        if (!email.text!.isEmpty && !password.text!.isEmpty) {
            return true
        } else {
            print("Email and password cannot be empty")
            return false
        }
    }
    
    func displayMessage(error:NSError) {
        let title = "Error"
        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func createUsername() {
        var usernameTextField: UITextField?
        let title = "Enter a username"
        let message = "Please enter a username for your new account:"
        let usernameEntry = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: .Default) { (UIAlertAction) in
            if let user = usernameTextField?.text {
                print(user)
                self.newUser = true
                self.username = user
                self.authenticateUser()
            }
        }
        
        usernameEntry.addAction(action)
        usernameEntry.addTextFieldWithConfigurationHandler { (username:UITextField) in
            usernameTextField = username
        }
        self.presentViewController(usernameEntry, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //check if user is logged in
        if firebase.authData != nil {
            retrieveUserName()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        email.text = ""
        password.text = ""
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
