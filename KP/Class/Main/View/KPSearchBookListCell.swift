//
//  KPSearchBookListCell.swift
//  KP
//
//  Created by yll on 2018/3/12.
//  Copyright © 2018年 adoma. All rights reserved.
//

import UIKit

class KPSearchBookListCell: UITableViewCell {

    @IBOutlet weak var bookImg: UIImageView!
    
    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var author: UILabel!
    
    @IBOutlet weak var content: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        
        bookImg.backgroundColor = .random
        
        backgroundColor = .white

    }

    func disPlay(data: Any?) {
       
        guard let bookModel = data as? KPBookModel else {
            return
        }
        
        name.text = bookModel.name
        content.text = bookModel.content
        author.text = bookModel.author
        bookImg.kf.setImage(with:URL.init(string: bookModel.imgUrl ?? ""), placeholder:UIImage.init(named: "book_default"))
        
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
