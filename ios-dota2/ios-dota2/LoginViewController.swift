//
//  LoginViewController.swift
//  ios-dota2
//
//  Created by iOS Students on 5/29/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {

    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    @IBOutlet weak var idTextField: UITextField!
    @IBOutlet weak var statusLabel: UILabel!
    
    var appDelegate: AppDelegate!
    var session: NSURLSession!
    var accountid: Int32 = 0
    var steamid: Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get the app delegate
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // Get the shared URL session
        session = NSURLSession.sharedSession()
    }
    
    override func viewWillAppear(animated: Bool) {

        // Preload the account id and steam id
        if checkUserExist() {
//            statusLabel.text = "There is one user: \(appDelegate.steamid)"
        } else {
//            statusLabel.text = "There is no any user in this device"
        }

    }
    
    override func viewDidAppear(animated: Bool) {
        if checkUserExist() {
            completeLogin()
//            statusLabel.text = "There is  one user in this device"
        } else {
            println("There is no user info")
//            statusLabel.text = "There is no any user in this device"
        }

    }
    
    @IBAction func loginButtonTouchUp(sender: AnyObject) {
        println("start login")
        if let id = idTextField.text.toInt() {
            println("convert success \(id)")
            
            if id >= 76561197960265728 {
                println("using steamid")
                steamid = Int64(id)
                accountid = Int32(id - 76561197960265728)
            } else {
                println("using accountid")
                accountid = Int32(id)
                steamid = id + 76561197960265728
            }
            
            saveData(steamid, accountid: accountid)
        } else {
            statusLabel.text = "Incorrect steam id or account id format."
        }
        
        
        
        println("steamid = \(steamid)")
        println("accountid = \(accountid)")

    }
    
    func saveData(steamid: Int64, accountid: Int32) {
        
        let entityDescription =
        NSEntityDescription.entityForName("User", inManagedObjectContext: managedObjectContext!)

        let user = User(entity: entityDescription!, insertIntoManagedObjectContext: managedObjectContext)
        user.accountid = NSNumber(int: accountid)
        user.steamid = NSNumber(longLong: steamid)

        var error: NSError?

        managedObjectContext?.save(&error)

        if let error = error {
            println(error.localizedFailureReason)
        } else {
            println("save account and steam id core data success")
        }


        appDelegate.accountid = "\(accountid)"
        appDelegate.steamid = "\(steamid)"
        
        if checkUserExist() {
            completeLogin()
        } else {
            completeLogin()
        }
        println("login success")
    }
    
    func checkUserExist() -> Bool {
        let entityDescription =
        NSEntityDescription.entityForName("User", inManagedObjectContext: managedObjectContext!)
        
        var error: NSError?
        
        
        let request = NSFetchRequest()
        request.entity = entityDescription
        
        var objects = managedObjectContext?.executeFetchRequest(request, error: &error)
        
        if let results = objects {
            if results.count > 0 {
                let match = results[0] as! NSManagedObject
                if let tempAccountID: AnyObject = match.valueForKey("accountid") {
                    appDelegate.accountid = "\(tempAccountID)"
                }
                
                if let tempSteamID: AnyObject? = match.valueForKey("steamid") {
                    appDelegate.steamid = "\(tempSteamID!)"
                }
                
                return true

            } else {
                return false
            }
        } else {
            return false
        }

    }
    

    func completeLogin() {
        let controller = self.storyboard!.instantiateViewControllerWithIdentifier("MainTabBarController") as! MainTabBarController
        self.presentViewController(controller, animated: true, completion: nil)

    }

}
