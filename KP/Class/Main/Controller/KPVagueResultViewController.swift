//
//  KPVagueResultViewController.swift
//  KP
//
//  Created by yll on 2018/3/15.
//  Copyright © 2018年 adoma. All rights reserved.
//

import UIKit

class KPVagueResultViewController: KPBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    //模糊搜索页面
    
    typealias LookMore = (Int)->Void
    
    var selectSectionLookMore: LookMore?
    
    var vagueTable: UITableView!
    
    var currentTask: URLSessionTask?
    
    var searchText: String? {
        didSet {
            startSearchAll()
        }
    }
    
    var booklist: [KPBookModel] = []
    var booklistViewList: [KPListModel] = []
    var ideaViewList: [KPIdearModel] = []
    var userList: [KPUserModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        
        vagueTable = UITableView.init(frame: CGRect.init(x: 0, y: kLayoutNavH , width: Main_Screen_Width, height: Main_Screen_Height - kLayoutNavH), style: .grouped)
        
        vagueTable.showsVerticalScrollIndicator = false
        
        vagueTable.backgroundColor = .white
        
        vagueTable.delegate = self
        
        vagueTable.dataSource = self
        
        vagueTable.separatorStyle = .none
        
        vagueTable.tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 1))
        
        vagueTable.keyboardDismissMode = .onDrag
        
        view.addSubview(vagueTable)
        
        startSearchAll()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            if self.booklist.count > 3 {
                return 3
            }
            return self.booklist.count
        case 1:
            if self.booklistViewList.count > 3 {
                return 3
            }
            return self.booklistViewList.count
        case 2:
            if self.ideaViewList.count > 3 {
                return 3
            }
            return self.ideaViewList.count
        case 3:
            if self.userList.count > 3 {
                return 3
            }
            return self.userList.count
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
        case 0:
            var cell = tableView.dequeueReusableCell(withIdentifier: "vagueCellOne")
            if cell == nil {
                cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "vagueCellOne")
                cell?.selectionStyle = .none
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
                cell?.textLabel?.textColor = Main_Text_Color
                cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 12)
                cell?.detailTextLabel?.textColor = Sub_Text_Color
                cell?.imageView?.image = UIImage.init(named: "tab_book_store_nor")
            }
            
            let bookModel = booklist[indexPath.row]
            cell?.textLabel?.text = bookModel.name
            cell?.detailTextLabel?.text = bookModel.author
            
            return cell!
            
        case 1:
            var cell = tableView.dequeueReusableCell(withIdentifier: "vagueCellTwo")
            if cell == nil {
                cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "vagueCellTwo")
                cell?.selectionStyle = .none
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
                cell?.textLabel?.textColor = Main_Text_Color
            }
            
            let bookListModel = booklistViewList[indexPath.row]
            cell?.textLabel?.text = bookListModel.title
            return cell!
            
        case 2:
            var cell = tableView.dequeueReusableCell(withIdentifier: "vagueCellThree")
            if cell == nil {
                cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "vagueCellThree")
                cell?.selectionStyle = .none
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
                cell?.textLabel?.textColor = Main_Text_Color
            }
            
            let ideaModel = ideaViewList[indexPath.row]
            cell?.textLabel?.text = ideaModel.content ?? "想法"
            return cell!
            
        case 3:
            var cell = tableView.dequeueReusableCell(withIdentifier: "vagueCellFour")
            if cell == nil {
                cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "vagueCellFour")
                cell?.selectionStyle = .none
                cell?.textLabel?.font = UIFont.systemFont(ofSize: 14)
                cell?.textLabel?.textColor = Main_Text_Color
                cell?.imageView?.image = UIImage.init(named: "tab_book_mine_nor")
                
            }
            
            let userModel = userList[indexPath.row]
            cell?.textLabel?.text = userModel.nickName ?? ""
            return cell!
            
        default:
            return UITableViewCell()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        let footer = UIButton.init(type: .custom)
        
        footer.backgroundColor = .white
        footer.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        footer.setTitleColor(Search_Color, for: .normal)
        
        footer.layer.borderWidth = 1
        footer.layer.borderColor = Line_Color.cgColor
        
        footer.tag = section + 20180326
        
        footer.addTarget(self, action: #selector(showIns(sender:)), for: .touchUpInside)
        
        switch section {
        case 0:
            if self.booklist.count < 3 {
                return nil
            }
            footer.setTitle("查看更多书籍", for: .normal)
        case 1:
            if self.booklistViewList.count < 3 {
                return nil
            }
            footer.setTitle("查看更多书单", for: .normal)
        case 2:
            footer.setTitle("查看更多想法", for: .normal)
        case 3:
            footer.setTitle("查看更多用户", for: .normal)
        default:
            footer.setTitle("", for: .normal)
        }
        
        return footer
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return 60
        case 1:
            return 40
        case 2:
            return 40
        case 3:
            return 40
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if self.booklist.count < 3 {
                return 0.01
            }
            
        case 1:
            if self.booklistViewList.count < 3 {
                return 0.01
            }
            
        default:
            break
        }
        
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            if booklist.isEmpty == false {
                
                let book = booklist[indexPath.row]
                
                let bookInfo = KPBookInfoController.instance
                
                bookInfo.kp_self.title = book.name
                
                (bookInfo.kp_self as! KPBookInfoController).bookId = book.id!
                
                self.navigationController?.pushViewController(bookInfo, animated: true)
            }
            
        case 1:
            if booklistViewList.isEmpty == false {
                
                let bookList = booklistViewList[indexPath.row]
                
                let bookListInfo = KPBookListController.instance
                
                bookListInfo.kp_self.title = bookList.title
                
                (bookListInfo.kp_self as! KPBookListController).entryType = .collection(bookList.listId)
                
                self.navigationController?.pushViewController(bookListInfo, animated: true)
            }
            
        default:
            break
        }
    }
    
    @objc func showIns(sender: UIButton) -> Void {
        print("点击了查看更多")
        selectSectionLookMore?(sender.tag)
    }
    
    //
    func startSearchAll() -> Void {
        
        guard let key = self.searchText,
            key.count > 0 else {
                booklist = []
                booklistViewList = []
                ideaViewList = []
                userList = []
                self.vagueTable.reloadData()
                return
        }
        
        currentTask?.cancel()
        
        let ecode = self.searchText?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let request = KPNetWork.requestSearchBook(path: "m/search/all/" + ecode!, closure: { (json) in
            
            self.booklist = json["booklist"].arrayValue.compactMap{KPBookModel.init(json: $0)}
            self.booklistViewList = json["booklistViewList"].arrayValue.compactMap{KPListModel.init(json: $0)}
            self.ideaViewList = json["ideaViewList"].arrayValue.compactMap{KPIdearModel.init(json: $0)}
            self.userList = json["userList"].arrayValue.compactMap{KPUserModel.init(json: $0)}
            
            
            self.vagueTable.reloadData()
            
        })
        
        currentTask = request.task
    }
}
