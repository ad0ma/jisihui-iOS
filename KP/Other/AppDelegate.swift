//
//  AppDelegate.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/23.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GeTuiSdkDelegate /*, GDTSplashAdDelegate*/ {

    var window: UIWindow?
    
    var adWindow = UIView.init(frame: UIScreen.main.bounds)
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        
        window?.backgroundColor = .white

        //MARK: iOS11统一适配
        if #available(iOS 11, *) {
            UIScrollView.appearance().contentInsetAdjustmentBehavior = .never
            UITableView.appearance().estimatedRowHeight = 0
            UITableView.appearance().estimatedSectionHeaderHeight = 0
            UITableView.appearance().estimatedSectionFooterHeight = 0
        }
        
        IQKeyboardManager.shared.enable = true
        
        window?.rootViewController = KPLaunchController()
        
        window?.makeKeyAndVisible()
        
        //友盟统计
        if let umConfig =  UMAnalyticsConfig.sharedInstance() {
            umConfig.appKey = "592791b675ca356a8500031f"
            umConfig.bCrashReportEnabled = false
            MobClick.start(withConfigure: umConfig)
        }
        
        //听云
        NBSAppAgent.start(withAppID: "c44760a2da414b6186ad94add1da5970")
        
        //Bugly
        Bugly.start(withAppId: kBuglyAppId)
        
        //个推
        GeTuiSdk.start(withAppId: kGtAppId, appKey: kGtAppKey, appSecret: kGtAppSecret, delegate: self)
        
        //注册推送
        registerRemoteNotification()
        
//        if isIphone4 {
//            print("isIphone4")
//        } else if isIphone5_5C_5S_SE {
//            print("isIphone5_5C_5S_SE")
//        } else if isIphone678_6S7S8S {
//            print("isIphone678_6S7S8S")
//        } else if isIphonePlus {
//            print("isIphonePlus")
//        } else if isIphoneX {
//            print("isIphoneX")
//        } else {
//            print("other")
//        }
        return true
    }
    
    func registerRemoteNotification() {
        
        let types: UIUserNotificationType = [.alert, .sound, .badge]
        let settings = UIUserNotificationSettings.init(types: types, categories: nil)
        UIApplication.shared.registerForRemoteNotifications()
        UIApplication.shared.registerUserNotificationSettings(settings)
    }
    
    /** 远程通知注册成功委托 */
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let token = NSData.init(data: deviceToken).description.trimmingCharacters(in: CharacterSet.init(charactersIn: "<>")).replacingOccurrences(of: " ", with: "")
                
        // 向个推服务器注册deviceToken
        GeTuiSdk.registerDeviceToken(token)
    }
    
    /** 统计APNs通知的点击数 */
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        GeTuiSdk.handleRemoteNotification(userInfo)
        completionHandler(.newData)
    }
    
    func geTuiSdkDidReceivePayloadData(_ payloadData: Data!, andTaskId taskId: String!, andMsgId msgId: String!, andOffLine offLine: Bool, fromGtAppId appId: String!) {
        
        guard let data = payloadData, let json = try? JSON.init(data: data) else {
            return
        }
                
        //handle json
        print(json)
    }
    
    /** SDK启动成功返回cid */
    func geTuiSdkDidRegisterClient(_ clientId: String!) {
        print(clientId)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        GDTTrack.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}


