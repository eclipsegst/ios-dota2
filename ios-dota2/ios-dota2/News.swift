//
//  Player.swift
//  ios-dota2
//
//  Created by iOS Students on 5/22/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import Foundation

struct News {
    var title = ""
    var author = ""
    var gid = ""
    var date = ""
    
    init(dictionary: [String : AnyObject]) {
        title = dictionary["title"] as! String
        author = dictionary["author"] as! String
        gid = dictionary["gid"] as! String
        
        var dateAnyObject: AnyObject = dictionary["date"]!
        var timeStamp = NSTimeInterval(dateAnyObject as! NSNumber)
        date = convertNSDateToString(NSDate(timeIntervalSince1970: timeStamp))
        
        
    }
    
    static func newsFromResults(results: [[String : AnyObject]]) -> [News] {
        var news = [News]()
        
        for result in results {
            news.append(News(dictionary: result))
        }
        
        return news
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
