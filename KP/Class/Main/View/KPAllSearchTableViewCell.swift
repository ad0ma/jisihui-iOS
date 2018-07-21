//
//  KPAllSearchTableViewCell.swift
//  KP
//
//  Created by yll on 2018/3/14.
//  Copyright © 2018年 adoma. All rights reserved.
//

import UIKit

class KPAllSearchTableViewCell: UITableViewCell {
    
    /// 静态搜索cell
    
    typealias CallBack = (String, Int)->Void
    
    var selectTagCallBack: CallBack?
    
    let buttonHeight: CGFloat = 25
    let buttonMargin: CGFloat = 8
    let extMargin: CGFloat = 14
    
    let buttonFont = UIFont.systemFont(ofSize: 13)
    
    init?(keys: [String]) {
        
        if keys.count == 0 {
            return nil
        }
        
        super.init(style: .default, reuseIdentifier: "")
        
        selectionStyle = .none
        
        var lastButton: UIView!
        
        for (idx, key) in keys.enumerated() {
            
            let keyButton = makeKeyButton(name: key)
            
            var x = extMargin
            var y: CGFloat = 0
            let maxWidth = Main_Screen_Width - 2 * buttonMargin
            let buttonWidth = keyButton.frame.size.width + 20
            let width =  buttonWidth > maxWidth ? maxWidth : buttonWidth
            
            if idx == 0 {
                
            } else {
                if (lastButton.kp_maxX + width + buttonMargin*2 > Main_Screen_Width) { //换行
                    y = lastButton.kp_maxY + buttonMargin;
                } else {
                    x = lastButton.kp_maxX + buttonMargin;
                    y = lastButton.kp_y;
                }
            }
            
            keyButton.tag = 20190327 + idx
            
            keyButton.frame = CGRect.init(x: x, y: y, width: width, height: buttonHeight)
            self.addSubview(keyButton)
            lastButton = keyButton
        }
        
        //MARK: 重新计算高度
        self.kp_height = lastButton.kp_maxY + extMargin;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeKeyButton(name: String) -> UIView {
        
        let key = UIButton()
        
        key.setTitle(name.trimmingCharacters(in: .whitespacesAndNewlines), for: .normal)
        key.titleLabel?.font = buttonFont
        key.titleLabel?.textAlignment = .center
        key.setTitleColor(Search_Color, for: .normal)
        
        key.addTarget(self, action: #selector(selected(tag:)), for: .touchUpInside)
        
        key.sizeToFit()
                
        return key
    }
    
    @objc func selected(tag: UIButton) {
        if let text = tag.titleLabel?.text {
            selectTagCallBack?(text, tag.tag - 20190327)
        }
    }
    
}
