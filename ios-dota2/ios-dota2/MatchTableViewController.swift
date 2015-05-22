//
//  MatchTableViewController.swift
//  ios-dota2
//
//  Created by iOS Students on 5/22/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import UIKit

class MatchTableViewController: UITableViewController {

    
    @IBOutlet var matchesTableView: UITableView!
    
    var matches: [Match] = [Match]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        println("start call dota2client")
        
        Dota2Client.sharedInstance().getMatchHistory { matches, error in
        
            if let matches = matches {
                self.matches = matches
                println("self.matches = \(matches)")
                dispatch_async(dispatch_get_main_queue()){
                    self.matchesTableView.reloadData()
                }
            } else {
                println(error)
            }
        }
    }
    

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return matches.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellReuseIdentifier = "MatchTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier) as! UITableViewCell
        println("matches_count = \(matches.count)")
        let match = matches[indexPath.row]
        println("matchID = \(match.startTime!)")
        cell.textLabel!.text = "Match ID: " + "\(match.matchID)"
        cell.detailTextLabel!.text = "Date : \(match.startTime!)"

        return cell
    }

    
}
