//
//  KPMainSearchController.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/6/3.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON

class KPMainSearchController: KPBaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, KPSegmentedControlDelegate {
    
    var searchText: UITextField!

    var result: [Any]?
    
    var currentTask: URLSessionTask?
    
    var searchTable: UITableView!
        
    var searchSegmented: KPSegmentedControl!
    
    var staticResult: KPStaticResultViewController!
    
    var vague: KPVagueResultViewController!
    
    enum ResultType: Int {
        case book, bookList, idea, user
    }
    
    var type: ResultType = .book
    
    lazy var empty: KPEmpty = { empty in
        
        self.view.addSubview(empty)
        
        empty.snp.makeConstraints { (make) in
            make.top.left.bottom.right.equalTo(self.searchTable)
        }
        empty.backgroundColor = Content_Color
        
        empty.isHidden = true
        
        return empty
        
    }(KPEmpty.empty(title: "暂无数据"))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
//        请求大家都在搜数据
//        getAllSearchBookName()

        staticResult = KPStaticResultViewController()
        self.addChildViewController(staticResult)
        view.addSubview(staticResult.view)
        
        staticResult.latelySearchArr = KPUserCenter.shareSingTon().myTextArray
        
        staticResult.latelySearchTextTo = {(text, tag) in

            print("text = \(text) + tag = \(tag)")
            
            self.searchText.text = text
            
            self.staticResult.view.isHidden = true
            
            self.searchSegmented.isHidden = false
            self.searchTable.isHidden = false
            
            self.startSearh(itemIndex: self.type)
            
        }
        //添加模糊页面
        vague = KPVagueResultViewController()
        self.addChildViewController(vague)
        view.addSubview(vague.view)
        
        vague.selectSectionLookMore = { (tag) in
            
            self.type = ResultType.init(rawValue: tag - 20180326) ?? .book
            self.searchSegmented.selectedIndex = tag - 20180326
            self.searchButtonAction()
            print("\(tag)")
            
        }
        
        vague.view.isHidden = true
        
        searchTable = UITableView.init(frame: CGRect.init(x: 0, y: kLayoutNavH + 50, width: Main_Screen_Width, height: Main_Screen_Height - kLayoutNavH - 50))
        
