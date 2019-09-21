//
//  AdminReportCellTableViewCell.swift
//  GeoChat
//
//  Created by Joseph Storer on 9/21/19.
//  Copyright © 2019 Joseph Storer. All rights reserved.
//

import UIKit

class AdminReportCellTableViewCell: UITableViewCell {

    
    @IBOutlet weak var handleLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var reportLbl: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
