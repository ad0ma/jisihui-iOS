//
//  KPBookListController.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/27.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON

class KPBookListController: KPBaseTableViewController,KPNetWorkProtocol {
    
    var books: [KPBookModel]?
    
    var currentPage = 1
    
    enum HomeType: String {
        case hot = "HOT"
        case good = "GOOD"
        case new = "NEW"
    }
    
    enum BookListEntry {
        case collection(Int) //书单
        case category(Int)   //书城
        case home(HomeType)  //首页更多
    }
    
    var entryType = BookListEntry.collection(0) {
        didSet {
            self.tableView.spr_headerEnable()
            self.tableView.spr_beginRefreshing()
        }
    }
    
    func getData(callback: @escaping CALLBACK) {
        
        switch entryType {
        case .collection(let listId):
            getBookListInfo(listId: listId, callback: callback)
            
        case .category(let categoryId):
            getCategoryBookList(categoryId: categoryId, callback: callback)
            
        case .home(let homeType):
            getHomeMoreBooks(homeTpye: homeType, callback: callback)
        }
        
    }
    
    //分类
    func getCategoryBookList(categoryId: Int, callback: @escaping CALLBACK) -> Void {
        
        KPNetWork.request(path: "m/good/c/\(categoryId)/\(currentPage)", method: .get) { (result) in
            
            guard let data = result.data else {
                return
            }
            
            if result.response?.statusCode == 200, let json = try? JSON.init(data: data) {
                
                let listArr = json.arrayValue.compactMap({ (bookJson) -> KPBookModel? in
                    return KPBookModel.init(json: bookJson)
                })
                
                callback(listArr,true)
            } else {
                callback(nil,false)
            }
        }
    }
    
    //书单
    func getBookListInfo(listId: Int, callback: @escaping CALLBACK) -> Void {
        
        KPNetWork.request(path: "m/booklist/\(listId)", method: .get) { (result) in
            
            guard let data = result.data else {
                return
            }
            
            if result.response?.statusCode == 200, let json = try? JSON.init(data: data) {
                
                let bookListModel = KPListModel.init(json: json)
                
                self.title = bookListModel.title
                
                let listArr = bookListModel.bookList
                
                callback(listArr,true)
            } else {
                callback(nil,false)
            }
        }
    }
    
    //首页更多
    func getHomeMoreBooks(homeTpye: HomeType, callback: @escaping CALLBACK) -> Void {
        KPNetWork.request(path: "app/getMore?type=\(homeTpye.rawValue)&page=\(currentPage)&pageSize=20", method: .get) { (result) in
            
            guard let data = result.data else {
                return
            }
            
            if result.response?.statusCode == 200, let json = try? JSON.init(data: data) {
                                
                let bookListJson = json["bookList"].arrayValue
                
                let listArr = bookListJson.map{KPBookModel.init(json: $0)}
                
                callback(listArr,true)
            } else {
                callback(nil,false)
            }
        }
    }
    
    func updateData() {
        self.currentPage = 1
            
        getData { [unowned self] (data, success) in
            self.books = data as? [KPBookModel]
            self.tableView.reloadData()
            self.tableView.spr_headerEndRefreshing()
            
            switch self.entryType {
            case .category, .home:
                self.tableView.spr_footerEnable()
                
            default:
                break
            }
        }
    }
    
    func loadMoreData() {
        self.currentPage += 1
        
        getData { [unowned self] (data, success) in
            
            guard let newData = data as? [KPBookModel],
                newData.count > 0 else {
                    self.tableView.spr_footerEndRefreshing(true)
                    return
            }
            
            self.books! += newData
            
            if success {
                self.tableView.reloadData()
                self.tableView.spr_footerEndRefreshing()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = Content_Color
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.registerReusableCell(KPBookInfoCell.self)
        tableView.registerReusableCell(KPBookInfoNoDetailCell.self)
        tableView.rowHeight = 160
        tableView.contentInset = UIEdgeInsetsMake(5, 0, kLayoutBottom, 0)
        
        tableView.spr_setIndicatorHeader {
            self.updateData()
        }
        
        tableView.spr_setIndicatorFooter {
            self.loadMoreData()
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return books?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch entryType {
            
        case .collection:
            let bookInfoCell = tableView.dequeueReusableCell(indexPath: indexPath) as KPBookInfoCell
            
            bookInfoCell.disPlay(data: books?[indexPath.row])
            
            return bookInfoCell
            
        case .home, .category:
            let bookNoDetailCell = tableView.dequeueReusableCell(indexPath: indexPath) as KPBookInfoNoDetailCell
            
            bookNoDetailCell.disPlay(data: books?[indexPath.row])
            
            return bookNoDetailCell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let bookInfo = KPBookInfoController.instance
        
        bookInfo.kp_self.title = books?[indexPath.row].name
        
        (bookInfo.kp_self as! KPBookInfoController).bookId = books![indexPath.row].id!
        
        self.navigationController?.pushViewController(bookInfo, animated: true)
    }

}
