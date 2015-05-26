//
//  Player.swift
//  ios-dota2
//
//  Created by iOS Students on 5/22/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import Foundation



struct Summary {
    
    var steamid: String? = nil
    var personaname = ""
    var avatarfull = ""
    
    /* Construct a TMDBMovie from a dictionary */
    init(dictionary: [String : AnyObject]) {
        
        steamid = dictionary["steamid"] as? String
        personaname = dictionary["personaname"] as! String
        avatarfull = dictionary["avatarfull"] as! String

    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of TMDBMovie objects */
    static func summaryFromResults(results: [String : AnyObject]) -> Summary {
        var summary = [Summary]()
        
        summary.append(Summary(dictionary: results))
        
        return summary[summary.startIndex]
    }
    
    
    func convertNSDateToString(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        var theDateForamt = NSDateFormatterStyle.MediumStyle
        let theTimeFormat = NSDateFormatterStyle.ShortStyle
        
        dateFormatter.dateStyle = theDateForamt
        dateFormatter.timeStyle = theTimeFormat
        
        return dateFormatter.stringFromDate(date)
    }
}
