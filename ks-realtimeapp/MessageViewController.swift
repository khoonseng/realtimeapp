//
//  MessageViewController.swift
//  ks-realtimeapp
//
//  Created by khoonseng on 4/23/16.
//  Copyright © 2016 khoonseng. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {

    @IBOutlet var messageField: UITextField!
    //completion block
    var onMessageAvailable: ((data:String) ->())?
    
    @IBAction func sendMessage(sender: AnyObject) {
        if let text = messageField.text {
            onMessageAvailable!(data:text)
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancelMessage(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
