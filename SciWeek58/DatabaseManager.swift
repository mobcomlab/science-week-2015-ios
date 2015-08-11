//
//  DatabaseManager.swift
//  SciWeek58
//
//  Created by UnRAFE on 29/07/2015.
//  Copyright (c) 2015 Naresuan University. All rights reserved.
//

import RealmSwift

class DatabaseManager {
    
    static func quests()->Results<Quest>{
        return Realm().objects(Quest).sorted("id", ascending: true)
    }
    
    static func updateCompleteQuest(quest : Quest) {
        
        let realm = Realm()
        realm.write {
            quest.status = 1
        }
    }
    
    static func resetQuest() {
        
        let realm = Realm()
        let quests = realm.objects(Quest)
        realm.write { () -> Void in
            for quest in quests {
                quest.status = 0
            }
        }
    }
}
