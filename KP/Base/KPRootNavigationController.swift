//
//  KPRootNavigationController.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/6/3.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit

class KPRootNavigationController: UINavigationController, UINavigationControllerDelegate {
    
    @objc var popDelegate: UIGestureRecognizerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.isHidden = true

        self.popDelegate = self.interactivePopGestureRecognizer?.delegate
        
        self.delegate = self
    }
    
    //UINavigationControllerDelegate方法
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        //实现滑动返回功能
        //清空滑动返回手势的代理就能实现
        if viewController == self.viewControllers.first {
            self.interactivePopGestureRecognizer!.delegate = self.popDelegate
        } else {
            self.interactivePopGestureRecognizer!.delegate = nil
        }
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if childViewControllers.count > 0 {
            viewController.kp_self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "ic_back"), style: .plain, target: self, action: #selector(turnBack))
            viewController.hidesBottomBarWhenPushed = true
        }
        
        super.pushViewController(viewController, animated: animated)
    }

    @objc func turnBack() {
        popViewController(animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
