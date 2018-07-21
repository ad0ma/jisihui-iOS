//
//  KPSelectBookCell.swift
//  KP
//
//  Created by 王宇宙 on 2018/3/3.
//  Copyright © 2018年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON

class KPSelectBookCell: UITableViewCell {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var bookNameLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var doubanScoreLAbel: UILabel!
    
    var data: JSON? {
        didSet{
            coverImageView.kf.setImage(with: URL.init(string: data!["imgUrl"].stringValue))
            bookNameLabel.text = data!["name"].stringValue
            authorNameLabel.text = data!["author"].stringValue
            doubanScoreLAbel.text = "豆瓣评分:\(String(format: "%.1f", data!["doubanScore"].floatValue))"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
