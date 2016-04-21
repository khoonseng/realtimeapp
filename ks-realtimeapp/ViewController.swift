//
//  ViewController.swift
//  ks-realtimeapp
//
//  Created by khoonseng on 4/16/16.
//  Copyright © 2016 khoonseng. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let firebase = Firebase (url: "https://ks-realtimeapp.firebaseio.com")
    
    @IBOutlet var textField: UITextField!
    @IBOutlet var textLabel: UILabel!
    
   
    @IBAction func sendMessageButton(sender: AnyObject) {
        
        //firebase.setValue(textField.text)
        
        
        firebase.childByAppendingPath("user").childByAppendingPath("name").setValue(textField.text)
        firebase.childByAppendingPath("user").childByAppendingPath("isOnline").setValue(true)
        
        textField.text = ""
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //firebase.setValue("This is a very long label that will take more than one line of the iPhone!")
        /*
        firebase.childByAppendingPath("users").childByAppendingPath("name").childByAppendingPath("firstName").setValue("Khoon Seng")
        firebase.childByAppendingPath("users").childByAppendingPath("name").childByAppendingPath("lastName").setValue("Lim")
        firebase.childByAppendingPath("users").childByAppendingPath("age").setValue("29")
        firebase.childByAppendingPath("users").childByAppendingPath("gender").setValue("Male")
        firebase.childByAppendingPath("users").childByAppendingPath("isOnline").setValue("true")*/
        
        firebase.observeEventType(FEventType.Value) { (snapshot:FDataSnapshot!) -> Void in
            //print(snapshot.value)
            //self.textLabel.text = snapshot.value as? String
            
            //self.firebase.setValue("Computer says no!")
            
            if let snapshot = snapshot.value["user"] {
                if let name = snapshot?.objectForKey("name") as? String {
                    self.textLabel.text = name
                }
                if let isOnline = snapshot?.objectForKey("isOnline") as? Bool {
                    print(isOnline)
                    if isOnline {
                        self.view.backgroundColor = UIColor.greenColor()
                    } else {
                        self.view.backgroundColor = UIColor.whiteColor()
                    }
                }
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

