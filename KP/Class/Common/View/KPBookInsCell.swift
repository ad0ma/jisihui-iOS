//
//  KPBookInsCell.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/31.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit

class KPBookInsCell: UITableViewCell {

    @IBOutlet weak var insTextV: UILabel!
    
    var orginHeight: CGFloat = 0
    
    func disPlay(data: Any?) {
        
        guard let insStr = data as? String else {
            return
        }
        
        self.kp_width = Main_Screen_Width
        layoutIfNeeded()
        
        let style = NSMutableParagraphStyle.init()
        style.lineSpacing = 5
        style.lineBreakMode = .byTruncatingTail
        
        let attrStr = NSAttributedString.init(string: insStr, attributes: [NSAttributedStringKey.paragraphStyle: style])
        
        insTextV.attributedText = attrStr
        
        insTextV.sizeToFit()
        
        orginHeight = insTextV.kp_height + 8
        
        clipsToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
