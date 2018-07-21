//
//  KPBookCategoryCell.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/6/1.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit

class KPBookCategoryCell: UICollectionViewCell {
    
    @IBOutlet weak var imgV: UIImageView!
    
    @IBOutlet weak var categoryName: UILabel!

    @IBOutlet weak var allName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        categoryName.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        categoryName.textColor = UIColor.white.withAlphaComponent(0.9)

    }

}
