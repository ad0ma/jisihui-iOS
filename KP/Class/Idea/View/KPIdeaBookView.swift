//
//  KPIdeaBookView.swift
//  KP
//
//  Created by 王宇宙 on 2018/2/7.
//  Copyright © 2018年 adoma. All rights reserved.
//

import UIKit
import Kingfisher
import SwiftyJSON


protocol IdeaBookViewActionDelegate {
    func bookDidClicked(bookId: String) -> Void;
}

class KPIdeaBookView: UIView {
    
    @IBOutlet weak var bookCoverImageView: UIImageView!
    @IBOutlet weak var bookNameLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var pressLabel: UILabel!
    @IBOutlet weak var publishDateLabel: UILabel!
    
    
    var delegate: IdeaBookViewActionDelegate?
    var bookInfo: [String: JSON]? {
        didSet{

            guard let book=bookInfo else {
                return
            }
            guard book.keys.count>0 else {
                return
            }
            bookNameLabel.text = book["name"]?.stringValue
            authorNameLabel.text = book["author"]?.stringValue
            scoreLabel.text = "豆瓣评分:\(String(format: "%.1f", (book["doubanScore"]?.floatValue)!))"
            let imgUrl = book["imgUrl"]?.string
            guard let url=imgUrl else {
                return
            }
            bookCoverImageView.kf.setImage(with: URL.init(string: url), placeholder: UIImage(named: "book_default"), options: nil, progressBlock: nil, completionHandler: nil)
        }
    }
    
    //
    @IBAction func bookClickAction(_ sender: UIButton) {
        delegate?.bookDidClicked(bookId: "\(bookInfo!["id"]!.numberValue)")
    }
    
}