        searchTable.showsVerticalScrollIndicator = false
        searchTable.delegate = self
        searchTable.dataSource = self
        searchTable.backgroundColor = Content_Color
        searchTable.rowHeight = 160
        searchTable.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0)
        searchTable.registerReusableCell(KPSearchBookListCell.self)
        searchTable.registerReusableCell(KPUserListTableViewCell.self)
        searchTable.registerReusableCell(KPIdearListTableViewCell.self)
        searchTable.registerReusableCell(KPBookCollectionCell.self)
        searchTable.tableFooterView = UIView()
        view.addSubview(searchTable)
        
        searchTable.isHidden = true
        
        searchSegmented = KPSegmentedControl.init(frame: CGRect.init(x: 0, y: kLayoutNavH, width: Main_Screen_Width, height: 50), titles: ["书籍", "书单"/*, "想法", "用户"*/])
        
        searchSegmented.delegate = self
        
        view.addSubview(searchSegmented)
        
        searchSegmented.isHidden = true
        
    }
    
    //segment按钮代理方法
    func didSelect(itemIndex: Int) {
        
        //将下标赋值
        self.type = ResultType.init(rawValue: itemIndex) ?? .book
        
        result = nil

        self.searchTable.reloadData()
        
        startSearh(itemIndex: type)
            
    }
    
    func configSearchBar() -> Void {
        if self.searchText != nil {
            return
        }

        let naviBar = self.navigationController?.navigationBar
        naviBar?.isHidden = true
        
        //MARK: config bar
        var bar: UINavigationBar!

        if #available(iOS 11, *) {

            let top: UINavigationBar!

            if isIphoneX {

                top = UINavigationBar.init(frame: CGRect.init(x: 0, y: 0, width: Main_Screen_Width, height: 44))

                bar = UINavigationBar.init(frame: CGRect.init(x: 0, y: 44, width: Main_Screen_Width, height: 44))

            } else {

                top = UINavigationBar.init(frame: CGRect.init(x: 0, y: 0, width: Main_Screen_Width, height: 20))

                bar = UINavigationBar.init(frame: CGRect.init(x: 0, y: 20, width: Main_Screen_Width, height: 44))
            }

            top.clipsToBounds = true
            top.tintColor = naviBar?.tintColor
            top.isTranslucent = true
            top.barStyle = .black
            top.setBackgroundImage(naviBar?.backgroundImage(for: .default), for: .default)

            view.addSubview(top)
        } else {
          bar = UINavigationBar.init(frame: CGRect.init(x: 0, y: 0, width: Main_Screen_Width, height: 64))
        }
        
        bar.tintColor = naviBar?.tintColor
        bar.isTranslucent = true
        bar.barStyle = .black
        bar.setBackgroundImage(naviBar?.backgroundImage(for: .default), for: .default)
        
        let searchText = UITextField.init()
        bar.addSubview(searchText)
        
        let leftBack = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 33/2 + 11, height: 33/2))
        
        let left = UIImageView.init(frame: CGRect.init(x: 11, y: 0, width: 33/2, height: 33/2))
        
        left.image = UIImage.init(named: "om_sousuo")
        leftBack.addSubview(left)
        searchText.leftView = leftBack
        searchText.leftViewMode = .always
        searchText.font = UIFont.systemFont(ofSize: 15)
        searchText.placeholder = "请输入图书名称或作者"
        searchText.borderStyle = .roundedRect
        searchText.backgroundColor = .white
        searchText.tintColor = Main_Theme_Color
        searchText.addTarget(self, action: #selector(textChanged(sender:)), for: .editingChanged)
        searchText.clearButtonMode = .always
        searchText.returnKeyType = .search
        searchText.delegate = self
        searchText.setContentHuggingPriority(UILayoutPriority(rawValue: 250), for: .horizontal)
        
        self.searchText = searchText
        
        let search = UIButton.init(type: .custom)
        bar.addSubview(search)
        
        search.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        search.setContentHuggingPriority(UILayoutPriority(rawValue: 251), for: .horizontal)
        search.setTitle("搜索", for: .normal)
        search.addTarget(self, action: #selector(searchButtonAction), for: .touchUpInside)
        
        let back = UIButton.init(type: .custom)
        bar.addSubview(back)

        back.setImage(UIImage.init(named: "ic_back"), for: .normal)
        back.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        
        back.snp.makeConstraints { (make) in
            make.centerY.equalTo(searchText)
            make.left.equalToSuperview().offset(14)
            make.width.equalTo(10)
            make.height.equalTo(18)
        }
        
        search.snp.makeConstraints { (make) in
            make.centerY.equalTo(searchText)
            make.right.equalToSuperview().offset(-14)
            make.left.equalTo(searchText.snp.right).offset(14)
        }
        
        searchText.snp.makeConstraints { (make) in
            if #available(iOS 11 , *) {
                make.centerY.equalToSuperview()
            } else {
                make.centerY.equalToSuperview().offset(12)
            }
            make.left.equalTo(back.snp.right).offset(14)
        }
                
        view.addSubview(bar)
    }
    
    @objc func backAction() -> Void {
        self.kp_navigationController?.popViewController(animated: true)
    }
    
    @objc func searchButtonAction() {
        
        self.searchText.resignFirstResponder()
        
        guard let str = self.searchText.text, str.count > 0 else {
            KPHud.showText(text: "请输入搜索词")
            return
            
        }
        
        vague.view.isHidden = true
        
        searchSegmented.isHidden = false
        searchTable.isHidden = false
        
        self.searchText.resignFirstResponder()

        startSearh(itemIndex: type)
        
        //点击搜索的时候保存搜索记录
        KPUserCenter.shareSingTon().searchText = self.searchText.text
        
        staticResult.latelySearchArr = KPUserCenter.shareSingTon().myTextArray
        
    }
    
    func startSearh(itemIndex: ResultType) -> Void {
        
        view.endEditing(true)
        
        guard let key = self.searchText.text as NSString?,
            key.length > 0 else {
                result = nil
                self.searchTable.reloadData()
                return
        }
        currentTask?.cancel()
        
        let ecode = self.searchText.text!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        var path: String
        
        switch type {
            
        case .book:
            path = "m/search/book/"
        case .bookList:
            path = "/m/search/booklist/"
        case .idea:
            path = "/m/search/idea/"
        case .user:
            path = "/m/search/user/"
        }
        
        let request = KPNetWork.requestSearchBook(path: path + ecode, closure: { (json) in
            
            self.result = json.arrayValue.compactMap{
                switch self.type {
                case .book:
                    return KPBookModel.init(json: $0)
                case .bookList:
                    return KPListModel.init(json: $0)
                case .idea:
                    return KPIdearModel.init(json: $0)
                case .user:
                    return KPUserModel.init(json: $0)
                }
            }
            
           self.empty.isHidden = !self.result!.isEmpty
            
            self.searchTable.reloadData()
            
        })
        
        currentTask = request.task
    }
    
    //MARK: 文字改变发起搜索，静态页和模糊页面显示状态改变
    @objc func textChanged(sender: UITextField) -> Void {
        
        self.empty.isHidden = true
        
        if let str = sender.text, str.count > 0 {
            
            staticResult.view.isHidden = true
            vague.view.isHidden = false
            if sender.markedTextRange == nil {
                vague.searchText = str
            }
        
        } else {
            
            staticResult.view.isHidden = false
            vague.view.isHidden = true
            
        }
        
        searchSegmented.isHidden = true
        searchTable.isHidden = true
        
    }
    
    //MARK: 收起键盘
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
        
        searchButtonAction()
        
        return true
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.searchText.resignFirstResponder()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return result?.count ?? 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configSearchBar()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch type {
        
        case .book:
            
            let searchBookCell = tableView.dequeueReusableCell(indexPath: indexPath) as KPSearchBookListCell
            
            searchBookCell.disPlay(data: result?[indexPath.row])
            
            return searchBookCell
            
        case .bookList:
            
            let searchBookCell = tableView.dequeueReusableCell(indexPath: indexPath) as KPBookCollectionCell
            
            searchBookCell.disPlay(data: result?[indexPath.row])
            
            return searchBookCell
            
        case .idea:
            
            let idearListCell = tableView.dequeueReusableCell(indexPath: indexPath) as KPIdearListTableViewCell
            
            idearListCell.disPlay(data: result?[indexPath.row])
            
            return idearListCell
            
        case .user:
            
            let userListCell = tableView.dequeueReusableCell(indexPath: indexPath) as KPUserListTableViewCell
            
            userListCell.disPlay(data: result?[indexPath.row])
            
            return userListCell

        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch type {
        case .book, .bookList:
            return 160
        case .idea:
            return 140
        case .user:
            return 70
        }
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        self.searchText.resignFirstResponder()
        
        switch type {
        case .book:
            let bookInfo = KPBookInfoController.instance
            
            bookInfo.kp_self.title = (result?[indexPath.row] as! KPBookModel).name
            
            (bookInfo.kp_self as! KPBookInfoController).bookId = (result?[indexPath.row] as! KPBookModel).id!
            
            self.navigationController?.pushViewController(bookInfo, animated: true)
            
        case .bookList:
            
            let bookList = KPBookListController.instance
            
            bookList.kp_self.title = (result?[indexPath.row] as! KPListModel).title
            
            (bookList.kp_self as! KPBookListController).entryType = .collection((result?[indexPath.row] as! KPListModel).listId)
            
            navigationController?.pushViewController(bookList, animated: true)
            
//        case .idea:
//
//        case .user:
            
        default :
            KPHud.showText(text: "跳转不详")
        }
    }
    
    
    /// 大家都在搜的静态页面
    func getAllSearchBookName() -> Void {
        
//        let staticResult = KPStaticResultViewController()
//        self.addChildViewController(staticResult)
//        view.addSubview(staticResult.view)
//        
////        let vague = KPVagueResultViewController()
////        self.addChildViewController(vague)
////        view.addSubview(vague.view)

        print("测试")
    }
}
