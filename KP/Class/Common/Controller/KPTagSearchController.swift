//
//  KPTagSearchController.swift
//  KP
//
//  Created by Adoma on 2017/11/1.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON

class KPTagSearchController: KPBaseTableViewController, KPNetWorkProtocol {
    
    var currentPage = 1
    
    var tag: String = "我是标签" {
        didSet {
            self.title = tag
            tableView.spr_headerEnable()
            tableView.spr_beginRefreshing()
        }
    }
    
    var books: [KPBookModel] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none

        tableView.registerReusableCell(KPBookInfoNoDetailCell.self)
        
        tableView.rowHeight = 150
        tableView.contentInset = UIEdgeInsetsMake(5, 0, kLayoutBottom, 0)
        
        tableView.spr_setIndicatorHeader {
            self.updateData()
        }
        
        tableView.spr_setIndicatorFooter {
            self.loadMoreData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return books.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let bookInfoCell = tableView.dequeueReusableCell(indexPath: indexPath) as KPBookInfoNoDetailCell
        
        bookInfoCell.disPlay(data: books[indexPath.row])
        
        return bookInfoCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let bookInfo = KPBookInfoController.instance
        
        bookInfo.kp_self.title = books[indexPath.row].name
        
        (bookInfo.kp_self as! KPBookInfoController).bookId = books[indexPath.row].id!
        
        self.navigationController?.pushViewController(bookInfo, animated: true)
    }

    func getData(callback: @escaping CALLBACK) {
        
        guard let ecode = tag.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return
        }

        KPNetWork.request(path: "app/tags/\(ecode)/\(currentPage)", method: .get) { (result) in
            
            guard let data = result.data else {
                return
            }
            
            if result.response?.statusCode == 200, let json = try? JSON.init(data: data) {
                
                let listArr = json["resData"].arrayValue.compactMap({ (bookJson) -> KPBookModel? in
                    return KPBookModel.init(json: bookJson)
                })
                
                callback(listArr,true)
            } else {
                callback(result.error,false)
            }
        }
    }
    
    func updateData() {
        currentPage = 1
        tableView.spr_footerRest()
        tableView.spr_footerEnable()
        
        getData { (data, success) in
            guard let data = data else {
                return
            }
            
            if success, let bookArr = data as? [KPBookModel] {
                self.books.removeAll()
                self.books.append(contentsOf: bookArr)
                
                self.reload()
            } else {
                KPHud.showText(text: (data as! NSError).domain)
            }
            
            defer {
                self.tableView.spr_headerEndRefreshing()
            }
        }
    }
    
    func loadMoreData() {
        
        //如果第8页没数据，会把第七页的数据请求下来
        currentPage += 1
        
        getData { (data, success) in
            
            guard let data = data else {
                self.tableView.spr_footerEndRefreshing()
                return
            }
            
            if success, let bookArr = data as? [KPBookModel] {
                
                self.books.append(contentsOf: bookArr)
                self.reload()
                
            } else {
                KPHud.showText(text: (data as! NSError).domain)
            }
            
            if self.currentPage * 7 > self.books.count {
                self.tableView.spr_footerEndRefreshing(true)
            } else {
                self.tableView.spr_footerEndRefreshing()
            }
        }

    }
    
    func reload() {
        self.tableView.reloadData()
    }

}
