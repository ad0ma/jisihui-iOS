//
//  KPBookInfoNoDetailCell.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/6/3.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit

class KPBookInfoNoDetailCell: UITableViewCell {
    
    @IBOutlet weak var infoContent: UIView!
    
    @IBOutlet weak var bookImgV: UIImageView!

    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var author: UILabel!
    
    @IBOutlet weak var rank: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        //        infoContent.layer.borderWidth = 0.5
        //        infoContent.layer.borderColor = Border_Color.cgColor
        infoContent.layer.shadowColor = UIColor.darkGray.cgColor
        infoContent.layer.shadowOffset = CGSize.init(width: 0, height: 1)
        infoContent.layer.shadowOpacity = 0.5
        infoContent.layer.shadowRadius = 3
        
        bookImgV.backgroundColor = .random
    }

    func disPlay(data: Any?) {
        guard let bookModel = data as? KPBookModel else {
            return
        }
        
        author.text = bookModel.author
        name.text = bookModel.name
        if let f = bookModel.rank, f > 0 {
            rank.text = "豆瓣评分: " + bookModel.doubanScore
        } else {
            rank.text = bookModel.doubanScore
        }
        bookImgV.kf.setImage(with:URL.init(string: bookModel.imgUrl ?? ""), placeholder:UIImage.init(named: "book_default"))
    }

    
}
