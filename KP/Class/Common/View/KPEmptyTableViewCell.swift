//
//  KPEmptyTableViewCell.swift
//  KP
//
//  Created by Adoma on 2018/4/23.
//  Copyright © 2018年 adoma. All rights reserved.
//

import UIKit

class KPEmptyTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tipLabel: UILabel!
    
    var tipText: String? {
        didSet {
            self.tipLabel.text = tipText
        }
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
