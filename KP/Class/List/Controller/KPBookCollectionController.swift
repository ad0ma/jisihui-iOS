//
//  KPBookCollectionController.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/29.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON

class KPBookCollectionController: KPBaseTableViewController,KPNetWorkProtocol, YBPopupMenuDelegate {
    
    var data: [KPListModel]?
    
    var currentPage = 1
    
    var sortType = 1 //1时间 2热度
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "精品书单"
        
        tableView.separatorStyle = .none
        tableView.contentInset = UIEdgeInsetsMake(5, 0, 5, 0)
        tableView.rowHeight = 160
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = Content_Color
        tableView.registerReusableCell(KPBookCollectionCell.self)
        
        edgesForExtendedLayout = [.left, .right]
        
        let sortButton = UIButton.init(type: .custom)
        sortButton.setImage(#imageLiteral(resourceName: "sort_icon"), for: .normal)
        sortButton.addTarget(self, action: #selector(sort(sender:)), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: sortButton)
        
        tableView.spr_setIndicatorHeader {
            self.updateData()
        }
        
        tableView.spr_setIndicatorFooter {
            self.loadMoreData()
        }
        
        tableView.spr_headerEnable()
        tableView.spr_beginRefreshing()
    }
    
    @objc func sort(sender: UIControl) {
        let pop = YBPopupMenu.showRely(on: sender, titles: ["按时间排序", "按热度排序"], icons: ["sort_time", "sort_hot"], badges: [], menuWidth: 145, delegate: self)
        pop?.isShadowShowing = true
        pop?.type = .dark
    }
    
    func ybPopupMenuDidSelected(at index: Int, ybPopupMenu: YBPopupMenu!) {
        sortType = index + 1
        tableView.spr_beginRefreshing()
    }
    
    func getData(callback: @escaping CALLBACK) {
        KPNetWork.request(path: "m/booklist/page/\(sortType)/\(currentPage)", method: .get) { (result) in
            
            guard let data = result.data else {
                return
            }
            
            if result.response?.statusCode == 200, let json = try? JSON.init(data: data) {
                
                let listArr = json.arrayValue.compactMap({ (modeJson) -> KPListModel? in
                    return KPListModel.init(json: modeJson)
                })
                
                callback(listArr,true)
            } else {
                callback(nil,false)
            }
            
        }
    }
    
    func updateData() {
        currentPage = 1
        getData { (listArr, success) in
            
            self.data = listArr as? [KPListModel]
            
            if success {
                self.tableView.reloadData()
                self.tableView.spr_headerEndRefreshing()
                self.tableView.spr_footerEnable()
            }
        }
    }
    
    func loadMoreData() {
        currentPage += 1
        getData { (listArr, success) in
            
            guard let listArr = listArr as? [KPListModel] else {
                return
            }
            
            if listArr.last?.listId == self.data?.last?.listId {
                
                self.tableView.spr_footerEndRefreshing(true)
                
            } else {
                
                self.data! += listArr
                
                if success {
                    self.tableView.reloadData()
                    self.tableView.spr_footerEndRefreshing()
                }
            }
        }
    }
    
    //MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let bookCollection = tableView.dequeueReusableCell(indexPath: indexPath) as KPBookCollectionCell
        
        bookCollection.disPlay(data: data?[indexPath.row])
        
        return bookCollection
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let bookList = KPBookListController.instance
        
        bookList.kp_self.title = data?[indexPath.row].title
        
        (bookList.kp_self as! KPBookListController).entryType = .collection(data![indexPath.row].listId)
        
        navigationController?.pushViewController(bookList, animated: true)
    }
    
}
