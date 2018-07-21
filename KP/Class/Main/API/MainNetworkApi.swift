//
//  MainNetworkApi.swift
//  KP
//
//  Created by yll on 2018/3/12.
//  Copyright © 2018年 adoma. All rights reserved.
//

extension KPNetWork {
    
    
    /// 大家都在搜接口
    @discardableResult
    static func requestSearchHot(closure: @escaping (JSON) -> Void) -> DataRequest {
        
        #if DEBUG
             let base = "http://139.224.12.154:8080/"
        #else
             let base = "https://www.jisihui.com/"
        #endif
        
        return request(base: base, path: "m/search/hot", method: .get, closure: { (result) in
            
            guard let data = result.data else {
                return
            }
            
            closure(JSON.init(data))
        })
    }
    
    /// 书籍
    @discardableResult
    static func requestSearchBook(path: String, closure: @escaping (JSON) -> Void) -> DataRequest {
        
        #if DEBUG
            let base = "http://139.224.12.154:8080/"
        #else
            let base = "https://www.jisihui.com/"
        #endif
        
        return request(base: base, path: path, method: .get, closure: { (result) in
            
            guard let data = result.data else {
                return
            }
            
            closure(JSON.init(data))
        })
    }
    
}
