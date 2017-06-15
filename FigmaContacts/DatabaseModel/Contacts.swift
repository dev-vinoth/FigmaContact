//
//  Contacts.swift
//  FigmaContacts
//
//  Created by Vinoth on 6/13/17.
//  Copyright © 2017 Kovan. All rights reserved.
//

import Foundation
import RealmSwift

class Contacts: Object {
    
    dynamic var id      = ""
    dynamic var name    = ""
    dynamic var phone   = ""
    dynamic var email   = ""
    dynamic var country = ""
    dynamic var imgData = NSData()
    dynamic var isFavorite = false
    
    override class func primaryKey() -> String? {
        return "id"
    }
}

func autoMd5Id() -> String {
    
    let time = NSDate()
    let timeInterval = String(time.timeIntervalSince1970)
    //print("Time interval" , timeInterval)
    return timeInterval
}

