//
//  KPMainBooksCell.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/27.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit

class KPMainBooksCell: UITableViewCell {
    
    @IBOutlet weak var oneImgV: UIImageView!
    
    @IBOutlet weak var oneTitle: UILabel!
    
    @IBOutlet weak var oneRank: UILabel!
    
    
    @IBOutlet weak var twoImgV: UIImageView!
    
    @IBOutlet weak var twoTitle: UILabel!
    
    @IBOutlet weak var twoRank: UILabel!
    
    
    @IBOutlet weak var threeImgV: UIImageView!
    
    @IBOutlet weak var threeTtile: UILabel!
    
    @IBOutlet weak var threeRank: UILabel!
    
    
    @IBOutlet var ranks: [UILabel]!
    
    
    typealias SelectBlock = (Int) -> ()
    var selectBlock: SelectBlock?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ranks.forEach { (rank) in
//            rank.layer.cornerRadius = 10
//            rank.layer.masksToBounds = true
//            rank.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            rank.textColor = Main_Theme_Color
        }
    }
    
    @IBAction func selectBook(_ sender: UIControl) {
        //MARK: tag = sender.tag - 100
        let bookIdx = sender.tag - 100
        selectBlock?(bookIdx)
    }
    
    func disPlay(data: Any?) {
        
        guard let books = data as? [KPBookModel] else {
            return
        }
        
        oneImgV.image = nil
        oneTitle.text = nil
        oneRank.text = nil
        
        twoImgV.image = nil
        twoTitle.text = nil
        twoRank.text = nil
        
        threeImgV.image = nil
        threeTtile.text = nil
        threeRank.text = nil
        
        for (idx, book) in books.enumerated() {
            switch idx {
            case 0:
                oneImgV.kf.setImage(with:URL.init(string: book.imgUrl ?? ""), placeholder:UIImage.init(named: "book_default"))
                oneTitle.text = book.name
                oneRank.text = book.doubanScore
                
            case 1:
                twoImgV.kf.setImage(with:URL.init(string: book.imgUrl ?? ""), placeholder:UIImage.init(named: "book_default"))
                twoTitle.text = book.name
                twoRank.text = book.doubanScore
                
            case 2:
                threeImgV.kf.setImage(with:URL.init(string: book.imgUrl ?? ""), placeholder:UIImage.init(named: "book_default"))
                threeTtile.text = book.name
                threeRank.text = book.doubanScore
            
            default:
                break
            }
        }
    }
}
