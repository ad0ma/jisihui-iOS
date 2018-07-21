//
//  KPBookInfoCell.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/27.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit

class KPBookInfoCell: UITableViewCell {
    
    @IBOutlet weak var infoContent: UIView!
    
    @IBOutlet weak var bookImg: UIImageView!

    @IBOutlet weak var bookName: UILabel!
    
    @IBOutlet weak var bookDescription: UILabel!
    
    @IBOutlet weak var authorName: UILabel!
    
    @IBOutlet weak var bookRank: UILabel!
    
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
        
        bookImg.backgroundColor = .random
    }
    
    func disPlay(data: Any?) {
        guard let bookModel = data as? KPBookModel else {
            return
        }
        
        authorName.text = bookModel.author
        bookName.text = bookModel.name
        bookDescription.text = bookModel.content
        
        if let f = bookModel.rank, f > 0 {
            bookRank.text = "豆瓣评分: " + bookModel.doubanScore
        } else {
            bookRank.text = bookModel.doubanScore
        }
        
        bookImg.kf.setImage(with:URL.init(string: bookModel.imgUrl ?? ""), placeholder:UIImage.init(named: "book_default"))
    }

}
