//
//  IBeaconViewController.swift
//  SciWeek58
//
//  Created by UnRAFE on 06/08/2015.
//  Copyright (c) 2015 Naresuan University. All rights reserved.
//

import UIKit
import QuartzCore
import CoreLocation
import CoreBluetooth
import RealmSwift
import STZPopupView
import CCMRadarView

class IBeaconViewController: UIViewController, CBPeripheralManagerDelegate,CLLocationManagerDelegate {
    
    @IBOutlet var radar: CCMRadarView!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var textStatus: UILabel!
    @IBOutlet var colorStatus: UIView!
    var locationManager: CLLocationManager!
    var bluetoothPeripheralManager: CBPeripheralManager!
    var isBroadcasting = false
    
    var distance: Double?
    var record: Bool = false
    var passed: Bool = false
    var bluetoothOn: Bool = false
    var beaconUuid: String = ""
    var beaconMajor: CLBeaconMajorValue = 0
    var beaconMinor: CLBeaconMinorValue = 0
    var beaconUniqId: String = ""
    var quest:Quest?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.quest?.text
        
        self.colorStatus.layer.cornerRadius = self.colorStatus.frame.size.width/2
        self.textStatus.layer.cornerRadius = self.textStatus.frame.size.width/2
        self.colorStatus.layer.masksToBounds = true
        self.textStatus.layer.masksToBounds = true
        self.colorStatus.backgroundColor = UIColor.grayColor()
        self.textStatus.text = String(format: "")
        self.setFont()
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    func startQuest() {
        
        var strAnswer: String = self.quest!.answer
        let arrayAnswers = strAnswer.componentsSeparatedByString(",")
        if arrayAnswers.count >= 5 {
            beaconUuid = arrayAnswers[0]
            beaconMajor = CLBeaconMajorValue(arrayAnswers[1].toInt()!)
            beaconMinor = CLBeaconMinorValue(arrayAnswers[2].toInt()!)
            beaconUniqId = arrayAnswers[3]
            
            var doubleValue : Double = NSString(string: arrayAnswers[4]).doubleValue
            distance = doubleValue
        }
        
        BProgressHUD.showMessageAutoHide(1, msg: "กำลังโหลด") { () -> Void in
            self.configureView()
            self.startScanning()
        }
    }
    
    func configureView() {
        radar.startAnimation()
        
        let aString: String = self.quest!.other
        let newString = aString.stringByReplacingOccurrencesOfString(",", withString: "\n")
        self.descriptionTextView.text = newString
    }
    
    func startScanning() {
        
        let uuid = NSUUID(UUIDString: beaconUuid)
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: beaconMajor, minor: beaconMinor, identifier:beaconUniqId)
        
        locationManager.startMonitoringForRegion(beaconRegion)
        locationManager.startRangingBeaconsInRegion(beaconRegion)
    }
    
    func stopScanning() {
        radar.stopAnimation()
        let uuid = NSUUID(UUIDString: beaconUuid)
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: beaconMajor, minor: beaconMinor, identifier:beaconUniqId)
        
        locationManager.stopMonitoringForRegion(beaconRegion)
        locationManager.stopRangingBeaconsInRegion(beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        
        if beacons.count > 0 {
            let beacon = beacons[0] as! CLBeacon
            updateDistance(beacon.proximity, acc: Double(beacon.accuracy))
        } else {
            
            updateDistance(CLProximity.Unknown, acc: 9999.0)
        }
    }
    
    func updateDistance(proximity: CLProximity, acc: Double) {
        UIView.animateWithDuration(0.8, animations: { () -> Void in
            switch proximity {
            case .Unknown:
                self.colorStatus.backgroundColor = UIColor.grayColor()
                self.textStatus.text = String(format: "Searching...")
            case .Far:
                self.colorStatus.backgroundColor = UIColor.redColor()
                self.updateTextStatus(acc)
            case .Near:
                self.colorStatus.backgroundColor = UIColor.orangeColor()
                self.updateTextStatus(acc)
            case .Immediate:
                self.colorStatus.backgroundColor = UIColor.greenColor()
                self.updateTextStatus(acc)
                
            }
        })
        
        if(proximity != .Unknown){
            if acc <= distance && !passed{
                self.checkedInSuccess()
            }
        }
    }
    
    func updateTextStatus(acc: Double) {
        if acc <= 10.0 {
            self.textStatus.text = String(format: "%.2f m", acc)
        }
        else {
            self.textStatus.text = String(format: "Searching...")
        }
    }
    
    // MARK: CBPeripheralManagerDelegate method implementation
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
        var statusMessage = ""
        
        switch peripheral.state {
        case CBPeripheralManagerState.PoweredOn:
            statusMessage = "Bluetooth Status: Turned On"
            bluetoothOn = true
            self.startQuest()
            
        case CBPeripheralManagerState.PoweredOff:
            if self.bluetoothOn {
                self.stopScanning()
                bluetoothOn = false
                self.turnOffBluetoothWhenPlaying()
            }
            else {
                self.pleaseTurnBlutoothOn()
            }
            statusMessage = "Bluetooth Status: Turned Off"
            
        case CBPeripheralManagerState.Resetting:
            statusMessage = "Bluetooth Status: Resetting"
            
        case CBPeripheralManagerState.Unauthorized:
            statusMessage = "Bluetooth Status: Not Authorized"
            
        case CBPeripheralManagerState.Unsupported:
            statusMessage = "Bluetooth Status: Not Supported"
            
        default:
            statusMessage = "Bluetooth Status: Unknown"
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
    
    func checkedInSuccess() {
        
        passed = true
        self.stopScanning()
        let popupView = createPopupview()
        
        let popupConfig = STZPopupViewConfig()
        popupConfig.dismissTouchBackground = false
        popupConfig.cornerRadius = 10
        popupConfig.overlayColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        popupConfig.showAnimation = .SlideInFromTop
        popupConfig.dismissAnimation = .SlideOutToBottom
        popupConfig.showCompletion = { popupView in
            println("show")
        }
        popupConfig.dismissCompletion = { popupView in
            if self.record {
                var delayEli = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("done"), userInfo: nil, repeats: false)
            }
        }
        presentPopupView(popupView, config: popupConfig)
        
    }
    
    func turnOffBluetoothWhenPlaying() {
        
        let title = "Bluetooth ถูกปิดแล้ว"
        let message = "เพื่อการใช้งาน ควรเปิด Bluetooth"
        let cancelButtonTitle = "รับทราบ"
        
        let alertCotroller = DOAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            //No action
        }
        // Add the actions.
        alertCotroller.addAction(cancelAction)
        
        presentViewController(alertCotroller, animated: true, completion: nil)
    }
    
    func pleaseTurnBlutoothOn() {
        
        let title = "Bluetooth ปิดอยู่"
        let message = "กรุณาเปิด Bluetooth"
        let cancelButtonTitle = "รับทราบ"
        
        let alertCotroller = DOAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            //No action
        }
        // Add the actions.
        alertCotroller.addAction(cancelAction)
        
        presentViewController(alertCotroller, animated: true, completion: nil)
    }
    
    func updatePoints() {
        if passed {
            DatabaseManager.updateCompleteQuest(quest!)
        }
        record = true
        dismissPopupView()
    }
    
    func setFont() {
        if Style.DeviceType.IS_IPAD {
            self.descriptionTextView.font = UIFont.systemFontOfSize(24)
        }
    }
    
    func done() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

}
