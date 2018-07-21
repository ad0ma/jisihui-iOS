//
//  KPLoginController.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/6/5.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON

class KPLoginController: KPBaseViewController {
    
    @IBOutlet weak var accountTextF: UITextField!
    @IBOutlet weak var pwdTextF: UITextField!
    
    @IBOutlet weak var loginBotton: UIButton!
    
    convenience init() {
        self.init(nibName: "KPLoginController", bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "登录"

        if #available(iOS 11, *) {
            self.additionalSafeAreaInsets.top = -kLayoutNavH
        }

        loginBotton?.layer.cornerRadius = 5

        accountTextF?.superview?.layer.cornerRadius = 5
        accountTextF?.superview?.layer.masksToBounds = true
        
        let leftBack = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 24 + 10, height: 24))
        
        let left = UIImageView.init(frame: CGRect.init(x: 5, y: 0, width: 24, height: 24))
        
        left.image = UIImage.init(named: "ic_drawer_account")
        leftBack.addSubview(left)
        accountTextF?.leftView = leftBack
        accountTextF?.leftViewMode = .always
        
        let leftBack2 = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 24 + 10, height: 24))
        
        let left2 = UIImageView.init(frame: CGRect.init(x: 5, y: 0, width: 24, height: 24))
        
        left2.image = UIImage.init(named: "ic_password")
        leftBack2.addSubview(left2)
        pwdTextF?.leftView = leftBack2
        pwdTextF?.leftViewMode = .always

    }

    override func viewDidAppear(_ animated: Bool) {

    }
    
    @IBAction func forgetPwd()
    {
        let pwdController = KPWebViewController.instance
        pwdController.kp_self.title = "找回密码"
        (pwdController.kp_self as! KPWebViewController).urlStr = "http://www.jisihui.com/user/forget"
        self.navigationController?.pushViewController(pwdController, animated: true)
    }
    
    @IBAction func resign()
    {
        let resignController = KPWebViewController.instance
        resignController.kp_self.title = "注册"
        (resignController.kp_self as! KPWebViewController).urlStr = "http://www.jisihui.com/user/reg"
        self.navigationController?.pushViewController(resignController, animated: true)
    }
    
    @IBAction func login()
    {
        
        view.endEditing(true)
        
        guard let account = accountTextF.text as NSString?,
        account.length > 0 else {
            KPHud.showText(text: "请输入登录邮箱")
            return
        }
        
        guard let pwd = pwdTextF.text as NSString?,
            pwd.length > 0 else {
             KPHud.showText(text: "请输入密码")
            return
        }
        
        let para = ["username": account, "password": pwd]
        
        KPHud.showWaiting()
        
        KPNetWork.request(path: "m/login", method: .post, para: para) { (result) in
            
            guard let data = result.value,
                let json = try? JSON.init(data: data),
                  let msg = json["msg"].string else {
                return
            }
            
            KPHud.hideNotice()
            
            if result.response?.statusCode == 200 {
                KPUser.share.login(auth: msg)
                self.navigationController?.popViewController(animated: true)
            } else {
                KPHud.showText(text: msg)
            }
        }
    
    }
    
}
