//
//  KPHud.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/6/5.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit

class KPHud: NSObject {
    
    static let `default` = KPHud()
    
    var current: UIWindow?
    var bg: UIView?

    
    static func showWaiting(text: String? = nil, delay: TimeInterval = 0) {
        
        KPHud.default.bg?.removeFromSuperview()
        
        let window = UIWindow()
        window.backgroundColor = UIColor.clear
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.white
        label.text = text
        label.numberOfLines = 2
        label.textAlignment = .center
        
        let bg = UIView.init(frame: CGRect.init(x: 0, y: 0, width: kp_layout(80), height: kp_layout(80)))
        
        bg.tag = 1001
        bg.backgroundColor = RGBCOLOR(r: 0, g: 0, b: 0, alpha: 0.6)
        
        bg.layer.cornerRadius = 8
        bg.layer.masksToBounds = true
        
        bg.addSubview(label)
        
        let act = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        bg.addSubview(act)
        
        act.startAnimating()
        
        act.snp.makeConstraints { (make) in
            if text == nil {
                make.center.equalToSuperview()
            } else {
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview().offset(-10)
            }
        }
        
        label.snp.makeConstraints { (make) in
            if text == nil {
                
            } else {
                make.left.bottom.right.equalToSuperview()
                make.top.equalTo(act.snp.bottom)
            }
        }
        
        window.frame = UIScreen.main.bounds
        let vc = KPBaseViewController()
        vc.view.backgroundColor = .clear
        window.rootViewController = vc
        
        bg.center = window.center
        
        window.windowLevel = UIWindowLevelAlert
        window.isHidden = false
        window.addSubview(bg)
        
        bg.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {
            bg.alpha = 1
        })
        
        KPHud.default.current = window
        KPHud.default.bg = bg
        
        let selector = #selector(hideNotice)
        if delay > 0 {
            self.perform(selector, with: window, afterDelay: delay)
        }
    }
    
    static func showText(text: String, delay: TimeInterval = 2) {
        KPHud.default.bg?.removeFromSuperview()
        
        let window = UIWindow()
        window.backgroundColor = UIColor.clear
        
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.white
        label.text = text
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        
        let maxWidth: CGFloat = Main_Screen_Width - 80
        
        let name = text as NSString
        
        let maxSize = CGSize.init(width:maxWidth, height: 40)
        
        let size = name.boundingRect(with:maxSize , options: [.usesFontLeading, .usesLineFragmentOrigin], attributes: [NSAttributedStringKey.font: label.font], context: nil).size
        
        let bg = UIView()
        
        bg.tag = 1001
        bg.backgroundColor = RGBCOLOR(r: 0, g: 0, b: 0, alpha: 0.6)
        
        bg.layer.cornerRadius = maxSize.height*0.5
        bg.layer.masksToBounds = true
        
        bg.addSubview(label)
        
        label.frame.size = size
        label.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        window.frame = UIScreen.main.bounds
        let vc = KPBaseViewController()
        vc.view.backgroundColor = .clear
        window.rootViewController = vc

        window.windowLevel = UIWindowLevelAlert
        window.isHidden = false
        window.addSubview(bg)
        
        bg.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-100)
            make.size.equalTo(CGSize.init(width: size.width + 40, height: maxSize.height))
        }
        
        bg.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {
            bg.alpha = 1
        })
        
        KPHud.default.current = window
        KPHud.default.bg = bg
        
        let selector = #selector(hideNotice)
        if delay > 0 {
            self.perform(selector, with: window, afterDelay: delay)
        }
    }
    
    @objc static func hideNotice ()
    {
        UIView.animate(withDuration: 0.2, animations: { 
            KPHud.default.current?.viewWithTag(1001)?.alpha = 0
        }) { (done) in
            KPHud.default.current = nil
        }
    }
}
