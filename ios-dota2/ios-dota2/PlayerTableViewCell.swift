//
//  NewsTableViewCell.swift
//  ios-dota2
//
//  Created by iOS Students on 5/20/15.
//  Copyright (c) 2015 Zhaolong Zhong. All rights reserved.
//

import UIKit

class PlayerTableViewCell: UITableViewCell {

//    @IBOutlet weak var heroImageView: UIImageView!
//    @IBOutlet weak var levelLabel: UILabel!
//    @IBOutlet weak var playernameLabel: UILabel!
//    @IBOutlet weak var kdaLabel: UILabel!
    
    @IBOutlet weak var heroImageView: UIImageView!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var kdaLabel: UILabel!
    
    @IBOutlet weak var item_0ImageView: UIImageView!
    
    @IBOutlet weak var item_1ImageView: UIImageView!
    @IBOutlet weak var item_2ImageView: UIImageView!
    @IBOutlet weak var item_3ImageView: UIImageView!
    @IBOutlet weak var item_4ImageView: UIImageView!
    @IBOutlet weak var item_5ImageView: UIImageView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
