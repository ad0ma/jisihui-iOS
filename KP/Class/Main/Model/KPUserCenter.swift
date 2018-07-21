//
//  KPUserCenter.swift
//  KP
//
//  Created by yll on 2018/3/24.
//  Copyright © 2018年 adoma. All rights reserved.
//

import UIKit

class KPUserCenter {

    static let userCenter = KPUserCenter()
    
    private var searchTextArray: [String] = []
    
    private var lastText: String = ""
    
    class func shareSingTon() -> KPUserCenter {
        return userCenter
    }
    
    var searchText: String? {
        
        didSet {
            //先取出上一次保存的，
            self.searchTextArray = myTextArray
            
            //然后新增此次的
            if searchTextArray.contains(searchText ?? "") {
                
            } else {
                self.searchTextArray.append(searchText ?? "")
            }
            
            UserDefaults.standard.set(self.searchTextArray, forKey: APP_USER_SEARCHTEXT_KEY)
            UserDefaults.standard.synchronize()
        }
    }
    
    var myTextArray: [String] {
        get {
            return UserDefaults.standard.array(forKey: APP_USER_SEARCHTEXT_KEY) as? [String] ?? []
        }
    }
    
    func removeText() -> [String] {
        
        self.searchTextArray = []
        
        UserDefaults.standard.set(self.searchTextArray, forKey: APP_USER_SEARCHTEXT_KEY)
        UserDefaults.standard.synchronize()
        
        return self.searchTextArray
        
    }
}
