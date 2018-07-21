//
//  KPModel.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/6/7.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON

struct KPBookModel {
    
    var selected = false
    
    var dateFormat: DateFormatter {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm"
        return format
    }
    
    var name: String?
    var content: String?
    var readAll: Bool = false
    
    var tags: String?
    var tagArr: [String]?
    
    var enable: Bool = false
    var author: String?
    var rank: Float?
    var doubanScore: String {
        
        if let f = rank, f > 0 {
            return String.init(format: "%.1f", f)
        }
        
        return "暂无评分"
    }
    
    var createDate: Date?
    var creatDateFormat: String? {
        if createDate == nil {
            return nil
        }
        return dateFormat.string(from: createDate!)
    }
    
    var imgUrl: String?
    
    var id: String?
    
    var pushTime: Date?
    var pushTimeFormat: String? {
        if pushTime == nil {
            return nil
        }
        return dateFormat.string(from: pushTime!)
    }
    
    var collectTime: Date?
    var collectTimeFormat: String? {
        if collectTime == nil {
            return nil
        }
        return dateFormat.string(from: collectTime!)
    }
    
    init(json: JSON) {
        
        name = json["name"].string
        content = json["content"].string
        
        if let tag = json["tags"].string as NSString? {
            
            tags = tag.substring(with: NSRange.init(location: 1, length: tag.length - 2))
            
            tagArr = tags?.components(separatedBy: ",")
        }
        
        enable = json["enable"].boolValue
        author = json["author"].string
        rank = json["doubanScore"].float
        
        if let creat = json["createDate"].double {
            createDate = Date.init(timeIntervalSince1970: creat/1000)
        }
        
        id = json["id"].stringValue
        imgUrl = json["imgUrl"].string
    }
    
}

struct KPListModel {
    
    var listId: Int
    var title: String
    var dateText: String
    var content: String
    var imgUrl: String
    var bookList: [KPBookModel]?
    var authorName: String
    
    
    init(json: JSON) {
        
        listId = json["id"].intValue
        title = json["title"].stringValue
        dateText = json["dateText"].stringValue
        content = json["content"].stringValue
        imgUrl = json["imgUrl"].stringValue
        authorName = json["authorName"].stringValue
        
        if let bookListJson = json["bookList"].array {
           bookList = bookListJson.compactMap({ (bookJson) -> KPBookModel? in
                return KPBookModel.init(json: bookJson)
            })
        }
    }
}

struct KPBookStatuModel {
    
    enum KPBookStatus: String {
        case none = "DEFAULT"
        case toRead = "TOREAD"
        case reading = "READING"
        case readed = "READED"
    }
    
    var status: KPBookStatus = .none
    
    var book: KPBookModel
    
    init(json: JSON) {

        if let statu = KPBookStatus.init(rawValue: json["bookStatus"].stringValue) {
            status = statu
        }
        
        book = KPBookModel.init(json: json["book"])
    }
}

struct KPHomePictureModel {
    
    enum PictureType: String {
        case web = "web"
        case booklist = "booklist"
    }
    
    var contentType: PictureType?
    var contentValue: String?
    var picUrl: String

    init(json: JSON) {
        
        contentType = PictureType.init(rawValue: json["contentType"].stringValue)
        contentValue = json["contentValue"].stringValue
        picUrl = json["picUrl"].stringValue
    }
}

struct KPHomeModel {
    
    var newList: [[KPBookModel]] = []
    var hotList: [[KPBookModel]] = []
    var goodList: [[KPBookModel]] = []
    
    var pictureList: [KPHomePictureModel] = []
    
    var picturesNames: [String]? {
        if pictureList.count == 0 {
            return nil
        }
        
        return pictureList.map{ $0.picUrl }
    }
    
    
    init(json: JSON) {
        
        //new
        if let newBooks = json["newBookList"].array {
            
            newList = newBooks.enumerated().filter{ $0.offset % 3 == 0}.map({ (m: (offset: Int, element: JSON)) -> [KPBookModel] in
            
                var temp = [KPBookModel]()
                
                for idx in 0..<3 {
                    
                    let index = m.offset + idx
                    
                    if index >= newBooks.count { break }
                    
                    let newBook = KPBookModel.init(json: newBooks[index])
                    temp.append(newBook)
                }
                
                return temp
            })
            
        }
        
        //hot
        if let hotBooks = json["hotBookList"].array {
            
            hotList = hotBooks.enumerated().filter{ $0.offset % 3 == 0}.map({ (m: (offset: Int, element: JSON)) -> [KPBookModel] in
                
                var temp = [KPBookModel]()
                
                for idx in 0..<3 {
                    
                    let index = m.offset + idx
                    
                    if index >= hotBooks.count { break }
                    
                    let hotBook = KPBookModel.init(json: hotBooks[index])
                    temp.append(hotBook)
                }
                
                return temp
            })
            
        }
        
        //good
        if let goodBooks = json["goodBookList"].array {
            
            goodList = goodBooks.enumerated().filter{ $0.offset % 3 == 0}.map({ (m: (offset: Int, element: JSON)) -> [KPBookModel] in
                
                var temp = [KPBookModel]()
                
                for idx in 0..<3 {
                    
                    let index = m.offset + idx
                    
                    if index >= goodBooks.count { break }
                    
                    let goodBook = KPBookModel.init(json: goodBooks[index])
                    temp.append(goodBook)
                }
                
                return temp
            })
        }
        
        //picture
        if let pictures = json["pictureList"].array {
            pictureList = pictures.map{KPHomePictureModel.init(json: $0)}
        }
        
    }
}

struct KPPayInfoModel {
    
    var description: String?
    var sale = false //是否打折
    var originMoney: String?
    var realMoney: String?
    var type: String?
    
    init(json: JSON) {
        
        description = json["description"].string
        sale = json["sale"].boolValue
        originMoney = json["originMoney"].stringValue
        realMoney = json["realMoney"].stringValue
        type = json["type"].stringValue
    }
}

//想法
struct KPIdearModel {
    
    var id: String?
    var authorName: String?
    var content: String?
    var commentCount: Int?
    var ideaCommentViewList: [KPIdearCommentModel]?
    
    init(json: JSON) {
        
        id = json["id"].stringValue
        authorName = json["authorName"].stringValue
        content = json["content"].stringValue
        commentCount = json["commentCount"].intValue
        
        if let ideaCommentViewListJson = json["ideaCommentViewList"].array {
            
            ideaCommentViewList = ideaCommentViewListJson.compactMap({ (ideaCommentJson) -> KPIdearCommentModel? in
                return KPIdearCommentModel.init(json: ideaCommentJson)
            
            })
        }
        
    }
    
    
}

//想法评论
struct KPIdearCommentModel {
    
    var id: String?
    var authorName: String?
    var content: String?
    var dateText: String?
    
    init(json: JSON) {
        
        id = json["id"].stringValue
        authorName = json["authorName"].stringValue
        content = json["content"].stringValue
        dateText = json["dateText"].stringValue
    }
    
}
//用户
struct KPUserModel {
    
    var id: String?
    var nickName: String?
    
    init(json: JSON) {
        
        id = json["id"].stringValue
        nickName = json["nickName"].stringValue
        
    }
    
}

