//
//  KPSegmentedControl.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/23.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit


protocol KPSegmentedControlDelegate: class {
    
    func didSelect(itemIndex: Int)
}

class KPSegmentedControl: UIView {
    
    weak var delegate: KPSegmentedControlDelegate?
    
    private var index = 0
    @objc var selectedIndex: Int {
        get {
            return self.index
        }
        
        set {
            selectIndex(index: newValue)
            self.index = newValue
        }
    }

    private var line: UIView!
    
    
    @objc init(frame: CGRect, titles: [String]) {
        super.init(frame: frame)
                
        backgroundColor = .white
        
        let itemWidth = Main_Screen_Width / CGFloat(titles.count)
        let itemHeight = frame.size.height
        
        for (idx, title) in titles.enumerated() {
            
            let item = UIView.init(frame: CGRect.init(x: CGFloat.init(idx) * itemWidth, y: 0, width: itemWidth, height: itemHeight))
            
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction(sender:)))
            
            item.isUserInteractionEnabled = true
            item.addGestureRecognizer(tap)
            item.tag = 100 + idx
            
            addSubview(item)

            let titleLabel = UILabel()
            item.addSubview(titleLabel)
            
            titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
            titleLabel.text = title
            titleLabel.textAlignment = .center
            
            titleLabel.snp.makeConstraints({ (make) in
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-1.5)
            })
            
            if idx == selectedIndex {
                
                titleLabel.textColor = Main_Theme_Color
                
                line = UIView.init(frame: CGRect.init(x: 0, y: 36, width: 30, height: 2))
                addSubview(line!)
                
                line?.backgroundColor = Main_Theme_Color
                line?.layer.cornerRadius = 1
                
                line?.snp.makeConstraints({ (make) in
                    make.top.equalTo(titleLabel.snp.bottom).offset(1)
                    make.centerX.equalTo(titleLabel)
                    make.width.equalTo(titleLabel).offset(-2)
                    make.height.equalTo(2)
                })
            } else {
                titleLabel.textColor = RGBCOLOR(r: 51, g: 51, b: 51)
            }
            
        }
        
        let sep = UIView()
        addSubview(sep)
        
        sep.backgroundColor = Separator_Color
        sep.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func selectIndex(index: Int) {
        
        guard let selectLabel = viewWithTag(index + 100)?.subviews.first as? UILabel,
            let lastLabel = viewWithTag(selectedIndex + 100)?.subviews.first as? UILabel else {
            return
        }
        
        if selectLabel.tag - 100 == selectedIndex {
            return
        }
        
        lastLabel.textColor = RGBCOLOR(r: 51, g: 51, b: 51)
        selectLabel.textColor = Main_Theme_Color

        line?.snp.remakeConstraints({ (make) in
            make.top.equalTo(selectLabel.snp.bottom).offset(1)
            make.width.equalTo(0)
            make.left.equalTo(selectLabel.snp.centerX)
            make.height.equalTo(2)
        })
        
        layoutIfNeeded()
        
        line?.snp.remakeConstraints({ (make) in
            make.top.equalTo(selectLabel.snp.bottom).offset(1)
            make.width.equalTo(selectLabel).offset(-2)
            make.left.equalTo(selectLabel).offset(1)
            make.height.equalTo(2)
        })

        UIView.animate(withDuration: 0.2) {
            self.layoutIfNeeded()
        }
        
    }
    
    @objc private func tapAction(sender: UIGestureRecognizer) {
        
        let tag = (sender.view?.tag)! - 100
        
        if selectedIndex == tag {
            return
        }
        
        selectedIndex = tag
        
        delegate?.didSelect(itemIndex: selectedIndex)
    }
}
