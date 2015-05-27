//
//  NewsTableViewController.swift
//  ios-dota2
//
//  Created by iOS Students on 5/20/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import UIKit

class NewsTableViewController: UITableViewController {

   
    
    let BASE_URL = "http://api.steampowered.com/"
    let METHOD_NAME = "ISteamNews/GetNewsForApp/v0002/"
    let APPID = "570" // Dota 2 appid
    let FORMAT = "json"
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    
    var news: [News] = [News]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        session = NSURLSession.sharedSession()

        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        
        let urlString = "http://api.steampowered.com/ISteamNews/GetNewsForApp/v0002/?appid=570&count=30&maxlength=300&format=json"
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
                    if let appnewsDictionary = parsedResult["appnews"] as? NSDictionary {
                        
                        if let newsitems = appnewsDictionary["newsitems"] as? [[String : AnyObject]] {
                            println(newsitems)
                            self.news = News.newsFromResults(newsitems)
                            println(self.news)
                            
                            dispatch_async(dispatch_get_main_queue()) {
                                self.tableView.reloadData()
                            }
                        } else {
                            println("Cannot find key 'newsitems' in \(appnewsDictionary)")
                        }
                    } else {
                        println("Cannot find key 'appnews' in \(parsedResult)")
                    }
                }
            }
        }
        
        task.resume()
        
        let image = UIImage(named: "lina_640x1136")
        let imageView = UIImageView(image: image!)
        self.tableView.backgroundView = imageView
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellResueIdentifier = "NewsTableViewCell"
        let news = self.news[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(cellResueIdentifier) as! NewsTableViewCell


        cell.titleLabel.text = news.title
        let authorName = news.author
        if authorName == "" {
            cell.authorLabel.text = "unknown"
        } else {
            cell.authorLabel.text = news.author
        }
        cell.dateLabel.text = news.date
        
        return cell
    }
}
