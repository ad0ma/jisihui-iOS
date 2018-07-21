//
//  KPBookShelfController.swift
//  KP
//
//  Created by Adoma on 2017/12/23.
//  Copyright © 2017年 adoma. All rights reserved.
//

import SwiftyJSON
import Alamofire

class KPBookShelfController: KPBaseViewController, KPSegmentedControlDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    var seg: KPSegmentedControl!
    
    var searchBg: UIView!
    var batch: UIButton!
    var searchText: UITextField!
    
    var batchAllButton: UIButton!
    var batchNextButton: UIButton!
    
    var searchRequest: DataRequest?
    var isSearching: Bool {
        return searchText.isEditing
    }
    
    lazy var batchView: UIView = {
        
        let batch = UIView()
        self.view.addSubview(batch)
        
        batch.backgroundColor = .white
        
        batch.snp.makeConstraints({ (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(kLayoutTabH)
//            make.bottom.equalToSuperview()
            make.top.equalTo(self.view.snp.bottom)
        })
        
        //all
        let all = UIButton.init(type: .custom)
        batch.addSubview(all)
        
        self.batchAllButton = all
        
        all.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        all.setTitleColor(.black, for: .normal)
        all.setImage(UIImage.init(named: "unselect"), for: .normal)
        all.setImage(UIImage.init(named: "selected"), for: .selected)
        all.imageEdgeInsets.left = -5
        all.addTarget(self, action: #selector(batchAll(sender:)), for: .touchUpInside)
        
        all.snp.makeConstraints({ (make) in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview().offset(-(kLayoutTabH - kTabH) * 0.5)
        })

        //line
        let line = UIView()
        batch.addSubview(line)
        line.backgroundColor = Line_Color
        
        line.snp.makeConstraints({ (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(0.5)
        })
        
        return batch;
    }()
    
    var bookShelf: UITableView!
    
    var currentPage: Int {
        
        get {
            switch bookShelfType {
            case .reading:
                return readingPage
                
            case .toRead:
                return toReadPage
                
            case .readed:
                return readedPage
                
            default:
                return 1
            }
        }
        
        set {
            
            switch bookShelfType {
            case .reading:
                 readingPage = newValue
                
            case .toRead:
                 toReadPage = newValue
                
            case .readed:
                 readedPage = newValue
                
            default:
                break
            }
        }
    }
    
    var bookShelfType: KPBookStatuModel.KPBookStatus = .reading
    
    var readingPage = 1
    var readingBooks = [KPBookModel]()
    
    var toReadPage = 1
    var toReadBooks = [KPBookModel]()
    
    var readedPage = 1
    var readedBooks = [KPBookModel]()
    
    var searchBooks = [KPBookModel]()
    
    //获取当前图书数组
    var currentBooks: [KPBookModel] {
        
        get {
            
            if isSearching {
                return searchBooks
            }
            
            switch bookShelfType {
            case .reading:
                return readingBooks
                
            case .toRead:
                return toReadBooks
                
            case .readed:
                return readedBooks
                
            default:
                return []
            }
        }
        
        set {
            
            if isSearching {
                searchBooks = newValue
                return
            }
            
            switch bookShelfType {
            case .reading:
                readingBooks = newValue
                
            case .toRead:
                toReadBooks = newValue
                
            case .readed:
                readedBooks = newValue
                
            default:
                break
            }
        }
    }
    
    //获取当前选择的书
    var selectedBooks: [KPBookModel] {
        return currentBooks.filter{ $0.selected }
    }
    
    //获取当前选择的书逗号分隔的字符串
    var selectedBookStr: String? {
        
        if selectedBooks.count == 0 {
            return nil
        }
        
        return selectedBooks.compactMap{ $0.id }.joined(separator: ",")
    }
    
    var isBatch = false {
        
        didSet{
            seg.isUserInteractionEnabled = !isBatch
            searchText.isUserInteractionEnabled = !isBatch
            
            if isBatch {
                bookShelf.contentInset.bottom += 49
            } else {
                bookShelf.contentInset.bottom -= 49
            }
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "我的书架"
        
        seg = KPSegmentedControl.init(frame: CGRect.init(x: 0, y: 0, width: Main_Screen_Width, height: 49), titles: ["在读","想读","已读"])
        view.addSubview(seg)
        
        seg.delegate = self
        
        seg.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(kLayoutNavH)
            make.height.equalTo(49)
        }
        
        //search
        searchBg = UIView()
        view.addSubview(searchBg)
        
        searchBg.backgroundColor = .white
        
        searchBg.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(seg.snp.bottom)
            make.height.equalTo(45)
        }
        
        batch = UIButton.init(type: .custom)
        searchBg.addSubview(batch)
        
        batch.setTitle("批量操作", for: .normal)
        batch.setTitle("完成", for: .selected)
        batch.setTitleColor(RGBCOLOR(r: 149, g: 149, b: 149), for: .normal)
        batch.setTitleColor(Main_Theme_Color, for: .selected)
        batch.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        
        batch.addTarget(self, action: #selector(batchAction(sender:)), for: .touchUpInside)
        
        batch.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
        }
        
        searchText = UITextField.init()
        searchBg.addSubview(searchText)
        
        searchText.snp.makeConstraints { (make) in
            make.left.equalTo(batch.snp.right).offset(15)
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
            make.height.equalTo(30)
        }
        
        let leftBack = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 33/2 + 11, height: 33/2))
        let left = UIImageView.init(frame: CGRect.init(x: 11, y: 0, width: 33/2, height: 33/2))
        
        left.image = UIImage.init(named: "om_sousuo")
        leftBack.addSubview(left)
        searchText.leftView = leftBack
        searchText.leftViewMode = .always
        searchText.font = UIFont.systemFont(ofSize: 15)
        searchText.placeholder = "请输入图书名称或作者"
        searchText.borderStyle = .roundedRect
        searchText.backgroundColor = Content_Color
        searchText.tintColor = Main_Theme_Color
        searchText.addTarget(self, action: #selector(textChanged(sender:)), for: .editingChanged)
        searchText.clearButtonMode = .always
        searchText.returnKeyType = .search
        searchText.delegate = self
        searchText.setContentHuggingPriority(UILayoutPriority(rawValue: 249), for: .horizontal)
        
        //content
        bookShelf = UITableView.init(frame: CGRect.zero, style: .plain)
        view.addSubview(bookShelf)
        
        bookShelf.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(searchBg.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        bookShelf.showsVerticalScrollIndicator = false
        bookShelf.delegate = self
        bookShelf.dataSource = self
        bookShelf.backgroundColor = Content_Color
        bookShelf.tableFooterView = UIView()
        bookShelf.rowHeight = 160
        bookShelf.separatorStyle = .none
        bookShelf.registerReusableCell(KPShelfBookInfoCell.self)
        bookShelf.contentInset = UIEdgeInsetsMake(5, 0, kLayoutBottom, 0)
        bookShelf.spr_setIndicatorHeader {
            self.currentPage = 1
            self.currentBooks.removeAll()
            self.getBookShelfData {
                self.bookShelf.spr_headerEndRefreshing()
            }
        }
        
        bookShelf.spr_setIndicatorFooter {
            self.currentPage += 1
            self.getBookShelfData {
                self.bookShelf.spr_footerEndRefreshing()
            }
        }
        
        bookShelf.spr_headerEnable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bookShelf.spr_beginRefreshing()
    }
    
    //MARK: 获取书架列表
    func getBookShelfData(searchKey: String? = nil, completion: @escaping () -> ()) {
        
        searchRequest = KPNetWork.getBookShelfData(bookShelfType: bookShelfType.rawValue, page: currentPage, searchKey: searchKey) { (result) in
            
            completion()
            
            guard let data = result.value,
                let json = try? JSON.init(data: data),
                let books = json["data"].array else {
                    KPHud.showText(text: "网络错误")
                    return
            }
            
            let newBooks = books.compactMap{ KPBookModel.init(json: $0["book"]) }
            
            if self.isSearching {
                self.currentBooks = newBooks
            } else {
                self.currentBooks += newBooks
            }
            
            self.reloadData()
        }
    }
    
    func reloadData(showEmpty: Bool = true) {
        
        bookShelf.backgroundView = nil
        
        bookShelf.reloadData()
        
        dealBatchView()
        
        if currentBooks.count == 0, showEmpty {
            let empty = KPEmpty.empty(title: "暂无图书")
            bookShelf.backgroundView = empty
        }
    }
    
    //MARK: 点击不同的分类
    func didSelect(itemIndex: Int) {
        
        if isSearching {
            searchText.text = nil
            cancelSearch()
        }
        
        switch itemIndex {
        case 0:
            bookShelfType = .reading
            
        case 1:
            bookShelfType = .toRead
            
        case 2:
            bookShelfType = .readed
            
        default:
            break
        }
        
        self.reloadData(showEmpty: false)

        if currentBooks.count == 0 {
            bookShelf.spr_beginRefreshing()
        }
    }
    
    @objc func batchAction(sender: UIButton) {
        
        //如果当前处于批量选择状态
        if isBatch {
            
            //取消批量选择状态
            sender.isSelected = false
            
            hideBatchView()
            
            bookShelf.reloadData()
            
        } else {
            
            if sender.isSelected {
                
                batch.isSelected = false
                
                searchText.text = nil
                searchText.resignFirstResponder()
                self.searchBg.layoutIfNeeded()
                bookShelf.reloadData()
                
            } else {
                
                //先判断当前列表图书数量
                if currentBooks.count > 0 {
                    //进入批量选择状态
                    sender.isSelected = true

                    showBatchView()
                    
                    bookShelf.reloadData()
                }
            }
        }
    }
    
    var actions: [UIButton]!
    
    func showBatchView() {
        
        isBatch = true
        
        actions = []
        var actionsWidth = Main_Screen_Width * 0.5
        
        var next: UIView! = nil
        
        //添加按钮
        switch bookShelfType {
            
        case .reading, .toRead:
            actionsWidth = actionsWidth / 2

            //读完
            let readed = UIButton.init(type: .custom)
            batchView.addSubview(readed)
            
            actions.append(readed)
            next = readed
            
            readed.setTitle("读过", for: .normal)
            readed.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            readed.setTitleColor(Main_Theme_Color, for: .normal)
            readed.addTarget(self, action: #selector(batchReadedAction), for: .touchUpInside)
            
            readed.snp.makeConstraints({ (make) in
                make.right.equalToSuperview()
                make.height.equalTo(44)
                make.centerY.equalTo(batchAllButton)
                make.width.equalTo(actionsWidth)
            })
            
//        case .toRead:
//            actionsWidth = actionsWidth / 3
//
//            //读过
//            let readed = UIButton.init(type: .custom)
//            batchView.addSubview(readed)
//
//            actions.append(readed)
//
//            readed.setTitle("读过", for: .normal)
//            readed.titleLabel?.font = UIFont.systemFont(ofSize: 15)
//            readed.setTitleColor(Main_Theme_Color, for: .normal)
//            readed.addTarget(self, action: #selector(batchReadedAction), for: .touchUpInside)
//
//            readed.snp.makeConstraints({ (make) in
//                make.right.equalToSuperview()
//                make.height.equalTo(44)
//                make.centerY.equalTo(batchAllButton)
//                make.width.equalTo(actionsWidth)
//            })
//
//            //推送
//            let push = UIButton.init(type: .custom)
//            batchView.addSubview(push)
//
//            next = push
//            actions.append(push)
//
//            push.setTitle("推送", for: .normal)
//            push.titleLabel?.font = UIFont.systemFont(ofSize: 15)
//            push.setTitleColor(Main_Text_Color, for: .normal)
//            push.addTarget(self, action: #selector(batchPushAction), for: .touchUpInside)
//
//            push.snp.makeConstraints({ (make) in
//                make.right.equalTo(readed.snp.left)
//                make.height.equalTo(readed)
//                make.centerY.equalTo(readed)
//                make.width.equalTo(readed)
//            })
            
        default:
            break
        }
        
        //delete
        let delete = UIButton.init(type: .custom)
        batchView.addSubview(delete)
        
        actions.append(delete)
        
        delete.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        delete.setTitleColor(Sub_Text_Color, for: .normal)
        delete.setTitle("删除", for: .normal)
        delete.addTarget(self, action: #selector(batchDeleteAction), for: .touchUpInside)
        
        delete.snp.makeConstraints({ (make) in
            if next == nil {
                make.right.equalTo(batchView).offset(-15)
                make.centerY.equalTo(batchAllButton)
                make.width.equalTo(60)
            } else {
                make.right.equalTo(next.snp.left)
                make.centerY.equalTo(next)
                make.width.equalTo(actionsWidth)
            }
            make.height.equalTo(44)
        })
        
        batchAllButton.setTitle("全选（\(selectedBooks.count)本）", for: .normal)
        
        self.view.layoutIfNeeded()
        
        batchView.snp.updateConstraints { (make) in
            make.top.equalTo(self.view.snp.bottom).offset(-kLayoutTabH)
        }
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hideBatchView() {
        
        isBatch = false
        
        batch.isSelected = false
        
        self.view.layoutIfNeeded()
        
        batchView.snp.updateConstraints { (make) in
            make.top.equalTo(self.view.snp.bottom).offset(0)
        }
        
        UIView.animate(withDuration: 0.2, animations: {
            self.view.layoutIfNeeded()
        }) { (_) in
            self.actions.forEach{ $0.removeFromSuperview() }
        }
    }
    
    func dealBatchView() {
        
        if isBatch == false {
            return
        }
        
        if currentBooks.isEmpty {
            isBatch = false
            hideBatchView()
        }
        
        batchAllButton.isSelected = selectedBooks.count == currentBooks.count
        batchAllButton.setTitle("全选（\(selectedBooks.count)本）", for: .normal)
    }
    
    @objc func batchAll(sender: UIButton) {
        
        sender.isSelected = !sender.isSelected

        let books = currentBooks.map({ (book) -> KPBookModel in
            var mapBook = book
            mapBook.selected = sender.isSelected
            return mapBook
        })
        
        currentBooks = books
        
        reloadData()
    }
    
    @objc func batchDeleteAction() {
        
        guard let books = selectedBookStr else {
            KPHud.showText(text: "至少选择一本书")
            return
        }
        
        KPHud.showWaiting(text: "批量删除中")
        KPNetWork.request(path: "m/auth/collect", method: .delete, requestType: .json, para: ["bookIds": books]) { (result) in
            
            guard result.response?.statusCode == 200 else {
                    KPHud.showText(text: "删除失败")
                    return
            }
            
            KPHud.showText(text: "删除成功")
            self.bookShelf.spr_beginRefreshing()
        }
    }
    
    @objc func batchReadedAction() {
        
        guard let books = selectedBookStr else {
            KPHud.showText(text: "至少选择一本书")
            return
        }
        
        KPHud.showWaiting()
        KPNetWork.request(path: "m/auth/collect/create", requestType: .json, para: ["bookIds": books, "bookshelfType": "READED"]) { (result) in
            guard result.response?.statusCode == 200 else {
                    KPHud.showText(text: "操作失败")
                    return
            }

            KPHud.hideNotice()
            self.bookShelf.spr_beginRefreshing()
        }
    }
    
    func batchPushAction() {
        
        guard let books = selectedBookStr else {
            KPHud.showText(text: "至少选择一本书")
            return
        }
        
        KPHud.showWaiting()
        KPNetWork.request(path: "m/auth/push", para: ["bookId": books]) { (result) in
            guard result.response?.statusCode == 200 else {
                KPHud.showText(text: "操作失败")
                return
            }
            
            KPHud.hideNotice()
            self.bookShelf.spr_beginRefreshing()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //改变frame
        batch.isSelected = true
        self.searchBg.layoutIfNeeded()
    }
    
    //MARK: 文字改变发起搜索
    @objc func textChanged(sender: UITextField) -> Void {
        
        searchRequest?.cancel()
        getBookShelfData(searchKey: sender.text) {}
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.text?.count == 0 {
            return false
        }
       
        cancelSearch()
        
        return true
    }
    
    func cancelSearch() {
        searchText.resignFirstResponder()
        batch.isSelected = false
        searchBg.layoutIfNeeded()
        reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let bookCollection = tableView.dequeueReusableCell(indexPath: indexPath) as KPShelfBookInfoCell
        
        guard indexPath.row < currentBooks.count else {
            return bookCollection
        }
        
        bookCollection.disPlay(data: currentBooks[indexPath.row])
        
        bookCollection.setDelegate(delegate: self, type: bookShelfType, isBatch: isBatch, indexPath: indexPath)

        return bookCollection
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if isBatch {
            
            currentBooks[indexPath.row].selected = !currentBooks[indexPath.row].selected
            
            reloadData()
            
        } else {
            
            guard currentBooks.count > 0 else {
                return
            }
            
            let bookInfo = KPBookInfoController.instance
            
            bookInfo.kp_self.title = currentBooks[indexPath.row].name
            
            (bookInfo.kp_self as! KPBookInfoController).bookId = currentBooks[indexPath.row].id!
            
            self.navigationController?.pushViewController(bookInfo, animated: true)
        }
    }

}

extension KPBookShelfController: KPShelfBookInfoCellDelegate {

    func thinkBtnTapped(sender: UIButton, indexPath: IndexPath?) {
        
    }
    
    func pushBtnTapped(sender: UIButton, indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        currentBooks[indexPath.row].selected = true
        
        guard let books = selectedBookStr else {
            KPHud.showText(text: "至少选择一本书")
            return
        }
        
        KPHud.showWaiting()
        KPNetWork.request(path: "m/auth/push", para: ["bookId": books]) { (result) in
            guard result.response?.statusCode == 200 else {
                KPHud.showText(text: "操作失败")
                return
            }
            
            KPHud.hideNotice()
            self.bookShelf.spr_beginRefreshing()
        }
    }
}
