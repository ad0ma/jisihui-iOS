//
//  KPBookInfoKeyCell.swift
//  KP
//
//  Created by Shawley on 2018/4/7.
//  Copyright © 2018 adoma. All rights reserved.
//

import UIKit

class KPBookInfoKeyCell: KPBookInfoBaseCell {

    @IBOutlet weak var bgIcon: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.borderColor = Main_Theme_Color.cgColor
        layer.borderWidth = 1
        layer.cornerRadius = CGFloat(bounds.height / 2)
        layer.masksToBounds = true
        tagLabel.textColor = Main_Theme_Color
    }
    
    override func displayData(data: Any?) {
        
        guard let tag = data as? String else {
            return
        }
        
        tagLabel.text = tag
    }
}

extension KPBookInfoKeyCell {
    
    static func heightForData(text: String) -> CGFloat {
        let contentContainerHeight = getContentLabelWidth(text) //根据内容计算Content容器高度
        return contentContainerHeight + 15
    }
    
    static func getContentLabelWidth(_ content: String) -> CGFloat {
        let content = content as NSString
        let maxSize = CGSize(width: Main_Screen_Width, height: 30)
        let params = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
        let contentSize = content.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: params, context: nil).size
        return contentSize.width
    }
    
}
