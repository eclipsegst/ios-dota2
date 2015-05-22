//
//  SummaryViewController.swift
//  ios-dota2
//
//  Created by iOS Students on 5/20/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import UIKit

class SummaryViewController: UIViewController {
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    @IBOutlet weak var personanameLabel: UILabel!
    
    @IBOutlet weak var realnameLabel: UILabel!
    
    @IBOutlet weak var timecreatedLabel: UILabel!
    
    @IBOutlet weak var avatarImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()

        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        session = NSURLSession.sharedSession()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        // Build the URL
        let urlString = appDelegate.baseURLString + "ISteamUser/GetPlayerSummaries/v0002/?" + "key=" + appDelegate.apiKey + "&steamids=" + "\(appDelegate.steamid)"
        println(urlString)
        
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
                println(parsedResult)
                // Use the data
                if let error = parsingError {
                    println(error)
                } else {
                    if let response = parsedResult["response"] as? NSDictionary{
                        if let playerArray = response["players"] as? NSArray {
                            if let playerInfoDictionary = playerArray[0] as? NSDictionary {
                                println("success")
                                
                                let personaname = playerInfoDictionary["personaname"] as? String
                                let realname = playerInfoDictionary["realname"] as? String
                                
                                var dateAnyObject: AnyObject = playerInfoDictionary["timecreated"]!
                                var timeStamp = NSTimeInterval(dateAnyObject as! NSNumber)
                                let timecreated = self.convertNSDateToString(NSDate(timeIntervalSince1970: timeStamp))
                                
                                let avatarurl = playerInfoDictionary["avatarfull"] as? String
                                println(avatarurl!)
                                let url = NSURL(string: avatarurl!)
                                let data = NSData(contentsOfURL: url!)
                                
                                if let imageData = data {
                                    dispatch_async(dispatch_get_main_queue(), {
                                        self.personanameLabel.text = personaname
                                        self.realnameLabel.text = realname
                                        self.timecreatedLabel.text = timecreated
//                                        self.avatarImageView.image = 
                                        self.avatarImageView.image = UIImage(data: imageData)
                                    })
                                }
                            }
                            
                        }
                        
                    }
                }
            }
        }
        
        // Start the request
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


}
