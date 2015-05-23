//
//  Player.swift
//  ios-dota2
//
//  Created by iOS Students on 5/22/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import Foundation



struct Player {
    
    var account_id = 0
    var hero_id = 0
    var kills = 0
    var deaths = 0
    var assists = 0
    var level = 0
    
//    var startTime: String? = nil
//    var releaseYear: String? = nil
    
    /* Construct a TMDBMovie from a dictionary */
    init(dictionary: [String : AnyObject]) {
        
        account_id = dictionary["account_id"] as! Int
        hero_id = dictionary["hero_id"] as! Int
        kills = dictionary["kills"] as! Int
        deaths = dictionary["deaths"] as! Int
        assists = dictionary["assists"] as! Int
        level = dictionary["level"] as! Int
        
        //        startTime = dictionary[Dota2Client.JSONResponseKeys.StartTime] as? String
        
//        var startTimeAnyObject: AnyObject = dictionary[Dota2Client.JSONResponseKeys.StartTime]!
//        var startTimeStamp = NSTimeInterval(startTimeAnyObject as! NSNumber)
//        startTime = self.convertNSDateToString(NSDate(timeIntervalSince1970: startTimeStamp))
        
        //        if let releaseDateString = dictionary[TMDBClient.JSONResponseKeys.MovieReleaseDate] as? String {
        //
        //            if releaseDateString.isEmpty == false {
        //                releaseYear = releaseDateString.substringToIndex(advance(releaseDateString.startIndex, 4))
        //            } else {
        //                releaseYear = ""
        //            }
        //        }
    }
    
    /* Helper: Given an array of dictionaries, convert them to an array of TMDBMovie objects */
    static func playersFromResults(results: [[String : AnyObject]]) -> [Player] {
        var players = [Player]()
        
        for result in results {
            players.append(Player(dictionary: result))
        }
        
        return players
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