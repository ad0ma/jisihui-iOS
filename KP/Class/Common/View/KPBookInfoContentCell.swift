//
//  KPBookInfoContentCell.swift
//  KP
//
//  Created by Shawley on 2018/4/8.
//  Copyright © 2018 adoma. All rights reserved.
//

import UIKit

class KPBookInfoContentCell: KPBookInfoBaseCell {

    @IBOutlet weak var bookContent: UITextView!
    @IBOutlet weak var readAllBtn: UIButton!
    
    typealias CallBack = (_ sender: UIButton) -> ()
    
    var readAllBlock: CallBack?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bookContent.isUserInteractionEnabled = false
        readAllBtn.setTitle("阅读全文", for: .normal)
        readAllBtn.setTitle("收起", for: .selected)
        readAllBtn.setTitleColor(Main_Theme_Color, for: .normal)
        readAllBtn.setTitleColor(Main_Theme_Color, for: .selected)
    }

    override func displayData(data: Any?) {
        
        guard let book = data as? KPBookModel, let content = book.content else {
            return
        }
        
        bookContent.text = content
        readAllBtn.isHidden = content.count == 0
        readAllBtn.isSelected = book.readAll
    }
    
    @IBAction func readAllBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        readAllBlock?(sender)
    }
}

extension KPBookInfoContentCell {
    //根据数据计算cell高度
    static func heightForData(text: String) -> CGFloat {
        let contentContainerHeight = getContentLabelHeight(text)
        return contentContainerHeight + 52
    }
    
    //计算字符串需要的高度
    static func getContentLabelHeight(_ content: String) -> CGFloat {
        let content = content as NSString
        let maxSize = CGSize(width: Main_Screen_Width - 20, height: CGFloat.greatestFiniteMagnitude)
        let params = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]
        let contentSize = content.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: params, context: nil).size
        return contentSize.height
    }
}
