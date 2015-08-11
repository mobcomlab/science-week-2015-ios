//
//  WebServiceManager.swift
//  SciWeek58
//
//  Created by UnRAFE on 28/07/2015.
//  Copyright (c) 2015 Naresuan University. All rights reserved.
//

import Alamofire
import RealmSwift

class WebServiceManager {
    
    //static let baseURLString = "http://sciweek.mobcomlab.com/"
    //static let baseURLString = "http://localhost:8888/"
    static let baseURLString = "http://10.31.26.37:8888/"
    
    static let baseURLStringWithAPI = "\(baseURLString)api/"
    
    static func requestQuests(completion: ((NSError?) -> ())) {
        
        Alamofire.request(.GET, baseURLStringWithAPI+"quests", parameters: nil).responseJSON() {
            (_, _, json, error) in
            
            //println(json?.objectForKey("data"))
            if error != nil {
                completion(error)
                return
            }

            
            let quests = ((json as! NSDictionary).valueForKey("data") as! [NSDictionary])
            let realm = Realm()
            realm.write {
                for quest in quests {
                    realm.create(Quest.self, value: quest, update: true)
                }
            }
            completion(nil)

        }
    }
    
    
    
}