//
//  KPLaunchViewController.swift
//  KP
//
//  Created by Adoma on 2017/7/6.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON

/**
 是否 inReview
 */
var isAdoma = true

let splashAd: GDTSplashAd? = GDTSplashAd.init(appkey: AD_App_Id, placementId: AD_Lanuch_Id)

class KPLaunchController: UIViewController, GDTSplashAdDelegate {
    
    let bg = UIImageView.init(image: UIImage.init(named: "launch"))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        bg.frame = self.view.bounds
        self.view.addSubview(bg)
        getAdoma()
    }
    
    func getAdoma() {
        
        KPHud.showWaiting()
        
        KPNetWork.request(path: "m/upgrade", para: ["os":"IOS", "oldVersion": Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String]) { (result) in
         
            KPHud.hideNotice()
            
            guard  result.result.isSuccess,
                let data = result.data,
                let json = try? JSON.init(data: data) else  {
                    
                    let alert = UIAlertController.init(title: "网络连接失败", message: "请检查网络设置及是否已允许使用无线网络或移动数据", preferredStyle: .alert)
                    
                    let retry = UIAlertAction.init(title: "重试", style: .default, handler: { (_) in
                        self.getAdoma()
                    })
                    
                    alert.addAction(retry)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    return
            }
            
            if let lastVersion =  json["version"].string {
                //当且仅当本地版本号大于app最新版本号时isAdoma为true
                isAdoma = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String > lastVersion
            }
            
            #if DEBUG
                UIApplication.shared.keyWindow?.rootViewController = KPBaseTabBarController()
            #else
                self.showAD()
            #endif
            
            if isAdoma == false {
                
                KPUser.share.autoLogin()
                
                self.checkVersion(json)
            }
        }
    }
    
    func checkVersion(_ json: JSON) {
        
        if json["needUpgrade"].boolValue {
                
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
        
    }
    
    func showAD() {
        
        splashAd?.delegate = self
        
        UIGraphicsBeginImageContextWithOptions(bg.bounds.size, false, 0)
        
        bg.layer.render(in: UIGraphicsGetCurrentContext()!)
        
        guard let adImage = UIGraphicsGetImageFromCurrentImageContext()
            else {
                return
        }
        //测试自动打包
        splashAd?.backgroundColor = UIColor.init(patternImage: adImage)
        
        splashAd?.loadAndShow(in: UIApplication.shared.keyWindow)
        
        UIApplication.shared.keyWindow?.rootViewController = KPBaseTabBarController()
        
        defer {
            UIGraphicsEndImageContext()
        }
    }
    
    func splashAdSuccessPresentScreen(_ splashAd: GDTSplashAd!) {
        
    }
    
    func splashAdFail(toPresent splashAd: GDTSplashAd!, withError error: Error!) {
        print(error)
    }
    

}
