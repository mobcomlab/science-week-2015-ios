//
//  QuestionViewController.swift
//  SciWeek58
//
//  Created by UnRAFE on 06/08/2015.
//  Copyright (c) 2015 Naresuan University. All rights reserved.
//

import UIKit
import RealmSwift
import STZPopupView
import BProgressHUD

class QuestionViewController: UIViewController {

    var quest:Quest?
    
    @IBOutlet var button1:UIButton!
    @IBOutlet var button2:UIButton!
    @IBOutlet var button3:UIButton!
    @IBOutlet var button4:UIButton!
    @IBOutlet var questionLabel:UILabel!
    
    let rightBarItem = UIBarButtonItem()
    var arrayQuestionsGroup:NSArray?
    var arrayChoicesGroup:NSArray?
    var arrayAnswersGroup:NSArray?
    
    var arrUsedQuestion:[Int] = []
    var indexQuestion: NSInteger = 0
    var indexAnswer: NSInteger = 0
    var points: NSInteger = 0
    var record: Bool = false
    var passed: Bool = false
    
    var customAlertController: DOAlertController!
    weak var customAlertAction: DOAlertAction?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = self.quest?.title
        
        clearText()
        self.startQuest()
    }
    
    func startQuest() {
        
        var strQuestion: String = self.quest!.text
        arrayQuestionsGroup = strQuestion.componentsSeparatedByString(":")
        
        var strChoices: String = self.quest!.other
        arrayChoicesGroup = strChoices.componentsSeparatedByString(":")
        
        var strAnswer: String = self.quest!.answer
        arrayAnswersGroup = strAnswer.componentsSeparatedByString(":")
        
        BProgressHUD.showMessageAutoHide(1, msg: "กำลังโหลด") { () -> Void in
            self.randomQuestion()
        }
    }
    
    func randomQuestion () {
        
        indexQuestion = random() % arrayQuestionsGroup!.count
        if arrUsedQuestion.count > 0  {
            while (find(arrUsedQuestion, indexQuestion) != nil){
                indexQuestion = random() % arrayQuestionsGroup!.count
            }
        }
        arrUsedQuestion.append(indexQuestion)
        
        self.updateNumberOfQuestion()
        self.generateQuestion()
        self.randomChoice()
    }
    
    func generateQuestion() {
        questionLabel.text = arrayQuestionsGroup?[indexQuestion] as! String!
    }
    
    func randomChoice() {
        println("choice = \(arrayChoicesGroup?[indexQuestion])")
        
        var arrCurrentTextAnswer = [String]()
        
        var strAnswerUse: String = arrayChoicesGroup![indexQuestion] as! String
        arrCurrentTextAnswer = strAnswerUse.componentsSeparatedByString(",")
        arrCurrentTextAnswer.insert(arrayAnswersGroup![indexQuestion] as! String, atIndex:0)
        
        var arrUsedAnswer : [Int] = []
        var arrTextAnswer = [String]()
        
        let ranAnswer = random() % 4
        arrUsedAnswer.append(ranAnswer)
        
        while true {
            if arrUsedAnswer.count >= 4 {
                break
            }
            let ranAnswer = random() % 4
            if find(arrUsedAnswer, ranAnswer) == nil {
                arrUsedAnswer.append(ranAnswer)
            }
        }
        indexAnswer = arrUsedAnswer[0]
        for i in 0..<4 {
            arrTextAnswer.append(arrCurrentTextAnswer[find(arrUsedAnswer, i)!] as String)
        }
        
        self.button1.setTitle(arrTextAnswer[0], forState: UIControlState.Normal)
        self.button2.setTitle(arrTextAnswer[1], forState: UIControlState.Normal)
        self.button3.setTitle(arrTextAnswer[2], forState: UIControlState.Normal)
        self.button4.setTitle(arrTextAnswer[3], forState: UIControlState.Normal)
        
    }
    
    @IBAction func nextQuestion(sender:UIButton) {
        
        if sender.tag == indexAnswer {
            points++
            println("End Game points= \(points) %")
            self.checkLastQuestion()
        }
        else{
            self.checkLastQuestion()
        }
        
    }
    
    func checkLastQuestion() {
        
        if arrUsedQuestion.count < arrayQuestionsGroup!.count {
            
            self.randomQuestion()
            //self.updateNumberOfQuestion()
        }
        else {
            
            let percentage = (points*100)/arrayQuestionsGroup!.count
            if CGFloat(percentage) >= 50.0 {
                
                //Passed
                passed = true
                self.alertForDone()
            }
            else {
                
                //False
                self.alertForDone()
            }
            println("End Game percen= \(percentage) %")
        }
    }
    
    func updateNumberOfQuestion() {
        rightBarItem.title = "\(arrUsedQuestion.count)/\(arrayQuestionsGroup!.count)"
        rightBarItem.enabled = false
        self.navigationItem.rightBarButtonItem = rightBarItem
    }
    
    func alertForDone() {
        
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
    
    func createPopupview() -> UIView {
        
        let popupView = UIView(frame: CGRectMake(0, 0, 300, 400))
        popupView.backgroundColor = UIColor.whiteColor()
        
        let headView = UIView(frame: CGRectMake(10, 10, 280, 40))
        headView.backgroundColor = Style.ColorMain
        headView.layer.cornerRadius = 4.0
        
        let headLabel = UILabel(frame: CGRectMake(5, 5, 270, 30))
        headLabel.text = "ว๊าววว ได้ตั้ง \(points) ตะแนน"
        headLabel.textColor = UIColor.whiteColor()
        headLabel.font = UIFont.systemFontOfSize(20)
        headLabel.textAlignment = .Center
        
        headView.addSubview(headLabel)
        popupView.addSubview(headView)
        
        let iconView = UIImageView(image: UIImage(named: "AppIcon"))
        iconView.frame = CGRectMake(10, 60, 280, 280)
        popupView.addSubview(iconView)
        
        // Replay button
        let replayButton = UIButton.buttonWithType(.System) as! UIButton
        replayButton.setTitle("เล่นอีกครั้ง", forState: UIControlState.Normal)
        replayButton.frame = CGRectMake(10, 350, 135, 40)
        replayButton.layer.cornerRadius = 4.0
        replayButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        replayButton.backgroundColor = UIColor.redColor()
        replayButton.addTarget(self, action: "replayQuest", forControlEvents: UIControlEvents.TouchUpInside)
        popupView.addSubview(replayButton)
        
        // Close button
        let closeButton = UIButton.buttonWithType(.System) as! UIButton
        closeButton.setTitle("ตกลง", forState: UIControlState.Normal)
        closeButton.frame = CGRectMake(155, 350, 135, 40)
        closeButton.layer.cornerRadius = 4.0
        closeButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        closeButton.backgroundColor = UIColor.grayColor()
        closeButton.addTarget(self, action: "updatePoints", forControlEvents: UIControlEvents.TouchUpInside)
        popupView.addSubview(closeButton)
        
        return popupView
    }
    
    func updatePoints() {
        if passed {
            DatabaseManager.updateCompleteQuest(quest!)
        }
        record = true
        dismissPopupView()
    }
    
    func replayQuest() {
        arrUsedQuestion.removeAll(keepCapacity: false)
        points = 0
        record = false
        passed = false
        self.startQuest()
        dismissPopupView()
    }
    
    func clearText() {
        
        questionLabel.text = "";
        self.button1.setTitle("", forState: UIControlState.Normal)
        self.button2.setTitle("", forState: UIControlState.Normal)
        self.button3.setTitle("", forState: UIControlState.Normal)
        self.button4.setTitle("", forState: UIControlState.Normal)
    }
    
    func done() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }


}
