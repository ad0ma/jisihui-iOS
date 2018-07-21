//
//  KPBookInfoHeaderView.swift
//  KP
//
//  Created by Shawley on 2018/4/7.
//  Copyright © 2018 adoma. All rights reserved.
//

import UIKit

class KPBookInfoHeaderView: UICollectionReusableView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var changeGuessBooksView: UIView!
    @IBOutlet weak var refreshBtn: UIButton!
    @IBOutlet weak var refreshLabel: UILabel!
    
    typealias CallBack = () -> ()
    
    var changeNext: CallBack?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        refreshLabel.textColor = Main_Theme_Color
    }
    
    @IBAction func changeGuessBooksBtnTapped(_ sender: Any) {
        changeNext?()
    }
}
