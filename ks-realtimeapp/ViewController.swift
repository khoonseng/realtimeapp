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
        
        firebase.setValue(textField.text)
        textField.text = ""
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        firebase.setValue("This is a very long label that will take more than one line of the iPhone!")
        
        firebase.observeEventType(FEventType.Value) { (snapshot:FDataSnapshot!) -> Void in
            //print(snapshot.value)
            self.textLabel.text = snapshot.value as? String
            
            //self.firebase.setValue("Computer says no!")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

