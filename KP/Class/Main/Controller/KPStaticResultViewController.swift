//
//  KPStaticResultViewController.swift
//  KP
//
//  Created by yll on 2018/3/15.
//  Copyright © 2018年 adoma. All rights reserved.
//

import UIKit

class KPStaticResultViewController: KPBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    typealias latelySearch = (String, Int)->Void
    
    var latelySearchTextTo: latelySearch?
    
    ///静态搜索页面
    var staticResultTable: UITableView!
    
    var allSearchBookNameArray: [KPBookModel]?
    
    var bookNameArray: [String]?
    
    var latelySearchArr: [String] = []{
        
        didSet {
            self.latelySearckCell = KPAllSearchTableViewCell.init(keys:latelySearchArr )
            self.staticResultTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        staticResultTable = UITableView.init(frame: CGRect.init(x: 0, y: kLayoutNavH , width: Main_Screen_Width, height: Main_Screen_Height - kLayoutNavH), style: .grouped)
        
        staticResultTable.showsVerticalScrollIndicator = false
        
        staticResultTable.backgroundColor = .white
        
        staticResultTable.separatorStyle = .none
        
        staticResultTable.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        staticResultTable.tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 1))//处理 y=35的问题

        staticResultTable.keyboardDismissMode = .onDrag
        
        staticResultTable.registerReusableCell(KPEmptyTableViewCell.self)
        
        view.addSubview(staticResultTable)

        getAllSearchBookName()
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            if self.allSearchBookNameArray?.isEmpty ?? true {
                let empty = tableView.dequeueReusableCell(indexPath: indexPath) as KPEmptyTableViewCell
                empty.tipText = "暂无热门搜索"
                return empty
            }
            return self.bookKeyCell!
        case 1:
            if self.latelySearchArr.isEmpty {
                let empty = tableView.dequeueReusableCell(indexPath: indexPath) as KPEmptyTableViewCell
                empty.tipText = "暂无最近搜索"
                return empty
            }
            return self.latelySearckCell!
            
        default:
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let back = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Main_Screen_Width, height: 40))
        back.backgroundColor = .white

        let title = UILabel.init(frame: CGRect.init(x: 15, y: 0, width: Main_Screen_Width, height: 40))
        back.addSubview(title)
        
        title.text = (section == 1) ? "最近搜索":"大家都在搜"
        title.font = UIFont.systemFont(ofSize: 15)
        title.textColor = Detail_Text_Color
        
        let remove = UIButton.init(frame: CGRect.init(x: Main_Screen_Width - 50, y: 0, width: 40, height: 40))
        remove.setImage(UIImage.init(named: "delete_text"), for: .normal)
        back.addSubview(remove)
        
        remove.addTarget(self, action: #selector(toRemoveSearchText(sender:)), for: .touchUpInside)
        
        switch section {
        case 0:
            remove.isHidden = true
            
        case 1:
            remove.isHidden = self.latelySearchArr.isEmpty
            
        default:
            break
        }

        return back
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            if self.allSearchBookNameArray?.isEmpty ?? true {
                return 40
            }
            return self.bookKeyCell?.kp_height ?? 0
        case 1:
            if self.latelySearchArr.isEmpty {
                return 40
            }
            return self.latelySearckCell?.kp_height ?? 0
            
        default:
            return 0
        }
    
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 1

    }
    
    ///大家都在搜
    var bookKeyCell: KPAllSearchTableViewCell? {
        
        didSet {
            bookKeyCell?.selectTagCallBack = { (text, tag) in
                
                print("text = \(text) + tag = \(tag)")

                let bookInfo = KPBookInfoController.instance

                bookInfo.kp_self.title = self.allSearchBookNameArray?[tag].name

                (bookInfo.kp_self as! KPBookInfoController).bookId = self.allSearchBookNameArray![tag].id!

                self.navigationController?.pushViewController(bookInfo, animated: true)
            }
        }
    }
    
    /// 最近搜索
    var latelySearckCell: KPAllSearchTableViewCell? {
        
        didSet {
            latelySearckCell?.selectTagCallBack = { (text, tag) in
                
                self.latelySearchTextTo?(text, tag)
                
            }
        }
    }
    
    @objc func toRemoveSearchText(sender: UIButton) {
        
        latelySearchArr = KPUserCenter.shareSingTon().removeText()
        self.staticResultTable.reloadData()
        
    }
    
    func getAllSearchBookName() {
        
        KPNetWork.requestSearchHot {[weak self] (json) in
            
            print(json)
            
            self?.allSearchBookNameArray = json.arrayValue.compactMap{KPBookModel.init(json: $0)}
            
            self?.bookNameArray = json.arrayValue.compactMap{KPBookModel.init(json: $0).name}
            
            self?.bookKeyCell = KPAllSearchTableViewCell.init(keys:self?.bookNameArray ?? [] )
            
            self?.staticResultTable.delegate = self
            self?.staticResultTable.dataSource = self
            
            self?.staticResultTable.reloadData()
            
        }
        
    }
}
