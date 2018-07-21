//
//  KPMoreInsController.swift
//  KP
//
//  Created by ad0ma on 2017/6/29.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit

class KPMoreInsController: KPBaseViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        topConstraint?.constant = kLayoutNavH
    }
    
    func setAttrText(text: NSAttributedString) {
        textView?.attributedText = text
        textView.contentOffset = CGPoint.zero
    }
    
    func setText(text: String) -> Void {
        
        let style = NSMutableParagraphStyle.init()
        style.lineSpacing = 3
        style.firstLineHeadIndent = 10
        style.paragraphSpacing = 5
        
        let attrStr = NSAttributedString.init(string: text, attributes: [NSAttributedStringKey.paragraphStyle: style, NSAttributedStringKey.foregroundColor: Main_Text_Color, NSAttributedStringKey.font:UIFont.systemFont(ofSize: 16)])
        
        textView?.attributedText = attrStr
        
        textView?.sizeToFit()
        
        textView.contentOffset = CGPoint.zero
    }

}
