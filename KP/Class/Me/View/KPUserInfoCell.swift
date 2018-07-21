//
//  KPUserInfoCell.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/6/5.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit

class KPUserInfoCell: UITableViewCell {
    
    
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var info: UILabel!
    
    @IBOutlet weak var rightImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    
}
