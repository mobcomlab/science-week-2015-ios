//
//  QuestViewController.swift
//  SciWeek58
//
//  Created by UnRAFE on 28/07/2015.
//  Copyright (c) 2015 Naresuan University. All rights reserved.
//

import RealmSwift

class QuestViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIAlertViewDelegate{
    
    @IBOutlet var collectionView: UICollectionView?
    private let reuseIdentifier = "QuestCell"
    var hidingNavBarManager:HidingNavigationBarManager?
    
    weak var secureTextAlertAction: DOAlertAction?
    var customAlertController: DOAlertController!
    weak var customAlertAction: DOAlertAction?
    
    var gridSize:CGFloat = 0
    var nullSpace:CGFloat = 0
    var gridOfRows:NSInteger = 0
    var quests: Results<Quest>? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //icon book
        let iconTitleImage = UIImageView()
        iconTitleImage.image = Style.resizeImage(UIImage(named: "AppIcon")!, targetSize: CGSizeMake(70.0, 70.0))
        iconTitleImage.frame = CGRectMake(0, 0, 35, 35)
        
        //Name
        let iconTitleLabel = UILabel()
        iconTitleLabel.text = "Science Week 2015"
        iconTitleLabel.sizeToFit()
        iconTitleLabel.textColor = UIColor.whiteColor()
        iconTitleLabel.font = UIFont.boldSystemFontOfSize(16.0)
        iconTitleLabel.frame = CGRectMake(45, 5, iconTitleLabel.frame.size.width, 25)
        
        //UIView
        let iconTitleView = UIView()
        iconTitleView.frame = CGRectMake(0, 0, 45+iconTitleLabel.frame.size.width+10, 35)
        
        //Add subview
        iconTitleView.addSubview(iconTitleImage)
        iconTitleView.addSubview(iconTitleLabel)
        
        //Nav icon
        navigationItem.titleView = iconTitleView
        
        // Nav bar right
        var infoBarButton = UIBarButtonItem(image: UIImage(named: "ic-info"), style: UIBarButtonItemStyle.Plain, target: self, action: "infoPressed")
        self.navigationItem.leftBarButtonItem = infoBarButton
        let moreBarButton = UIBarButtonItem(image: UIImage(named: "ic-more"), style: UIBarButtonItemStyle.Plain, target: self, action: "morePressed")
        self.navigationItem.rightBarButtonItem = moreBarButton
        
        if Style.DeviceType.IS_IPHONE_4_OR_LESS || Style.DeviceType.IS_IPHONE_5 {
            gridSize = 140
            gridOfRows = 2
        }
        else if Style.DeviceType.IS_IPHONE_6 {
            gridSize = 160
            gridOfRows = 2
        }
        else if Style.DeviceType.IS_IPHONE_6P {
            gridSize = 125
            gridOfRows = 3
        }
        else if Style.DeviceType.IS_IPAD {
            gridSize = 180
            gridOfRows = 3
        }
        
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        
        let space = screenWidth - (gridSize*CGFloat(gridOfRows))
        nullSpace = space/CGFloat(gridOfRows+1)
        
        self.requestWS()
        
        hidingNavBarManager = HidingNavigationBarManager(viewController: self, scrollView: self.collectionView!)
    }
    
    func requestWS() {
        
        WebServiceManager.requestQuests({ (error) -> () in
            if error == nil {
                self.collectionView?.reloadData()
                self.configureView()
            }
        })
    }
    
    func configureView() {
        
        self.quests = DatabaseManager.quests()
        self.collectionView?.reloadData()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureView()
        hidingNavBarManager?.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        hidingNavBarManager?.viewDidLayoutSubviews()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        hidingNavBarManager?.viewWillDisappear(animated)
    }
    
    // MARK: Collection View
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        hidingNavBarManager?.shouldScrollToTop()
        
        return true
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        return CGSize(width: gridSize , height: gridSize+25.0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return nullSpace
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(nullSpace, nullSpace, nullSpace, nullSpace)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if quests != nil {
            return quests!.count
        }
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as! QuestCell
        
        let quest = quests![indexPath.row]
        
        cell.circleView.layer.cornerRadius = (gridSize-20)/2
        cell.setGrid(quest)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        hidingNavBarManager?.shouldScrollToTop()
        var questViewController = UIViewController()
        let quest = quests![indexPath.row]
        
        if quest.type == 1 {
            questViewController = self.storyboard?.instantiateViewControllerWithIdentifier("QuestionViewController") as! UIViewController
            let questionView = questViewController as! QuestionViewController
            questionView.quest = quest
            
            navigationController?.pushViewController(questViewController, animated: true )
        }
        else if quest.type == 2 {
            questViewController = self.storyboard?.instantiateViewControllerWithIdentifier("QRViewController") as! UIViewController
            let questionView = questViewController as! QRViewController
            questionView.quest = quest
            
            navigationController?.pushViewController(questViewController, animated: true )
        }
        else if quest.type == 3 {
            questViewController = self.storyboard?.instantiateViewControllerWithIdentifier("IBeaconViewController") as! UIViewController
            let questionView = questViewController as! IBeaconViewController
            questionView.quest = quest
            
            navigationController?.pushViewController(questViewController, animated: true )
        }
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
            
            var header: QuestHeaderView?
            
            if kind == UICollectionElementKindSectionHeader {
                header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "QuestHeader", forIndexPath: indexPath) as? QuestHeaderView
            }
            return header!
    }

    
    // MARK: Nav buttons
    
    func infoPressed() {
        performSegueWithIdentifier("showInfo", sender: nil)
    }
    
    func morePressed() {
        let optionMenu = UIAlertController(title: nil, message: "ตัวเลือก", preferredStyle: .ActionSheet)
        
        optionMenu.addAction(UIAlertAction(title: "เริ่มเกมใหม่", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.alertForReset()
        }))
        optionMenu.addAction(UIAlertAction(title: "เกี่ยวกับเรา", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.performSegueWithIdentifier("showAbout", sender: nil)
            
        }))
        optionMenu.addAction(UIAlertAction(title: "ยกเลิก", style: .Cancel, handler: nil))
        
        optionMenu.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        self.presentViewController(optionMenu, animated: true, completion: nil)
    }
    
    
    func alertForReset() {
        
        let title = "กรุณายืนยัน"
        let message = "ต้องการเริ่มเกมใหม่หรือไม่?"
        let cancelButtonTitle = "ยกเลิก"
        let otherButtonTitle = "เริ่มเกมใหม่"
        
        let alertCotroller = DOAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create the actions.
        let cancelAction = DOAlertAction(title: cancelButtonTitle, style: .Cancel) { action in
            NSLog("Cancel.")
        }
        
        let otherAction = DOAlertAction(title: otherButtonTitle, style: .Default) { action in
            self.resetData()
        }
        
        // Add the actions.
        alertCotroller.addAction(cancelAction)
        alertCotroller.addAction(otherAction)
        
        presentViewController(alertCotroller, animated: true, completion: nil)
    }
    
    func resetData() {
        
        DatabaseManager.resetQuest()
        self.configureView()
    }
    
}
