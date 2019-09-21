//
//  UserResultTableViewCell.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/20/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit

class UserResultTableViewCell: UITableViewCell {

    
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var handleLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
