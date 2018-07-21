//
//  KPUser.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/6/5.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

//MARK: 属性
class KPUser: NSObject {
    
    static let share = KPUser()
    
    var nick: String?
    var account: String?
    var pushMail: String?
    var realSendMail: String?
    var id: Int?
    var sendMailPwd: String?
    var integral: Int?
    var vipSecond: Double = 0
    var vipDate: String {
        let formater = DateFormatter.init()
        formater.dateFormat = "yyyy.MM.dd"
        let date = Date.init(timeIntervalSince1970: vipSecond / 1000)
        return formater.string(from: date)
    }
    
    var headerIcon: String?
    var themeBgIcon: String?
    var introduce: String?
    
    private var token: String?
    var auth: String? {
        get {
            if token == nil {
                token = UserDefaults.standard.string(forKey: APP_USER_AUTH_KEY)
            }
            
            return token
        }
        
        set {
            token = newValue
            UserDefaults.standard.set(newValue, forKey: APP_USER_AUTH_KEY)
            UserDefaults.standard.synchronize()
        }
    }
}

//MARK: 状态
extension KPUser {
    
    //MARK: 判断用户是否登录
    var isLogin: Bool {
        get {
            return UserDefaults.standard.bool(forKey: APP_USER_LOGIN_KEY)
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: APP_USER_LOGIN_KEY)
        }
    }
    
    var isVip: Bool {
        return vipSecond > 0
    }
    
    
}

//MARK: 行为
extension KPUser {
    
    static func checkVersion(showTip: Bool = false) {
        
        if showTip {
            KPHud.showText(text: "正在检查，请稍候...", delay: 0)
        }
        
        KPNetWork.request(path: "m/upgrade", para: ["os":"IOS", "oldVersion": Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String]) { (result) in
            
            guard let data = result.data else {
                return
            }
            
            if result.response?.statusCode == 200, let json = try? JSON.init(data: data) {
                
                if json["needUpgrade"].boolValue {
                    
                    if NetworkReachabilityManager.init()?.isReachableOnWWAN ?? true , showTip{
                        
                        KPHud.showText(text: "请在Wifi条件下升级哦~")
                        
                    } else {
                        
                        KPHud.hideNotice()
                        
                        let newVersion = json["version"].stringValue
                        let description = json["description"].string
                        
                        let alert = UIAlertController.init(title: "新版本提醒\(newVersion)", message: description, preferredStyle: .alert)
                        
                        if json["force"].boolValue == false {
                            
                            let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
                            
                            alert.addAction(cancel)
                        }
                        
                        let update = UIAlertAction.init(title: "更新", style: .default, handler: { (_) in
                            
                            if let url = URL.init(string: json["downloadUrl"].stringValue) {
                                
                                UIApplication.shared.openURL(url)
                                
                                if json["force"].boolValue {
                                    exit(0)
                                }
                            }
                        })
                        
                        alert.addAction(update)
                        
                        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
        
                } else {
                    
                    if showTip {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: { 
                            KPHud.showText(text: "你已经是最新版了")
                        })
                    }
                }
                
            }
            
        }
    }
    
    func autoLogin() -> Void {
        
        if KPUser.share.isLogin == false {
            return
        }
        getUserInfo()
    }
    
    func getUserInfo() -> Void {
        
        if KPUser.share.isLogin == false {
            return
        }
        
        KPNetWork.request(path: "m/auth/user", method: .post) { (result) in
            
            guard let data = result.data else {
                return
            }
  
            if result.response?.statusCode == 200, let json = try? JSON.init(data: data) {
                
                let user = KPUser.share
                
                user.id = json["id"].int
                user.nick = json["nickName"].string
                user.account = json["username"].string
                user.pushMail = json["pushMail"].string
                user.realSendMail = json["realSendMail"].string
                user.sendMailPwd = json["sendMailPwd"].string
                user.integral = json["integral"].int
                user.vipSecond = json["expiration"].double ?? 0
                user.introduce = json["introduce"].string
            }
            
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: APP_USER_LOGIN_KEY), object: true)
        }
    }
    
    func resign() -> Void {
        KPUser.share.isLogin = false
        KPUser.share.auth = nil
        
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: APP_USER_LOGIN_KEY), object: false)
    }
    
    func login(auth: String) -> Void {
        KPUser.share.isLogin = true
        KPUser.share.auth = auth
        
        getUserInfo()
    }
}


