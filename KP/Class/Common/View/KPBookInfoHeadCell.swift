//
//  KPBookInfoHeadCell.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/31.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit

class KPBookInfoHeadCell: UITableViewCell {
    
    @IBOutlet weak var bookImgV: UIImageView!
    
    @IBOutlet weak var bookName: UILabel!

    @IBOutlet weak var authorName: UILabel!
    
    @IBOutlet weak var rank: UILabel!
    
    @IBOutlet weak var rating: RatingBar!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func disPlay(data: Any?) {
        guard let bookModel = data as? KPBookModel else {
            return
        }
        
        bookName.text = bookModel.name
        authorName.text = bookModel.author
        rank.text = bookModel.doubanScore
        rating.rating = CGFloat(bookModel.rank ?? 0)
        bookImgV.kf.setImage(with:URL.init(string: bookModel.imgUrl ?? ""), placeholder:UIImage.init(named: "book_default"))
    }
    
}
