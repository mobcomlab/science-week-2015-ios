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
        
        circleView.backgroundColor = Style.ColorBlue
        switch (quest.type) {
            case 1 :circleView.backgroundColor = Style.ColorGray
                    break
            case 2 :circleView.backgroundColor = Style.ColorGreen
                    break
            case 3 :circleView.backgroundColor = Style.ColorBlue
                    break
            default : break
        }
        
        passedImage.hidden = true
        if quest.status > 0 {
           passedImage.hidden = false
        }
        
        titleLabel.text = quest.title
        //titleLabel.text = String(quest.type)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    
}
