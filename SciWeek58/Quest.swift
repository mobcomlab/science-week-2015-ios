//
//  Quests.swift
//  SciWeek58
//
//  Created by UnRAFE on 29/07/2015.
//  Copyright (c) 2015 Naresuan University. All rights reserved.
//

import RealmSwift

class Quest: Object {
    
    dynamic var id = 0
    dynamic var type = 0
    dynamic var text = ""
    dynamic var answer = ""
    dynamic var other = ""
    dynamic var title = ""
    dynamic var icon = ""
    dynamic var color = ""
    dynamic var status = 0
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}