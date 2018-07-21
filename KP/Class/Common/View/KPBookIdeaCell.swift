//
//  KPBookIdeaCell.swift
//  KP
//
//  Created by Shawley on 06/04/2018.
//  Copyright © 2018 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON

@objc protocol KPBookIdeaCellDelegate {
    
    func praiseBtnTapped(sender: UIButton, data: Any?, closure: @escaping (_ result: Bool) -> ())
    
    func collectionBtnTapped(sender: UIButton, data: Any?, closure: @escaping (_ result: Bool) -> ())
    
}

class KPBookIdeaCell: KPBookInfoBaseCell {

    @IBOutlet weak var userHeadIcon: UIImageView!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var ideaCreateTime: UILabel!
    
    @IBOutlet weak var ideaDetail: UITextView!
    
    @IBOutlet weak var praiseBtn: UIButton!
    @IBOutlet weak var praiseCount: UILabel!
    @IBOutlet weak var collectionBtn: UIButton!
    @IBOutlet weak var collectionCount: UILabel!
    @IBOutlet weak var readAllBtn: UIButton!
    
    typealias CallBack = (_ sender: UIButton) -> ()
    
    var readAllBlock: CallBack?
    
    weak var delegate: KPBookIdeaCellDelegate?
    
    var data: KPIdeaModel?
    var collectsCount = 0
    var likesCount = 0

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        praiseBtn.setImage(UIImage(named: "点赞未点击"), for: .normal)
        praiseBtn.setImage(UIImage(named: "点赞已点击"), for: .selected)
        collectionBtn.setImage(UIImage(named: "收藏未点击"), for: .normal)
        collectionBtn.setImage(UIImage(named: "收藏已点击"), for: .selected)
        userHeadIcon.layer.borderColor = Main_Theme_Color.cgColor
        userHeadIcon.layer.borderWidth = 1
        userHeadIcon.layer.cornerRadius = CGFloat(userHeadIcon.bounds.width / 2)
        userHeadIcon.layer.masksToBounds = true
        ideaDetail.isUserInteractionEnabled = false
        readAllBtn.setTitle("展开", for: .normal)
        readAllBtn.setTitle("收起", for: .selected)
        readAllBtn.setTitleColor(Main_Theme_Color, for: .normal)
    }
    
    override func displayData(data: Any?) {
        
        guard let data = data as? KPIdeaModel else {
            return
        }
        
        self.data = data
        ideaDetail.text = data.content
        readAllBtn.isHidden = KPBookIdeaCell.getContentLabelHeight(data.content ?? "") < 17
        nickName.text = data.nickName
        
        if let picKey = data.picKey  {
            userHeadIcon.kf.setImage(with: URL.kp_qiniuImage(picKey: picKey), placeholder: #imageLiteral(resourceName: "icon_user"))
        } else {
            userHeadIcon.kf.setImage(with: data.avatarUrl, placeholder: #imageLiteral(resourceName: "icon_user"))
        }
        
        collectsCount = data.collectsCount
        likesCount = data.likesCount
        collectionCount.text = "(\(collectsCount))"
        praiseCount.text = "(\(likesCount))"
        ideaCreateTime.text = data.lastUpdateDate
        readAllBtn.isSelected = data.readAll
    }

    @IBAction func praiseBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.praiseBtnTapped(sender: sender, data: data) { result in
            guard result else {
                sender.isSelected = !sender.isSelected
                return
            }
            if sender.isSelected {
                self.likesCount += 1
            } else {
                self.likesCount -= 1
            }
            self.praiseCount.text = "(\(self.likesCount))"
        }
    }
    
    @IBAction func collectionBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        delegate?.collectionBtnTapped(sender: sender, data: data) { result in
            guard result else {
                sender.isSelected = !sender.isSelected
                return
            }
            if sender.isSelected {
                self.collectsCount += 1
            } else {
                self.collectsCount -= 1
            }
            self.collectionCount.text = "(\(self.collectsCount))"
        }
    }
    
    @IBAction func readAllBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        readAllBlock?(sender)
    }
}

extension KPBookIdeaCell {
    //根据数据计算cell高度
    static func heightForData(text: String) -> CGFloat {
        let contentContainerHeight = getContentLabelHeight(text) + 14 //根据内容计算Content容器高度
        return 58 + contentContainerHeight + 53
    }
    
    //计算字符串需要的高度
    static func getContentLabelHeight(_ content: String) -> CGFloat {
        let content = content as NSString
        let maxSize = CGSize(width: Main_Screen_Width - 73, height: CGFloat.greatestFiniteMagnitude)
        let params = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
        let contentSize = content.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine, .usesFontLeading], attributes: params, context: nil).size
        return contentSize.height
    }
}
