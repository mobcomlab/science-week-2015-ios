//
//  QuestCell.swift
//  SciWeek58
//
//  Created by UnRAFE on 28/07/2015.
//  Copyright (c) 2015 Naresuan University. All rights reserved.
//

import UIKit

class QuestCell: UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var circleView: UIView!
    @IBOutlet var questImage: UIImageView!
    @IBOutlet var passedImage: UIImageView!
    
    func setGrid(quest: Quest) {
        
        if Style.DeviceType.IS_IPAD {
            self.backgroundColor = UIColor.clearColor()
            titleLabel.font = UIFont.systemFontOfSize(30)
        }
        questImage.image = UIImage(named: quest.icon)
        circleView.backgroundColor = UIColor(rgba: quest.color)
        passedImage.hidden = true
        if quest.status > 0 {
           passedImage.hidden = false
        }
        titleLabel.text = quest.title
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
}
