//
//  KPGuessBookInfoCell.swift
//  KP
//
//  Created by Shawley on 06/04/2018.
//  Copyright © 2018 adoma. All rights reserved.
//

import UIKit

class KPGuessBookInfoCell: KPBookInfoBaseCell {

    @IBOutlet weak var bookIcon: UIImageView!
    @IBOutlet weak var bookName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func displayData(data: Any?) {
        
        guard let book = data as? KPBookModel else {
            return
        }
        
        bookName.text = book.name
        bookIcon.kf.setImage(with:URL.init(string: book.imgUrl ?? ""), placeholder:UIImage.init(named: "book_default"))
    }
}
