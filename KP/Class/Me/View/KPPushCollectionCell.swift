//
//  KPPushCollectionCell.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/6/5.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit

class KPPushCollectionCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    
    @IBOutlet weak var author: UILabel!
    
    @IBOutlet weak var tags: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    var bookModel: KPBookModel? {
        didSet {
            name.text = bookModel?.name
            author.text = bookModel?.author
            tags.text = bookModel?.tags ?? "暂无标签"
            
            if bookModel?.collectTime != nil {
                time.text = bookModel?.collectTimeFormat
            } else if bookModel?.pushTime != nil {
                time.text = bookModel?.pushTimeFormat
            }
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
