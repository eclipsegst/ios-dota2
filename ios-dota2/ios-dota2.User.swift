//
//  User.swift
//  ios-dota2
//
//  Created by iOS Students on 5/29/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import Foundation
import CoreData

class User: NSManagedObject {

    @NSManaged var steamid: NSNumber
    @NSManaged var accountid: NSNumber

}
