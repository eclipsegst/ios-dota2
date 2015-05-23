//
//  MatchDetailViewController.swift
//  ios-dota2
//
//  Created by iOS Students on 5/22/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import UIKit

class MatchDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{

    var match: Match?
    var players: [Player] = [Player]()
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var matchidLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var firstBloodTimeLabel: UILabel!
    @IBOutlet weak var radiantWinLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        session = NSURLSession.sharedSession()
        
        tableView.delegate = self
        tableView.dataSource = self

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        println(match!.matchID)
        
        let parameters = [Dota2Client.ParameterKeys.MatchID : match!.matchID]
        var mutableMethod : String = Dota2Client.Methods.GetMatchDetails

        
        let urlString = Dota2Client.Constants.BaseURL + mutableMethod + Dota2Client.escapedParameters(parameters) + "&key=" + Dota2Client.Constants.ApiKey
        let url = NSURL(string: urlString)!
        
        let request = NSURLRequest(URL: url)
        println("url = \(url)")
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                println("Could not complete the request \(error)")
            } else {
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                if let error = parsingError {
                    println(error)
                } else {
                    if let result = parsedResult["result"] as? NSDictionary {
                        
                        println(result["radiant_win"])
                        
                        if let playersRaw = result["players"] as? [[String : AnyObject]] {
                            
                            self.players = Player.playersFromResults(playersRaw)
                            

                            dispatch_async(dispatch_get_main_queue()) {

                                let matchid = result["match_id"] as! Int
                                println(matchid)
                                self.matchidLabel!.text = "Match ID: " + String(matchid)
                                
                                
                                var startTimeAnyObject: AnyObject = result["start_time"]!
                                var starttimeStamp = NSTimeInterval(startTimeAnyObject as! NSNumber)
                                let starttime = self.convertNSDateToString(NSDate(timeIntervalSince1970: starttimeStamp))
                                
                                self.startTimeLabel.text = "Date: " + starttime
                                
                                var durationAnyObject = result["duration"] as? Double
                                println(durationAnyObject)
                                let duration = self.secondsToString(durationAnyObject!)
                                self.durationLabel!.text = "Duration: " + duration
                                
                                var firstBloodDouble = result["first_blood_time"] as? Double
                                let firstBlood = self.secondsToString(firstBloodDouble!)
                                self.firstBloodTimeLabel.text = "First Blood: " + firstBlood
                                
                                var radiantWinBool = result["radiant_win"] as? Int
                                let radiantWin = self.convertWin(radiantWinBool!)
                                
                                self.radiantWinLabel.text = "Result: " + "\(radiantWin)"
                                
                                self.tableView.reloadData()
                            }
                        } else {
                            println("Cannot find key 'players' in \(result)")
                        }
                    } else {
                        println("Cannot find key 'result' in \(parsedResult)")
                    }
                }
            }
        }
        
        task.resume()
        
        
    }
    
    func convertNSDateToString(date: NSDate) -> String {
        let dateFormatter = NSDateFormatter()
        var theDateForamt = NSDateFormatterStyle.MediumStyle
        let theTimeFormat = NSDateFormatterStyle.ShortStyle
        
        dateFormatter.dateStyle = theDateForamt
        dateFormatter.timeStyle = theTimeFormat
        
        return dateFormatter.stringFromDate(date)
    }
    
    func secondsToString(seconds: Double) -> String {
        var sec = seconds % 60
        var min = (seconds/60) % 60
        var hours = (seconds / 3600)
        
        return String(format: "%d h, %d m, %d s", Int(hours), Int(min), Int(sec))
    }
    
    func convertWin(m: Int) -> String {
        if m == 1 {
            return "Win"
        } else {
            return "Lose"
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return players.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PlayerTableViewCell", forIndexPath: indexPath) as! UITableViewCell
        

        let player = players[indexPath.row]
        let accountID = player.account_id
        let hereoID = player.hero_id
        cell.textLabel?.text = "Account ID: \(accountID)"
        cell.detailTextLabel!.text = "Hero ID: \(player.hero_id)"
        
        return cell
    }

    

}
