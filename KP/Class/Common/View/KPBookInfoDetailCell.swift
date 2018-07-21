//
//  KPBookInfoDetailCell.swift
//  KP
//
//  Created by Shawley on 2018/4/7.
//  Copyright © 2018 adoma. All rights reserved.
//

import UIKit

class KPBookInfoDetailCell: KPBookInfoBaseCell {

    @IBOutlet weak var bookIcon: UIImageView!
    @IBOutlet weak var bookName: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var rank: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func displayData(data: Any?) {
        
        guard let book = data as? KPBookModel  else {
            return
        }
        
        author.text = book.author
        bookName.text = book.name
        
        if let f = book.rank, f > 0 {
            rank.text = "豆瓣评分: " + book.doubanScore
        } else {
            rank.text = book.doubanScore
        }
        
        bookIcon.kf.setImage(with:URL.init(string: book.imgUrl ?? ""), placeholder:UIImage.init(named: "book_default"))
    }
}
