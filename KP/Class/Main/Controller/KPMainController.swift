//
//  KPMainController.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/23.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON

class KPMainController: KPBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var mainTable: UITableView! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "集思会"
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: #imageLiteral(resourceName: "ic_search"), style: .plain, target: self, action: #selector(searchAction))
        
        let rect = CGRect.init(x: 0, y: kLayoutNavH, width: Main_Screen_Width, height: Main_Screen_Height - kLayoutTabH - kLayoutNavH)
        
        mainTable = UITableView.init(frame: rect, style: .grouped)
        
        mainTable.separatorStyle = .none
        mainTable.showsVerticalScrollIndicator = false
        mainTable.backgroundColor = Content_Color
        
        mainTable.registerReusableCell(KPMainEntryCell.self)
        mainTable.registerReusableCell(KPMainBooksCell.self)
        mainTable.estimatedSectionFooterHeight = 0
        mainTable.estimatedSectionHeaderHeight = 0

        
        view.addSubview(mainTable)
        
        mainTable.spr_setIndicatorHeader {
            self.getMainData()
        }
        
        mainTable.spr_headerEnable()
        mainTable.spr_beginRefreshing()
    }
    
    var homeModel: KPHomeModel?
    
    func getMainData() -> Void {
        
        KPNetWork.request(path: "app/getIndexInfo", method: .get) { (result) in
            
            if result.response?.statusCode == 200 {
                
                guard let data = result.data else {
                    return
                }
                
                if result.response?.statusCode == 200, let json = try? JSON.init(data: data) {
                                        
                    self.homeModel = KPHomeModel.init(json: json)
                    
                    self.addBanner()
                    
                    self.mainTable.delegate = self as UITableViewDelegate
                    self.mainTable.dataSource = self as UITableViewDataSource
                    
                    self.mainTable.reloadData()
                    
                }
                
            } 
            self.mainTable.spr_headerEndRefreshing()
        }
    }
    
    //MARK: header
    func addBanner() -> Void {
        
        self.mainTable.tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Main_Screen_Width, height: 0.01))
        
        guard let banners = self.homeModel?.picturesNames,
            isAdoma == false else {
            return
        }
        
        let header = KPMainHeaderScrollView.init(images: banners)
        
        header.tapBlock = {[unowned self] idx in
            
            if let pictureModel = self.homeModel?.pictureList[idx], pictureModel.contentType != nil {
                
                switch pictureModel.contentType! {
                    
                case .web:
                    let activity = KPWebViewController.instance
                    activity.kp_self.title = "读书活动"
                    (activity.kp_self as! KPWebViewController).urlStr = pictureModel.contentValue
                    self.navigationController?.pushViewController(activity, animated: true)
                    
                case .booklist:
                    
                    if let collecIdStr = pictureModel.contentValue,
                       let collecIdInt = Int.init(collecIdStr)  {
                        
                        let bookList = KPBookListController.instance
                        
                        (bookList.kp_self as! KPBookListController).entryType = .collection(collecIdInt)
                        
                        self.navigationController?.pushViewController(bookList, animated: true)
                    }
                }
                
            }
            
            
        }
        
        self.mainTable.tableHeaderView = header
    }
    
    //MARK: search action
    @objc func searchAction() -> Void {
        let search = KPMainSearchController.instance
        self.navigationController?.pushViewController(search, animated: true)
    }
    
    //MARK: UITableViewDelegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.01
            
//        case 1:
//            return 50
            
        default:
            return 70
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    
        let header = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Main_Screen_Width, height: 70))
        header.backgroundColor = .clear
        
        let detail = UIView.init(frame: CGRect.init(x: 0, y: 20, width: Main_Screen_Width, height: 50))
        detail.backgroundColor = .white
        
        header.addSubview(detail)
        
        
        let title = UILabel.init()
        title.font = UIFont.boldSystemFont(ofSize: 15)
        title.textColor = Main_Text_Color
        detail.addSubview(title)
        
        title.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
        }
        
        let more = UIButton.init()
        more.setTitle("更多>>", for: .normal)
        more.setTitleColor(Main_Theme_Color, for: .normal)
        more.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        more.tag = section + 100
        more.addTarget(self, action: #selector(tapHeaderMore(sender:)), for: .touchUpInside)
        detail.addSubview(more)
        
        more.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
        
        let line = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Main_Screen_Width, height: 0.5))
        line.backgroundColor = Line_Color
        detail.addSubview(line)
        
        switch section {
        case 0:
            return nil
            
        case 1:
            title.text = "精品图书"
            
        case 2:
            title.text = "随便看看"
            
        case 3:
            title.text = "最新上架"
            
        default:
            break
        }
        
        return header
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return homeModel?.goodList.count ?? 0
        case 2:
            return homeModel?.hotList.count ?? 0
        case 3:
            return homeModel?.newList.count ?? 0
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 80
        default:
            return 185
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var books: [KPBookModel]?
        
        switch indexPath.section {
        case 0:
            let entryCell = tableView.dequeueReusableCell(indexPath: indexPath) as KPMainEntryCell
            
            entryCell.entryBlock = { entryType in
                
                switch entryType {
                case .rank:
                    let rank = KPRankListController.instance
                    self.navigationController?.pushViewController(rank, animated: true)
                    break
                    
                case .category:
                    self.tabBarController?.selectedIndex = 1
                    break
                    
                case .list:
                    self.tabBarController?.selectedIndex = 2
                    break
                    
                case .activity:
                    let activity = KPWebViewController.instance
                    activity.kp_self.title = "读书活动"
                    (activity.kp_self as! KPWebViewController).urlStr = "http://www.jisihui.com/main/activity"
                    self.navigationController?.pushViewController(activity, animated: true)
                    break
                }
            }
            
            return entryCell
            
        case 1:
            books = homeModel?.goodList[indexPath.row]
            
        case 2:
            books = homeModel?.hotList[indexPath.row]
            
        case 3:
            books = homeModel?.newList[indexPath.row]
            
        default:
            break
        }
        
        let booksCell = tableView.dequeueReusableCell(indexPath: indexPath) as KPMainBooksCell
        
        booksCell.disPlay(data: books)
        
        booksCell.selectBlock = { bookIdx in
            
            if (books?.count)! > bookIdx {
                
                let bookInfo = KPBookInfoController.instance
                
                (bookInfo.kp_self as! KPBookInfoController).bookId = books![bookIdx].id!
                
                self.kp_navigationController?.pushViewController(bookInfo, animated: true)
                
            }
            
        }
        
        return booksCell
    }
    
    //MARK: touch section's more
    @objc func tapHeaderMore(sender: UIButton) {
        let section = sender.tag - 100
        
        let bookList = KPBookListController.instance
        switch section {
        case 1:
            bookList.kp_self.title = "精品图书"
            (bookList.kp_self as! KPBookListController).entryType = .home(.good)
            break
            
        case 2:
            bookList.kp_self.title = "随便看看"
            (bookList.kp_self as! KPBookListController).entryType = .home(.hot)
            break
            
        case 3:
            bookList.kp_self.title = "最新上架"
            (bookList.kp_self as! KPBookListController).entryType = .home(.new)
            break
            
        default:
            break
        }
        navigationController?.pushViewController(bookList, animated: true)
    }

}
