//
//  KPMainEntryCell.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/26.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit

class KPMainEntryCell: UITableViewCell {
    
    typealias EntryBlock = (EntryType) -> ()
    var entryBlock: EntryBlock?
    
    @IBOutlet var names: [UILabel]!
        
    enum EntryType: Int {
        case rank
        case category
        case list
        case activity
    }
    
    override func awakeFromNib() {
        names.forEach{$0.textColor = Main_Theme_Color}
    }

    //MARK: anctions
    @IBAction func actions(_ sender: UIButton) {
        
        let idx = sender.tag - 100
        
        guard let entryType = EntryType.init(rawValue: idx) else {
            return
        }
        
        entryBlock?(entryType)
    }
    
}
