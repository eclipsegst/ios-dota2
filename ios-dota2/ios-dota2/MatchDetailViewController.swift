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
    var summaries: [Summary] = [Summary]()
    
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
                            for player in playersRaw {
                                
                            }
                            self.players = Player.playersFromResults(playersRaw)
                            
                            //ToDo:
                            //Getall the summary of all the players
                            
                            for player in self.players {
                                let accountid = player.account_id
                                
                                Dota2Client.sharedInstance().getPlayerSummaries(nil, account_id: accountid) { (result, error) -> Void in
                                    if let summary = result {
                                        println("summary test = \(summary.avatarfull)")
                                        
                                        self.summaries.append(summary)
//                                        if self.summaries.count == self.players.count {
                                            dispatch_async(dispatch_get_main_queue(), {
                                                self.tableView.reloadData()
                                            })
//                                        }
                                        
                                        
                                    }
                                }
                                
                            }

                            
                            
                            
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
                                
                                self.radiantWinLabel.text = "\(radiantWin)"
                                
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
            return "Result: Radiant Win"
        } else {
            return "Result: Dier Win"
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return players.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("PlayerTableViewCell") as! PlayerTableViewCell

        let player = players[indexPath.row]
        
        let accountID = player.account_id
        let heroID = player.hero_id
        let level = player.level
        let kda = player.kda
        
        let item_0 = player.item_0
        let item_1 = player.item_1
        let item_2 = player.item_2
        let item_3 = player.item_3
        let item_4 = player.item_4
        let item_5 = player.item_5
        
        
        
        
        if player.isRadiant() {
            cell.backgroundColor = UIColor.greenColor()
        } else {
            cell.backgroundColor = UIColor.orangeColor()
        }
        
        cell.levelLabel.text = "Lv.\(level)"
        if accountID == 4294967295 {
            cell.playerNameLabel.text = "Anonymous"
        } else {
            var idInt = 76561197960265728 + accountID
            let id = String(idInt)
            for summary in summaries {
                if summary.steamid == String(id) {
                    cell.playerNameLabel.text = summary.personaname
                }
            }
        }
        cell.kdaLabel.text = kda
        
        var heroName = Heroes.heroes[heroID]
        let iconName = "\(heroName!)_sb"
        if  iconName != "_sb" {
            cell.heroImageView.image = UIImage(named: iconName)
        } else {
            cell.heroImageView.image = UIImage(named: "dota2Icon")
        }
        
        if item_0 == 0 {
            cell.item_0ImageView.alpha = 0
        } else {
            var item_0_name = Items.items[item_0]
            let icon_0_name = "\(item_0_name!)_lg"
            cell.item_0ImageView.image = UIImage(named: icon_0_name)
        }
        
        if item_1 == 0 {
            cell.item_1ImageView.alpha = 0
        } else {
            var item_1_name = Items.items[item_1]
            let icon_1_name = "\(item_1_name!)_lg"
            cell.item_1ImageView.image = UIImage(named: icon_1_name)
        }
        
        if item_2 == 0 {
            cell.item_2ImageView.alpha = 0
        } else {
            var item_2_name = Items.items[item_2]
            let icon_2_name = "\(item_2_name!)_lg"
            cell.item_2ImageView.image = UIImage(named: icon_2_name)
        }
        
        if item_3 == 0 {
            cell.item_3ImageView.alpha = 0
        } else {
            var item_3_name = Items.items[item_3]
            let icon_3_name = "\(item_3_name!)_lg"
            cell.item_3ImageView.image = UIImage(named: icon_3_name)
        }
        
        if item_4 == 0 {
            cell.item_4ImageView.alpha = 0
        } else {
            var item_4_name = Items.items[item_4]
            let icon_4_name = "\(item_4_name!)_lg"
            cell.item_4ImageView.image = UIImage(named: icon_4_name)
        }
        
        if item_5 == 0 {
            cell.item_5ImageView.alpha = 0
        } else {
            var item_5_name = Items.items[item_5]
            let icon_5_name = "\(item_5_name!)_lg"
            cell.item_5ImageView.image = UIImage(named: icon_5_name)
        }
        
        
    
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerView = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))
        headerView.backgroundColor = UIColor.blackColor()

        var heroesLabel = UILabel(frame: CGRect(x: 10, y: 0, width: 250, height: 20))
        heroesLabel.text = "Heroes"
        heroesLabel.font = UIFont.boldSystemFontOfSize(12)
//        heroesLabel.textColor = UIColor(red: 8/255.0, green: 64/255.0, blue: 127/255.0, alpha: 1)
        heroesLabel.textColor = UIColor.whiteColor()
        headerView.addSubview(heroesLabel)
        

        var radiant = UIView(frame: CGRect(x: 75, y: 0, width: 20, height: 20))
        radiant.backgroundColor = UIColor.greenColor()
        headerView.addSubview(radiant)

        var radiantLabel = UILabel(frame: CGRect(x: 100, y: 0, width: 250, height: 20))
        radiantLabel.text = "- Radiant"
        radiantLabel.font = UIFont.boldSystemFontOfSize(12)
        radiantLabel.textColor = UIColor.whiteColor()
        headerView.addSubview(radiantLabel)
        
        
        var dier = UIView(frame: CGRect(x: 155, y: 0, width: 20, height: 20))
        dier.backgroundColor = UIColor.orangeColor()
        headerView.addSubview(dier)
        
        var dierLabel = UILabel(frame: CGRect(x: 180, y: 0, width: 250, height: 20))
        dierLabel.text = "- Dier"
        dierLabel.font = UIFont.boldSystemFontOfSize(12)
        dierLabel.textColor = UIColor.whiteColor()
        headerView.addSubview(dierLabel)

        
        
        return headerView
    }

    
}

extension UIColor
{
    convenience init(red: Int, green: Int, blue: Int)
    {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}


