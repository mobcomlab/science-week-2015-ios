//
//  RealmExtensions.swift
//  ebook
//
//  Created by Ant on 17/06/2015.
//  Copyright (c) 2015 Apptitude. All rights reserved.
//

import RealmSwift

extension Results {
    func ids() -> [AnyObject] {
        var array = [AnyObject]()
        for result in self {
            array.append(result.valueForKey("id")!)
        }
        return array
    }
}
