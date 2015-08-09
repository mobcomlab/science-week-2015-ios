//
//  QRViewController.swift
//  SciWeek58
//
//  Created by UnRAFE on 06/08/2015.
//  Copyright (c) 2015 Naresuan University. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftQRCode

class QRViewController: UIViewController {

    @IBOutlet var qrPreview: UIImageView!
    let scanner = QRCode()
    var quest:Quest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanner.prepareScan(qrPreview) { (stringValue) -> () in
            println(stringValue)
        }
        scanner.scanFrame = view.bounds
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // start scan
        scanner.startScan()
    }


}
