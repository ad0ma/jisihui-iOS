//
//  KPIdeaHistoryCell.swift
//  KP
//
//  Created by Adoma on 2018/6/3.
//  Copyright © 2018年 adoma. All rights reserved.
//

import UIKit

protocol KPIdeaHistoryCellDelegate: NSObjectProtocol {
    func selectedBook(id: String)
    func readAllAction(id: Int)
    func deleteAction(id: Int)
}

class KPIdeaHistoryCell: UITableViewCell {
    
    @IBOutlet weak var time: UILabel!
    
    
    @IBOutlet weak var topLine: UIView!
    @IBOutlet weak var dot: UIView!
    @IBOutlet weak var bottomLine: UIView!
    
    @IBOutlet weak var content: UITextView!
    
    @IBOutlet weak var bookBg: UIView!
    @IBOutlet weak var bookBgHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bookImg: UIImageView!
    
    @IBOutlet weak var bookName: UILabel!
    
    @IBOutlet weak var authorName: UILabel!
    
    @IBOutlet weak var rank: UILabel!
    
    @IBOutlet weak var showAll: UIButton!
    
    
    @IBOutlet weak var showAllHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var contentHeightConstraint: NSLayoutConstraint!
    
    
    var id: String?
    var ideaId: Int?
    weak var delegate: KPIdeaHistoryCellDelegate?
    
    @IBOutlet weak var deleteButton: UIButton!
    var canDelete = false 
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        dot.layer.cornerRadius = 5
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(showBookInfo))
        bookBg.addGestureRecognizer(tap)
    }
    
    @objc func showBookInfo() {
        delegate?.selectedBook(id: id!)
    }
    
    @IBAction func readAll() {
        delegate?.readAllAction(id: ideaId!)
    }
    
    @IBAction func delete() {
        delegate?.deleteAction(id: ideaId!)
    }
    
    func disPlay(data: Any?) {
        
        guard let idea = data as? KPIdeaModel else {
            return
        }
        
        ideaId = idea.id
        
        time.text = idea.lastUpdateDate
        content.text = idea.content
        
        showAll.setTitle(idea.readAll ? "收起":"展开", for: .normal)
        
        var contentHeight = idea.content?.caculateHeight(size: CGSize.init(width: Main_Screen_Width - 65, height: 1000), font: .systemFont(ofSize: 14)) ?? 0
        
        contentHeight += 14
        
        showAll.isHidden = contentHeight <= 51
        
        showAllHeightConstraint.constant = showAll.isHidden ? 5 : 25
        
        if !idea.readAll {
            contentHeightConstraint.constant = showAll.isHidden ? contentHeight + 10 : 51
        } else {
            contentHeightConstraint.constant = contentHeight + 10
        }
        
        bookBgHeightConstraint.constant = idea.book == nil ? 0 : 90
        
        bookBg.isHidden = idea.book == nil
        
        deleteButton.isHidden = !canDelete
        
        if let book = idea.book {
            id = book.id
            bookName.text = book.name
            authorName.text = book.author
            rank.text = "豆瓣评分：\(book.doubanScore)"
            bookImg.kf.setImage(with: URL.init(string: book.imgUrl ?? ""), placeholder: #imageLiteral(resourceName: "book_default"))
        }
    }
}
