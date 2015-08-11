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
import STZPopupView

class QRViewController: UIViewController {

    @IBOutlet var qrPreview: UIImageView!
    @IBOutlet var descriptionTextView: UITextView!
    let scanner = QRCode()
    
    var results:NSString? = nil
    var record: Bool = false
    var passed: Bool = false
    var quest:Quest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.quest?.text
        
        self.setFont()
        self.startQuest()
    }
    
    func startQuest() {
        
        BProgressHUD.showMessageAutoHide(1, msg: "กำลังโหลด") { () -> Void in
            self.configureView()
        }
    }
    
    func configureView() {
        
        let aString: String = self.quest!.other
        let newString = aString.stringByReplacingOccurrencesOfString(",", withString: "\n")
        self.descriptionTextView.text = newString
        
        scanner.prepareScan(qrPreview) { (stringValue) -> () in
            self.checkQRCode(stringValue)
        }
        scanner.scanFrame = qrPreview.bounds
        
        // start scan
        scanner.startScan()
    }
    
    func checkQRCode(result : NSString) {
        
        if result.isEqualToString(self.quest!.answer) {
            
            scanner.stopScan()
            passed = true
            let popupView = createPopupview()
            
            let popupConfig = STZPopupViewConfig()
            popupConfig.dismissTouchBackground = false
            popupConfig.cornerRadius = 10
            popupConfig.overlayColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
            popupConfig.showAnimation = .SlideInFromTop
            popupConfig.dismissAnimation = .SlideOutToBottom
            popupConfig.showCompletion = { popupView in
                //Show Alert
            }
            popupConfig.dismissCompletion = { popupView in
                if self.record {
                    var delayEli = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("done"), userInfo: nil, repeats: false)
                }
            }
            presentPopupView(popupView, config: popupConfig)
            
        }
        else {
            
            scanner.stopScan()
            let title = "QR Code ไม่ถูกต้อง"
            let message = ""
            let cancelButtonTitle = "ออก"
            let otherButtonTitle = "แสกนใหม่"
            
            let alertCotroller = DOAlertController(title: title, message: message, preferredStyle: .Alert)
            
            // Create the actions.
            let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
                var delayEli = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("done"), userInfo: nil, repeats: false)
            }
            
            let otherAction = DOAlertAction(title: otherButtonTitle, style: .Default) { action in
                self.configureView()
            }
            
            // Add the actions.
            alertCotroller.addAction(cancelAction)
            alertCotroller.addAction(otherAction)
            
            presentViewController(alertCotroller, animated: true, completion: nil)
        }
        
    }
    
    func createPopupview() -> UIView {
        
        let popupView = UIView(frame: CGRectMake(0, 0, 300, 400))
        popupView.backgroundColor = UIColor.whiteColor()
        
        let headView = UIView(frame: CGRectMake(10, 10, 280, 40))
        headView.backgroundColor = Style.ColorMain
        headView.layer.cornerRadius = 4.0
        
        let headLabel = UILabel(frame: CGRectMake(5, 5, 270, 30))
        headLabel.text = "ภารกิจสำเร็จแล้ว"
        headLabel.textColor = UIColor.whiteColor()
        headLabel.font = UIFont.systemFontOfSize(20)
        headLabel.textAlignment = .Center
        
        headView.addSubview(headLabel)
        popupView.addSubview(headView)
        
        let iconColorView = UIView(frame: CGRectMake(10, 60, 280, 280))
        iconColorView.backgroundColor = UIColor(rgba: self.quest!.color)
        iconColorView.layer.cornerRadius = 140
        popupView.addSubview(iconColorView)
        
        let iconView = UIImageView(image: UIImage(named: self.quest!.icon))
        iconView.frame = CGRectMake(10, 60, 280, 280)
        popupView.addSubview(iconView)
        
        if passed {
            let iconPassedView = UIImageView(image: UIImage(named: "PassedIcon"))
            iconPassedView.frame = CGRectMake(20, 70, 260, 260)
            popupView.addSubview(iconPassedView)
        }
        
        // Close button
        let closeButton = UIButton.buttonWithType(.System) as! UIButton
        closeButton.setTitle("ตกลง", forState: UIControlState.Normal)
        closeButton.frame = CGRectMake(10, 350, 280, 40)
        closeButton.layer.cornerRadius = 4.0
        closeButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        closeButton.backgroundColor = UIColor.grayColor()
        closeButton.addTarget(self, action: "updatePoints", forControlEvents: UIControlEvents.TouchUpInside)
        popupView.addSubview(closeButton)
        
        return popupView
    }
    
    func setFont() {
        if Style.DeviceType.IS_IPAD {
            self.descriptionTextView.font = UIFont.systemFontOfSize(24)
        }
    }
    
    func updatePoints() {
        if passed {
            DatabaseManager.updateCompleteQuest(quest!)
        }
        record = true
        dismissPopupView()
    }
    
    func clearText() {
        self.descriptionTextView.text = ""
    }
    
    func done() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }


}
