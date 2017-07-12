//
//  UserSearchResultTableViewCell.swift
//  FamilyBudgetApp
//
//  Created by Waqas Hussain on 03/04/2017.
//  Copyright © 2017 Technollage. All rights reserved.
//

import UIKit

class UserSearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var memberType: UILabel!
    @IBOutlet weak var memberTypeBtn: UIButton!
    @IBOutlet weak var RemoveMemberBtn: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
