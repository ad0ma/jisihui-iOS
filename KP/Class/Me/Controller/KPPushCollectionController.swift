//
//  KPPushCollectionController.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/6/5.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON

class KPPushCollectionController: KPBaseTableViewController, KPNetWorkProtocol {

    enum ControllerType: String {
        case collect = "collect"
        case push = "push"
    }
    
    var type = ControllerType.collect {
        didSet {
            
            switch type {
            case .collect:
                title = "收藏"
            case .push:
                title = "推送记录"
            }
            self.tableView.spr_beginRefreshing()
        }
    }
    
    var books: [KPBookModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.rowHeight = kp_layout(115)
        tableView.registerReusableCell(KPPushCollectionCell.self)
        
        tableView.spr_setIndicatorHeader {
            self.updateData()
        }
        self.tableView.spr_headerEnable()

    }
    
    func updateData() {
        
        getData { (data, success) in
            
            if let data = data {
                
                let json = JSON(data)
                
                self.books = json.compactMap({ (idx: (String, JSON)) -> KPBookModel? in
                    
                    let bookJson = idx.1
                    let bookInfo = bookJson["book"]
                    
                    if bookInfo.type != .dictionary {
                        return nil
                    }
                    
                    var book = KPBookModel.init(json: bookInfo)
                    
                    if let pushT = bookJson["pushDate"].double {
                        book.pushTime = Date.init(timeIntervalSince1970: pushT/1000)
                    }
                    
                    if let collectT = bookJson["time"].double {
                        book.collectTime = Date.init(timeIntervalSince1970: collectT/1000)
                    }
                    
                    return book
                })
                
                self.tableView.reloadData()
                self.tableView.spr_headerEnable()
                self.tableView.spr_headerEndRefreshing()
            }
        }
    }
    
    func getData(callback: @escaping (Any?, Bool) -> Void) {
        
        KPNetWork.request(path: ("m/auth/" + type.rawValue)) { (res) in
            
            if res.response?.statusCode == 200,
                let data = res.data {
                callback(data, true)
            } else {
                callback(nil, false)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.spr_beginRefreshing()
    }
    
    func loadMoreData() {}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let pushCollection = tableView.dequeueReusableCell(indexPath: indexPath) as KPPushCollectionCell
        
        pushCollection.bookModel = books?[indexPath.row]
        
        return pushCollection
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let id = books?[indexPath.row].id else {
            return
        }
        
        let bookInfo = KPBookInfoController.instance
        
        (bookInfo.kp_self as! KPBookInfoController).bookId = id
        
        self.navigationController?.pushViewController(bookInfo, animated: true)
    }
}
