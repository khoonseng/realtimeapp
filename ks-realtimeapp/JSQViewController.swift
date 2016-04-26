//
//  JSQViewController.swift
//  ks-realtimeapp
//
//  Created by khoonseng on 4/26/16.
//  Copyright © 2016 khoonseng. All rights reserved.
//

import UIKit

class JSQViewController: JSQMessagesViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.senderId = "uidFromFirebase"
        self.senderDisplayName = "username"
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
