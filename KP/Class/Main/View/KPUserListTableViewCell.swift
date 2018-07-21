//
//  KPUserListTableViewCell.swift
//  KP
//
//  Created by yll on 2018/3/14.
//  Copyright © 2018年 adoma. All rights reserved.
//

import UIKit

class KPUserListTableViewCell: UITableViewCell {

    @IBOutlet weak var userImgV: UIImageView!
    
    @IBOutlet weak var userNiceNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    func disPlay(data: Any?) {
        
        guard let userListModel = data as? KPUserModel else {
            return
        }
        
        userNiceNameLabel.text = userListModel.nickName
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
