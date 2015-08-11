//
//  InfoViewController.swift
//  SciWeek58
//
//  Created by Ant on 10/08/2015.
//  Copyright (c) 2015 Naresuan University. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BProgressHUD.showMessageAutoHide(1, msg: "กำลังโหลด") { () -> Void in
            let url = NSURL(string: "\(WebServiceManager.baseURLString)info")!
            self.webView.loadRequest(NSURLRequest(URL: url))
        }
    }
}
