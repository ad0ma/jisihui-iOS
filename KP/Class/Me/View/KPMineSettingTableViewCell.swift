//
//  KPMineSettingTableViewCell.swift
//  KP
//
//  Created by Shawley on 17/03/2018.
//  Copyright © 2018 adoma. All rights reserved.
//

import UIKit

class KPMineSettingTableViewCell: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var arrow: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
