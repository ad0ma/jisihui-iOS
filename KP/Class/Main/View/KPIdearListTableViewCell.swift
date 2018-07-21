//
//  KPIdearListTableViewCell.swift
//  KP
//
//  Created by yll on 2018/3/14.
//  Copyright © 2018年 adoma. All rights reserved.
//

import UIKit

class KPIdearListTableViewCell: UITableViewCell {

    
    /// 搜索结果页面的想法列表cell
    
    @IBOutlet weak var imgV: UIImageView!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var commentCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func disPlay(data: Any?) {
        
        guard let idearListModel = data as? KPIdearModel else {
            return
        }
        
        contentLabel.text = idearListModel.content
        commentCountLabel.text = "查看\(String(describing: idearListModel.commentCount ?? 0))评论 >" 
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
