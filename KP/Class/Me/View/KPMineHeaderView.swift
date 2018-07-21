//
//  KPMineHeaderView.swift
//  KP
//
//  Created by Shawley on 11/03/2018.
//  Copyright © 2018 adoma. All rights reserved.
//

import UIKit
import Kingfisher

@objc protocol KPMineSettingViewDelegate {
    func editButtonTapped()
}

class KPMineHeaderView: UICollectionReusableView {

    @IBOutlet weak var themeBgImageView: UIImageView!
    @IBOutlet weak var headerIcon: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var vipButton: UIButton!
    @IBOutlet weak var bgView: UIView!
    
    weak var delegate: KPMineSettingViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        headerIcon.layer.cornerRadius = headerIcon.bounds.width / 2
        headerIcon.layer.masksToBounds = true
        vipButton.setImage(UIImage.init(named: "vip_g"), for: .normal)
        vipButton.setImage(UIImage.init(named: "vip_r"), for: .selected)
        bgView.backgroundColor = Separator_Color
    }
    
    func showData(headerImage: UIImage?, themeBgImage: UIImage?) {
        
        headerIcon.image = UIImage.init(named: "icon_user")

        guard KPUser.share.isLogin else {
            nicknameLabel.text = "未登录"
            vipButton.isHidden = true
            detailLabel.isHidden = true
            themeBgImageView.image = nil
            return
        }
        
        vipButton.isHidden = false
        detailLabel.isHidden = false
        nicknameLabel.text = KPUser.share.nick ?? "加载中"
        vipButton.isSelected = KPUser.share.isVip
        detailLabel.text = KPUser.share.introduce
        
        if let icon = headerImage {
            headerIcon.image = icon
        } else if let icon = KPUser.share.headerIcon {
            headerIcon.kf.setImage(with: URL(string: icon), placeholder: UIImage.init(named: "icon_user"))
        }
        
        if let icon = themeBgImage {
            themeBgImageView.image = icon
        } else if let icon = KPUser.share.themeBgIcon {
           themeBgImageView.kf.setImage(with: URL(string: icon))
        }
    }
    
    func refreshIcon(type: KPNetWork.IconType, urlString: String, image: UIImage) {
        switch type {
        case .Header:
            headerIcon.kf.setImage(with: URL(string: urlString), placeholder: image)
        case .Background:
            themeBgImageView.kf.setImage(with: URL(string: urlString), placeholder: image)
        }
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        delegate?.editButtonTapped()
    }
    
    @IBAction func headIconTapped(_ sender: UIButton) {
        delegate?.editButtonTapped()
    }
}
