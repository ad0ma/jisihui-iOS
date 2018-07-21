//
//  KPBaseViewController.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/23.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit

class KPBaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MobClick.beginLogPageView(kp_name)


        view.backgroundColor = Content_Color
        
        edgesForExtendedLayout = [.top, .left, .right, .bottom]

        automaticallyAdjustsScrollViewInsets = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(userStatu(sender:)), name: NSNotification.Name.init(APP_USER_LOGIN_KEY), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        MobClick.endLogPageView(kp_name)
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func userStatu(sender: NSNotification) -> Void {}
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init(APP_USER_LOGIN_KEY), object: nil)
    }

}

class KPBaseTableViewController: UITableViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MobClick.beginLogPageView(kp_name)
        
        view.backgroundColor = Content_Color
        
        tableView.backgroundColor = Content_Color
        tableView.showsVerticalScrollIndicator = false
        
        automaticallyAdjustsScrollViewInsets = false
        
        edgesForExtendedLayout = [.left, .right, .bottom]

        tableView.tableFooterView = UIView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(userStatu(sender:)), name: NSNotification.Name.init(APP_USER_LOGIN_KEY), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        MobClick.endLogPageView(kp_name)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func userStatu(sender: NSNotification) -> Void {}
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init(APP_USER_LOGIN_KEY), object: nil)
    }
}
