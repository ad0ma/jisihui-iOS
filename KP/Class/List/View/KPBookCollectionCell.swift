//
//  KPBookCollectionCell.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/29.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit

class KPBookCollectionCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    
    @IBOutlet weak var detail: UILabel!

    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var imgV: UIImageView!
    
    @IBOutlet weak var backV: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgV.backgroundColor = .random
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
//        backV.layer.borderWidth = 0.5
//        backV.layer.borderColor = Border_Color.cgColor
        backV.layer.shadowColor = UIColor.darkGray.cgColor
        backV.layer.shadowOffset = CGSize.init(width: 0, height: 1)
        backV.layer.shadowOpacity = 0.5
        backV.layer.shadowRadius = 3
    }

    func disPlay(data: Any?) {
        guard let listModel = data as? KPListModel else {
            return
        }
        
        time.text = listModel.authorName + "   " + listModel.dateText
        title.text = listModel.title
        detail.text = listModel.content
        imgV.kf.setImage(with:URL.init(string: listModel.imgUrl), placeholder:UIImage.init(named: "book_default"))
    }
    
}
