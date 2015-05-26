//
//  Dota2Client.swift
//  ios-dota2
//
//  Created by iOS Students on 5/22/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import Foundation

class Dota2Client : NSObject {
    
    // Shared session
    var session: NSURLSession
    
    var accountID : String? = nil
   // accountID = "137156691"
    
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    
    // MARK: - GET
    func taskForGETMethod(method: String, parameters: [String: AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // 1. Set the parameters
        var mutableParameters = parameters
        mutableParameters[ParameterKeys.ApiKey] = Constants.ApiKey
        
        // 2 & 3 Build the URL and configure the request
        let urlString = Constants.BaseURL + method + Dota2Client.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        println("url = \(url)")
        let request = NSURLRequest(URL: url)
        
        println("start make request")
        
        // 4. Make the request
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            // 5 & 6 Parse the data and use the data
            if let error = downloadError {
                let newError = Dota2Client.errorForData(data, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
                println("there is an error before parse json")
            } else {
                println("start parse json")
                Dota2Client.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        // 7. Start the request
        task.resume()
        return task
    }
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given a response with error, see if a status is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        if let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as? [String : AnyObject] {
            
            if let errorMessage = parsedResult[Dota2Client.JSONResponseKeys.StatusMessage] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                return NSError(domain: "Dota2 Client Error", code: 1, userInfo: userInfo)
            }
        }
        
        return error
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        
//        println("parsedResult = \(parsedResult)")
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + join("&", urlVars)
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> Dota2Client {
        
        struct Singleton {
            static var sharedInstance = Dota2Client()
        }
        
        return Singleton.sharedInstance
    }
    
    // MARK: - Get match history
    func getMatchHistory(completionHandler: (result: [Match]?, error: NSError?) -> Void) {
        println("start getMatchHistory")
        // 1. Set the parameters, method
//        let parameters = [Dota2Client.ParameterKeys: Dota2Client.Constants.ApiKey!]
        let parameters = [Dota2Client.ParameterKeys.AccountID : Constants.AccountID]
        var mutableMethod : String = Methods.GetMatchHistory
        
        println("parameters = \(parameters)")
        println("mutableMethod = \(mutableMethod)")
            
//        mutableMethod = Dota2Client.subtitudeKeyInMethod(mutableMethod, key: Dota2Client.ParameterKeys.AccountID, value:Dota2Client.Constants.AccountID)
        
        taskForGETMethod(mutableMethod, parameters: parameters) {JSONResult, error in
            
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                println("get JSONResult success")
//                println("JSONResult = \(JSONResult)")
                if let result = JSONResult.valueForKey("result") as? [String : AnyObject] {
//                    println("results = \(result)")
                    if let matchesRaw = result["matches"] as? [[String : AnyObject]] {
//                        println("matchesRaw = \(matchesRaw)")
                        var matches = Match.matchesFromResults(matchesRaw)
//                        println("matches  = \(matches)")
                        completionHandler(result: matches, error: nil)
                    }
                    
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getMatchHistory parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getMatchHistory"]))
                }
            }
        }
    }
    
    // MARK: - Get player summaries
    func getPlayerSummaries(steamidInt: Int?, account_id: Int?, completionHandler: (result: Summary?, error: NSError?) -> Void) {
        println("start getPlayerSummaries")
        // 1. Set the parameters, method
        //        let parameters = [Dota2Client.ParameterKeys: Dota2Client.Constants.ApiKey!]
        var steamid = ""
        
        if steamidInt == nil {
            var id = 76561197960265728 + account_id!
            steamid = String(id)
        } else {
            steamid = "\(steamidInt)"
        }
        
        let parameters = [Dota2Client.ParameterKeys.SteamID : steamid]

        
        var mutableMethod : String = Methods.GetPlayerSummaries
        
        println("parameters = \(parameters)")
        println("mutableMethod = \(mutableMethod)")
        

        taskForGETMethod(mutableMethod, parameters: parameters) {JSONResult, error in
            
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                println("get JSONResult success")
                println("JSONResult = \(JSONResult)")
                if let response = JSONResult.valueForKey("response") as? [String : AnyObject] {
                    println("response = \(response)")
                    if let playerArray = response["players"] as? NSArray {
                        if playerArray.count > 0 {
                            if let playerInfoDictionary = playerArray[0] as? [String : AnyObject] {
                                println("playerInfoDictionary = \(playerInfoDictionary)")
                                var summary = Summary.summaryFromResults(playerInfoDictionary)
                                completionHandler(result: summary, error: nil)
                            }
                        } else {
                            println("PlayerArray count is 0")
                        }
                    }
                } else {
                    completionHandler(result: nil, error: NSError(domain: "getMatchHistory parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getMatchHistory"]))
                }
            }
        }
    }

}


extension Dota2Client {
    
    // MARK: - Constatns
    struct Constants {
        
        // MARK: API Key
        static let ApiKey : String = ""
        static let AccountID: String = ""
        static let SteamID: String = ""
        
        // MARK: URLs
        static let BaseURL : String = "http://api.steampowered.com/"
        static let BaseDota2URL : String = "http://api.steampowered.com/IDOTA2Match_570/"
    }
    
    // MARK: - Methods
    struct Methods {
     
        // MARK: Summary
        static let GetPlayerSummaries = "ISteamUser/GetPlayerSummaries/v0002/"
        
        static let GetFriendList = "ISteamUser/GetFriendList/v0001/"
        
        static let GetMatchHistory = "IDOTA2Match_570/GetMatchHistory/v1/"
        
        static let GetMatchDetails = "IDOTA2Match_570/GetMatchDetails/v1/"
    }
    
    // MARK: - URL Keys
    struct ParameterKeys {
        
        static let SteamID = "steamids"
        static let ApiKey = "key"
        
        static let AccountID = "account_id"
        static let MatchID = "match_id"
        
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: - General
        static let StatusMessage = "status"
        
        // MARK: - Summary
        
        
        // MARK: - Match
        
        static let Result = "result"
        static let Matches = "matches"
        static let MatchID = "match_id"
        static let StartTime = "start_time"
        
        static let HeroID = "hero_id"
        
        
        
    }
    

}