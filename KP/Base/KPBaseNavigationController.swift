//
//  KPBaseNavigationController.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/23.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit

class KPBaseNavigationController: UINavigationController, UIGestureRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18),NSAttributedStringKey.foregroundColor: UIColor.white]

        let isDark = UserDefaults.standard.bool(forKey: APP_THEME_DARK_KEY)
        //MARK: 根据偏好设置bar颜色
        if isDark {
            navigationBar.setBackgroundImage(nil, for: .default)
        } else {
            navigationBar.setBackgroundImage(UIImage.init(named: "bg_kp"), for: .default)
        }

        navigationBar.isTranslucent = true
        navigationBar.tintColor = .white
        navigationBar.barStyle = .black
        navigationBar.shadowImage = nil
        
        //MARK: 注册通知
        NotificationCenter.default.addObserver(self, selector: #selector(themeChangeNotification(sender:)), name: NSNotification.Name(rawValue: APP_THEME_DARK_KEY), object: nil)
        
        self.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        if childViewControllers.count > 0,
            let conten = self.topViewController {
            conten.kp_navigationController?.pushViewController(viewController, animated: animated)
        } else {
            super.pushViewController(viewController, animated: animated)
        }
        
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        let conten = self.topViewController
        return conten!.kp_navigationController!.popViewController(animated: animated)
    }
    
    @objc func themeChangeNotification(sender: NSNotification) -> Void {
        
        let isDark = sender.object as! Bool
        
        //MARK: 根据偏好设置bar颜色
        if isDark {
            navigationBar.setBackgroundImage(nil, for: .default)
        } else {
            navigationBar.setBackgroundImage(UIImage.init(named: "bg_kp"), for: .default)
        }
    }
    

}
