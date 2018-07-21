//
//  KPAllSearchView.swift
//  KP
//
//  Created by yll on 2018/3/12.
//  Copyright © 2018年 adoma. All rights reserved.
//

import UIKit

class KPAllSearchView: UIView {

    let titleLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "大家都在搜"
        return label
    
    }()

    let lineView: UIView = {
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor.gray
        return lineView
    
    }()
    
    
    
    init(frame: CGRect, titles: [String]) {
        
        super.init(frame: frame)
        
        backgroundColor = UIColor.white
        
        addSubview(titleLabel)
        addSubview(lineView)
        
        titleLabel.snp.makeConstraints { (make) in
            
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(40)
            
        }
        lineView.snp.makeConstraints { (make) in
            
            make.top.equalTo(titleLabel.snp.bottom)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(1)
            
        }
        
        
        //
        for (index, title) in titles.enumerated() {
            
            let titleButton: UIButton = UIButton.init(frame: CGRect.init(x: 15 + index * 70, y: 50, width: 70, height: 40))
            titleButton.setTitle(title, for: .normal)
            titleButton.titleLabel?.font = UIFont.layoutFont(size: 14)
            titleButton.setTitleColor(RGBCOLOR(r: 184, g: 148, b: 119), for: .normal)
            addSubview(titleButton)
            
            
//            titleButton.addTarget(self, action: #selector(readedAction), for: .touchUpInside)
            
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
