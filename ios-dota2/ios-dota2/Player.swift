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
    var player_slot = 0
    var kda = ""

    
    /* Construct a TMDBMovie from a dictionary */
    init(dictionary: [String : AnyObject]) {
        
        account_id = dictionary["account_id"] as! Int
        hero_id = dictionary["hero_id"] as! Int
        kills = dictionary["kills"] as! Int
        deaths = dictionary["deaths"] as! Int
        assists = dictionary["assists"] as! Int
        level = dictionary["level"] as! Int
        player_slot = dictionary["player_slot"] as! Int
        kda = "\(kills)/\(deaths)/\(assists)"
        

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
    
    func isRadiant() -> Bool {
        let n = self.player_slot
        let str = String(n, radix: 2).padding(8)
        if str[0] == "0" {
            return true
        } else {
            return false
        }
    }
}


extension String {
    // padding leading 0
    func padding(fieldLength: Int) -> String {
        var formatedString: String = ""
        formatedString += self
        if fieldLength > count(self) {
            for i in 1...(fieldLength - count(self)) {
                formatedString = "0" + formatedString
            }
        }
        
        return formatedString
    }
    
    func padding(fieldLength: Int, paddingChar: String) -> String {
        var formatedString: String = ""
        formatedString += self
        
        for i in 1...(fieldLength - count(self)) {
            formatedString += paddingChar
        }
        
        return formatedString
    }
}

/*
"abcde"[0] === "a"
"abcde"[0...2] === "abc"
"abcde"[2..<4] === "cd"
*/
extension String {
    subscript (i: Int) -> Character {
        return self[advance(self.startIndex, i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: advance(startIndex, r.startIndex), end: advance(startIndex, r.endIndex)))
    }
}
