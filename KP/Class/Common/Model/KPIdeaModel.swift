//
//  KPIdeaModel.swift
//  KP
//
//  Created by Shawley on 2018/4/7.
//  Copyright © 2018 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON

struct KPIdeaModel {
    
    var id: Int
    var nickName: String?
    var content: String?
    var picKey: String?
    var collectsCount: Int
    var likesCount: Int
    var commentsCount: Int
    var viewsCount: Int
    var lastUpdateDate: String?
    var createDate: String?
    
    var avatarUrl: URL?
    
    var readAll: Bool = false
    
    var book: KPBookModel?
    
    init(json: JSON) {
        
        id = json["id"].intValue
        content = json["content"].string
        
        if content?.last == "\n" {
           content = String(content!.dropLast())
        }
        
        let userInfo = json["user"].dictionaryValue
        nickName = userInfo["nickName"]?.stringValue
        if let avatarUrlString = userInfo["originalImageUrl"]?.string {
            avatarUrl = URL.init(string: avatarUrlString)
        }
        
        picKey = json["picture"].string
        
        collectsCount = json["collectsCount"].intValue
        likesCount = json["likesCount"].intValue
        commentsCount = json["commentsCount"].intValue
        viewsCount = json["viewsCount"].intValue
        
        let bookJson = json["book"]
        if bookJson != .null  {
            book = KPBookModel.init(json: bookJson)
        }
        
        //时间戳
        let timeStamp = json["lastUpdateDate"].int ?? json["createDate"].intValue  / 1000
        let timeInterval = TimeInterval(timeStamp)
        let date = Date(timeIntervalSince1970: timeInterval)
        
        let dformatter = DateFormatter()
        dformatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        lastUpdateDate = dformatter.string(from: date)
    }
}


