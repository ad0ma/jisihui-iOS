//
//  KPMineCollectionViewCell.swift
//  KP
//
//  Created by Shawley on 12/03/2018.
//  Copyright © 2018 adoma. All rights reserved.
//

import UIKit

class KPMineBaseCell: UICollectionViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class KPMineCollectionViewCell: KPMineBaseCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
