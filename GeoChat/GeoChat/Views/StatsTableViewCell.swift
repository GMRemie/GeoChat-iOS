//
//  StatsTableViewCell.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/20/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit

class StatsTableViewCell: UITableViewCell {


    
    @IBOutlet weak var imagesView: UIImageView!
    @IBOutlet weak var datePosted: UILabel!
    @IBOutlet weak var expirationType: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var discoveries: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
