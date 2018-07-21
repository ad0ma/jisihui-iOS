//
//  KPIdeaHistoryController.swift
//  KP
//
//  Created by Adoma on 2018/6/3.
//  Copyright © 2018年 adoma. All rights reserved.
//

class KPIdeaHistoryController: KPBaseTableViewController {
    
    var data: [KPIdeaModel]?
    
    var currentPage = 1
    var totalPage = 0
    
    var deleteEnable = false
    
    
    override func viewDidLoad() {
        title = "我的想法"
        
//        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsetsMake(0, 40, 0, 0)
        tableView.estimatedRowHeight = 180
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = Content_Color
        tableView.registerReusableCell(KPIdeaHistoryCell.self)
        
        edgesForExtendedLayout = [.left, .right]
        
        tableView.spr_setIndicatorHeader {
            self.updateData()
        }
        
        tableView.spr_setIndicatorFooter {
            self.loadMoreData()
        }
        
        tableView.spr_headerEnable()
        tableView.spr_beginRefreshing()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "删除", style: .plain, target: self, action: #selector(deleteState))
    }
    
    @objc func deleteState() {
        deleteEnable = !deleteEnable
        navigationItem.rightBarButtonItem?.title = deleteEnable ? "完成" : "删除"
        tableView.reloadData()
    }
    
    func getData(callback: @escaping CALLBACK) {
        
        KPNetWork.request(path: "/m/auth/idea/my/page?page=\(currentPage)", method: .get) { (result) in
            
            guard let data = result.data else {
                return
            }
            
            if let json = try? JSON.init(data: data), json["code"].string == "success" {
                
                let listArr = json["data"].arrayValue.compactMap(KPIdeaModel.init)
                
                self.totalPage = json["totalPage"].intValue
                
                callback(listArr,true)
                
            } else {
                callback(nil,false)
            }
            
        }
    }
    
    func updateData() {
        currentPage = 1
        getData { (listArr, success) in
            
            self.data = listArr as? [KPIdeaModel]
            
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
            
            guard let listArr = listArr as? [KPIdeaModel] else {
                return
            }
            
            if self.currentPage > self.totalPage {
                
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
        
        let ideaCell = tableView.dequeueReusableCell(indexPath: indexPath) as KPIdeaHistoryCell
        
        ideaCell.canDelete = deleteEnable
        ideaCell.disPlay(data: data?[indexPath.row])
        ideaCell.delegate = self
        
        return ideaCell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        guard let ideaCell = cell as? KPIdeaHistoryCell else {
            return
        }
        
        ideaCell.topLine.isHidden = indexPath.row == 0
        ideaCell.bottomLine.isHidden = (indexPath.row + 1) == data!.count
    }
    
}

extension KPIdeaHistoryController: KPIdeaHistoryCellDelegate {
    
    func selectedBook(id: String) {
        let bookInfo = KPBookInfoController.instance
        (bookInfo.kp_self as! KPBookInfoController).bookId = id
        self.navigationController?.pushViewController(bookInfo, animated: true)
    }
    
    func readAllAction(id: Int) {
        guard let history = data, let idx = history.index(where: {$0.id == id}) else {
            return
        }
        data![idx].readAll = !data![idx].readAll
        tableView.reloadData()
    }
    
    func deleteIdea(ideaId: Int) {
        KPNetWork.request(path: "m/auth/idea/\(ideaId)", method: .delete) { (result) in
            
            if result.response?.statusCode == 200 {
                guard let data = result.data else {
                    return
                }
                if let json = try? JSON.init(data: data) {
                    print(json)
                    KPHud.showText(text: "想法删除成功!", delay: 1)
                    self.tableView.setContentOffset(.zero, animated: false)
                    self.tableView.spr_beginRefreshing()
                }
            }
        }
    }
    
    func deleteAction(id: Int) {
        let alert = UIAlertController.init(title: nil, message: "确定删除该想法吗?", preferredStyle: .alert)
        let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancel)
        let push = UIAlertAction.init(title: "确定", style: .default, handler: { (_) in
            self.deleteIdea(ideaId: id)
        })
        alert.addAction(push)
        self.present(alert, animated: true, completion: nil)
    }
}
