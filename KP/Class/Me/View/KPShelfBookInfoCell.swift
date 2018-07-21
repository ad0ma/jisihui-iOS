//
//  KPShelfBookInfoCell.swift
//  KP
//
//  Created by Shawley on 25/01/2018.
//  Copyright © 2018 adoma. All rights reserved.
//

import UIKit

@objc protocol KPShelfBookInfoCellDelegate {
    
    func thinkBtnTapped(sender: UIButton, indexPath: IndexPath?)
    
    func pushBtnTapped(sender: UIButton, indexPath: IndexPath?)
}

class KPShelfBookInfoCell: UITableViewCell {
    
    @IBOutlet weak var infoContent: UIView!
    
    @IBOutlet weak var selectImg: UIImageView!
    
    @IBOutlet weak var bookImg: UIImageView!
    
    @IBOutlet weak var bookName: UILabel!
    
    @IBOutlet weak var authorName: UILabel!
    
    @IBOutlet weak var bookRank: UILabel!
    
    @IBOutlet weak var thinkMiddleBtn: UIButton!
    
    @IBOutlet weak var selectViewWidth: NSLayoutConstraint!
    
    weak var delegate: KPShelfBookInfoCellDelegate?
    
    var indexPath: IndexPath?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        //        infoContent.layer.borderWidth = 0.5
        //        infoContent.layer.borderColor = Border_Color.cgColor
        infoContent.layer.shadowColor = UIColor.darkGray.cgColor
        infoContent.layer.shadowOffset = CGSize.init(width: 0, height: 1)
        infoContent.layer.shadowOpacity = 0.5
        infoContent.layer.shadowRadius = 3
        
        //隐藏想法按钮，先行上线
        thinkMiddleBtn.isHidden = true
        
        thinkMiddleBtn.setTitle("想法", for: .normal)
        thinkMiddleBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        thinkMiddleBtn.setTitleColor(Main_Theme_Color, for: .normal)
        thinkMiddleBtn.layer.cornerRadius = 4.0
        thinkMiddleBtn.layer.masksToBounds = true
        thinkMiddleBtn.layer.borderWidth = 1.0
        thinkMiddleBtn.layer.borderColor = Main_Theme_Color.cgColor
        
        bookImg.backgroundColor = .random
    }
    
    func disPlay(data: Any?) {
        guard let bookModel = data as? KPBookModel else {
            return
        }
        
        authorName.text = bookModel.author
        bookName.text = bookModel.name
        
        if let f = bookModel.rank, f > 0 {
            bookRank.text = "豆瓣评分: " + bookModel.doubanScore
        } else {
            bookRank.text = bookModel.doubanScore
        }
        
        selectImg.image = UIImage.init(named: bookModel.selected ? "selected" : "unselect")
        
        bookImg.kf.setImage(with:URL.init(string: bookModel.imgUrl ?? ""), placeholder:UIImage.init(named: "book_default"))
    }
    
    func setDelegate(delegate: KPShelfBookInfoCellDelegate, type: KPBookStatuModel.KPBookStatus, isBatch: Bool, indexPath: IndexPath) {
        self.delegate = delegate

        selectImg.isHidden = !isBatch
        self.indexPath = indexPath
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.selectImg.isHidden {
            self.selectViewWidth.constant = 0.0
        } else {
            self.selectViewWidth.constant = 30.0
        }
        
    }
    
    
    @IBAction func thinkMiddleBtnTapped(_ sender: UIButton) {
        delegate?.thinkBtnTapped(sender: sender, indexPath: indexPath)
    }
    
    
}
