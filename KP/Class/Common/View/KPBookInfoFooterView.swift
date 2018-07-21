//
//  KPBookInfoFooterView.swift
//  KP
//
//  Created by Shawley on 2018/4/7.
//  Copyright © 2018 adoma. All rights reserved.
//

import UIKit

class KPBookInfoFooterView: UICollectionReusableView {
    
    typealias CallBack = (UIButton) -> ()
    
    @IBOutlet weak var readAllBtn: UIButton!
    var readAllAction: CallBack?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        readAllBtn.layer.borderColor = Main_Theme_Color.cgColor
        readAllBtn.layer.borderWidth = 1
        readAllBtn.layer.cornerRadius = 5.0
        readAllBtn.layer.masksToBounds = true
        readAllBtn.setTitleColor(Main_Theme_Color, for: .normal)
    }
    
    @IBAction func readAllBtnTapped(_ sender: UIButton) {
        readAllAction?(sender)
    }
}
