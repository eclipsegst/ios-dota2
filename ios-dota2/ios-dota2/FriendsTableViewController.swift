//
//  FriendsTableViewController.swift
//  ios-dota2
//
//  Created by iOS Students on 5/20/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import UIKit

class FriendsTableViewController: UITableViewController {
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    var friends: [Friend] = [Friend]()
    var tupleArray:[(String, String, String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        session = NSURLSession.sharedSession()
        
    }

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
        self.tableView.reloadData()
        
        
        let urlString = "http://api.steampowered.com/ISteamUser/GetFriendList/v0001/?key=" + appDelegate.apiKey + "&steamid=" + appDelegate.steamid + "&relationship=friend"
        let url = NSURL(string: urlString)!
        
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            
            if let error = downloadError {
                println("Could not complete the request \(error)")
            } else {
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                if let error = parsingError {
                    println(error)
                } else {
                    if let friendsDictionary = parsedResult["friendslist"] as? NSDictionary {
                        
                        if let friends = friendsDictionary["friends"] as? [[String : AnyObject]] {
                            
                            println(friends)
                            
                            self.friends = Friend.friendsFromResults(friends)
                            println("self.friends= \(self.friends)")
                            
                            for item in self.friends {
                                var (t0, t1) = self.getUserSummary(item.steamid)
                                println("t0 == \(t0)")
                            }
                            
                            
                        } else {
                            println("Cannot find key 'Friendsitems' in \(friendsDictionary)")
                        }
                    } else {
                        println("Cannot find key 'appFriends' in \(parsedResult)")
                    }
                }
            }
        }
        
        task.resume()
        
        let image = UIImage(named: "mirana_640x1136")
        let imageView = UIImageView(image: image!)
        self.tableView.backgroundView = imageView
    }
    
    
    
    func getUserSummary(steamid: String) ->(personaName: String, avatarUrl: String) {
        
        println("getUserSummary.......")
        
        var tupleResults = ("0", "0")
        
        var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        var session = NSURLSession.sharedSession()
        
        let urlString = appDelegate.baseURLString + "ISteamUser/GetPlayerSummaries/v0002/?" + "key=" + appDelegate.apiKey + "&steamids=" + "\(steamid)"
        // Debug
        //        println(urlString)
        
        let url = NSURL(string: urlString)!
        // Configure the request
        let request = NSMutableURLRequest(URL: url)
        
        // Make the request
        let task = session.dataTaskWithRequest(request) { data, response, downloadError in
            if let error = downloadError {
                println("Could not complete the request \(error)")
            } else {
                
                // Parse the data
                var parsingError: NSError? = nil
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError) as! NSDictionary
                
                // Debug
                //                println(parsedResult)
                // Use the data
                if let error = parsingError {
                    println(error)
                } else {
                    if let response = parsedResult["response"] as? NSDictionary{
                        if let playerArray = response["players"] as? NSArray {
                            if playerArray.count>0 {
                                if let playerInfoDictionary = playerArray[0] as? NSDictionary {
                                    
                                    
                                    
                                    let personaname = playerInfoDictionary["personaname"] as? String
                                    let realname = playerInfoDictionary["realname"] as? String
                                    
                                    //                                    let dateAnyObject: AnyObject? = playerInfoDictionary["timecreated"]
                                    //                                    var timeStamp = NSTimeInterval(dateAnyObject as! NSNumber)
                                    //                                    let timecreated = self.convertNSDateToString(NSDate(timeIntervalSince1970: timeStamp))
                                    
                                    let avatarurl = playerInfoDictionary["avatarfull"] as? String
                                    println(avatarurl!)
                                    println(personaname!)
                                    
                                    
                                    dispatch_async(dispatch_get_main_queue(),{
                                        self.tupleArray.append(avatarurl!, personaname!, steamid)
                                        dispatch_async(dispatch_get_main_queue()) {
                                            self.tableView.reloadData()
                                            
                                            println("tupleArray = \(self.tupleArray)")
                                        }
                                    })
                                    
                                } else {
                                    println("Could not get the palyer array in index 0 in \(playerArray)")
                                }
                                
                            } else {
                                println("Could not parse 'players' in \(response)")
                            }
                        }
                        
                    } else {
                        println("Could not parse 'response' in \(parsedResult)")
                    }
                }
            }
        }
        
        // Start the request
        task.resume()
        
        return tupleResults
    }


    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friends.count
    }


    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendTableViewCell", forIndexPath: indexPath) as! UITableViewCell

        let friend = self.friends[indexPath.row]
        
        for item in tupleArray {
            if item.2 == friend.steamid {
                cell.textLabel!.text = item.1
                let urlString = item.0
                println("item0 = \(urlString)")
                let url = NSURL(string: urlString)
////                println(url)
                let imageData = NSData(contentsOfURL: url!)
                cell.imageView!.image = UIImage(data: imageData!)
            }
        }
        
        cell.detailTextLabel?.text = friend.friend_since
        
        

        return cell
    }





}

struct Friend {
    var personaname = ""
    var friend_since = ""
    var avatarfull = ""
    var steamid = ""
    
    init(dictionary: [String : AnyObject]) {
        
        steamid = dictionary["steamid"] as! String
        
        var dateAnyObject: AnyObject = dictionary["friend_since"]!
        var timeStamp = NSTimeInterval(dateAnyObject as! NSNumber)
        friend_since = convertNSDateToString(NSDate(timeIntervalSince1970: timeStamp))
        
    }
    
    static func friendsFromResults(results: [[String : AnyObject]]) -> [Friend] {
        var friends = [Friend]()
        
        for result in results {
            friends.append(Friend(dictionary: result))
        }
        
        return friends
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
