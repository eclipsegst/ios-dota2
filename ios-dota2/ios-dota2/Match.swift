//
//  Match.swift
//  ios-dota2
//
//  Created by iOS Students on 5/22/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import Foundation

struct Match {
    
    var matchID = 0
    var startTime: String? = nil
    var releaseYear: String? = nil
    
    /* Construct a TMDBMovie from a dictionary */
    init(dictionary: [String : AnyObject]) {
        
        matchID = dictionary[Dota2Client.JSONResponseKeys.MatchID] as! Int
//        startTime = dictionary[Dota2Client.JSONResponseKeys.StartTime] as? String
        
        var startTimeAnyObject: AnyObject = dictionary[Dota2Client.JSONResponseKeys.StartTime]!
        var startTimeStamp = NSTimeInterval(startTimeAnyObject as! NSNumber)
        startTime = self.convertNSDateToString(NSDate(timeIntervalSince1970: startTimeStamp))
        
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
    static func matchesFromResults(results: [[String : AnyObject]]) -> [Match] {
        var matches = [Match]()
        
        for result in results {
            matches.append(Match(dictionary: result))
        }
        
        return matches
    }
    
    
    func convertNSDateToString(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        var theDateForamt = NSDateFormatterStyle.MediumStyle
        let theTimeFormat = NSDateFormatterStyle.ShortStyle
        
        dateFormatter.dateStyle = theDateForamt
        dateFormatter.timeStyle = theTimeFormat
        
        return dateFormatter.stringFromDate(date)
    }}