//
//  KPBookInfoController.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/31.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import SnapKit
import SwiftyJSON

let kBookInfoHeaderViewIdentifier = "kBookInfoHeaderViewIdentifier"
let kBookInfoDetailCellIdentifier = "kBookInfoDetailCellIdentifier"
let kBookInfoKeyCellIdentifier = "kBookInfoKeyCellIdentifier"
let kBookInfoIdeaCellIdentifier = "kBookInfoIdeaCellIdentifier"
let kBookInfoGuessCellIdentifier = "kBookInfoGuessCellIdentifier"
let kBookInfoContentCellIdentifier = "kBookInfoContentCellIdentifier"
let kBookInfoFooterViewIdentifier = "kBookInfoFooterViewIdentifier"

class KPBookInfoController: KPBaseViewController, GDTMobBannerViewDelegate {
    
    typealias CellAction = (title: String?, model: AnyObject, action: Selector?)
    
    var bookId = "" {
        didSet {
            getBookInfo()
            getIdeaList()
        }
    }
    
    var bookStatu: KPBookStatuModel?
    
    var collect: UIButton!
    var push: UIButton!
    var readed: UIButton!
    
    var bottom: UIView!
    var topAdBanner: GDTMobBannerView!
    
    var tagData: [String] = []
    var ideaData: [KPIdeaModel] = []
    var guessData: [KPBookModel] = []
    
    var currentPage: Int = 1
    var totalPage: Int = 1
    
    let maxContentHeight: CGFloat = 250
    
    func addAdBanner() -> Void {
        
        if topAdBanner != nil {
            return
        }
        
        topAdBanner = GDTMobBannerView.init(frame: CGRect.init(x: 0, y: kLayoutNavH, width: Main_Screen_Width, height: 50), appkey: AD_App_Id, placementId: AD_Banner_Id)
        
        topAdBanner.currentViewController = self
        
        topAdBanner.delegate = self as GDTMobBannerViewDelegate
        
        view.addSubview(topAdBanner)
        
        topAdBanner.loadAdAndShow()
    }
    
    func bannerViewFail(toReceived error: Error!) {
        print(error)
    }
    
    func bannerViewDidReceived() {
        UIView.animate(withDuration: 0.25) {
            self.collectionView.frame.origin.y = 50 + kLayoutNavH
            self.collectionView.frame.size.height = Main_Screen_Height - kLayoutNavH - self.bottomHeight - 50
        }
    }
    
    func bannerViewWillClose() {
        UIView.animate(withDuration: 0.25) {
            self.collectionView.frame.origin.y -= 50
            self.collectionView.frame.size.height += 50
        }
    }
    
    func getBookInfo() -> Void {
        
        KPHud.showWaiting()
        
        KPNetWork.request(path: "m/book/\(bookId)", method: .get) {[unowned self] (result) in
            guard let data = result.data, let json = try? JSON.init(data: data) else {
                return
            }
            
            KPHud.hideNotice()
            
            if result.response?.statusCode == 200 {
                
                self.bookStatu = KPBookStatuModel.init(json: json)
                
                self.tagData = self.bookStatu?.book.tagArr ?? []
                
                self.title = self.bookStatu?.book.name
                
                self.collectionView.reloadData()
                
                self.addBottomBar()
                self.addAdBanner()
                
            } else {
                print(json["msg"].stringValue)
            }
        }
    }
    
    func getIdeaList() -> Void {
        
        if self.currentPage == 1 {
            self.ideaData.removeAll()
        }
        
        KPNetWork.request(path: "m/idea/book/\(bookId)/page?page=\(currentPage)&pageSize=2", method: .get) { (result) in
            
            guard result.response?.statusCode == 200 else {
                return
            }
            
            guard let data = result.data, let json = try? JSON.init(data: data)  else {
                return
            }
            
            self.ideaData += json.dictionaryValue["data"]!.arrayValue.compactMap({ (ideaJson) -> KPIdeaModel? in
                return KPIdeaModel(json: ideaJson)
            })
            
            self.totalPage = json.dictionaryValue["totalPage"]?.intValue ?? 1
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
            
        }
    }
    
    func getGuessYouLikeBookInfo() -> Void {
        
        KPHud.showWaiting()
        
        KPNetWork.request(path: "m/guess_you_like", method: .get) {[unowned self] (result) in
            guard let data = result.data, let json = try? JSON.init(data: data) else {
                return
            }
            
            KPHud.hideNotice()
            
            if result.response?.statusCode == 200 {
                
                self.guessData = json.dictionaryValue["data"]!.arrayValue.compactMap { KPBookModel(json: $0) }
                self.collectionView.reloadData()
                
            } else {
                print(json["msg"].stringValue)
            }
        }
    }
    
    var bottomHeight: CGFloat {
        return isAdoma ? 0 : kLayoutTabH
    }
    
    lazy var collectionView: UICollectionView! = {
        let laylout = UICollectionViewFlowLayout.init()
        let collectionView = UICollectionView(frame: CGRect.init(x: 0, y: kLayoutNavH, width: Main_Screen_Width, height: Main_Screen_Height - kLayoutNavH - self.bottomHeight), collectionViewLayout: laylout)
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "KPBookInfoHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kBookInfoHeaderViewIdentifier)
        collectionView.register(UINib.init(nibName: "KPBookInfoDetailCell", bundle: nil), forCellWithReuseIdentifier: kBookInfoDetailCellIdentifier)
        collectionView.register(UINib.init(nibName: "KPBookInfoKeyCell", bundle: nil), forCellWithReuseIdentifier: kBookInfoKeyCellIdentifier)
        collectionView.register(UINib.init(nibName: "KPBookIdeaCell", bundle: nil), forCellWithReuseIdentifier: kBookInfoIdeaCellIdentifier)
        collectionView.register(UINib.init(nibName: "KPGuessBookInfoCell", bundle: nil), forCellWithReuseIdentifier: kBookInfoGuessCellIdentifier)
        collectionView.register(UINib.init(nibName: "KPBookInfoContentCell", bundle: nil), forCellWithReuseIdentifier: kBookInfoContentCellIdentifier)
        collectionView.register(UINib.init(nibName: "KPBookInfoFooterView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: kBookInfoFooterViewIdentifier)
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        
        getGuessYouLikeBookInfo()
    }
    
    //MARK: add bottomBar
    @objc func addBottomBar() -> Void {
        
        if bottom != nil {
            return
        }
        
        if isAdoma {
            return
        }
        
        //MARK: bottom buttons
        let bottomBar = UIView.init(frame: CGRect.init(x: 0, y: Main_Screen_Height - kLayoutTabH, width: Main_Screen_Width, height: self.bottomHeight))
        view.addSubview(bottomBar)
        
        bottom = bottomBar
        
        //MARK: bg
        let readedBg = UIView()
        readedBg.backgroundColor = .white
        bottomBar.addSubview(readedBg)
        
        let collectBg = UIView()
        collectBg.backgroundColor = .white
        bottomBar.addSubview(collectBg)
        
        let pushBg = UIView()
        pushBg.backgroundColor = Main_Theme_Color.withAlphaComponent(0.8)
        bottomBar.addSubview(pushBg)
        
        readedBg.snp.makeConstraints { (make) in
            make.left.bottom.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.3)
        }
        
        collectBg.snp.makeConstraints { (make) in
            make.left.equalTo(readedBg.snp.right)
            make.bottom.top.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.3)
        }
        
        pushBg.snp.makeConstraints { (make) in
            make.left.equalTo(collectBg.snp.right)
            make.top.bottom.right.equalToSuperview()
        }
        
        //已读按钮
        readed = UIButton.init(type: .system)
        readedBg.addSubview(readed)
        
        readed.setTitle("读过", for: .normal)
        readed.adjustsImageWhenHighlighted = false
        readed.setTitleColor(Main_Theme_Color, for: .normal)
        readed.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        readed.addTarget(self, action: #selector(readedAction), for: .touchUpInside)
        
        //想读
        collect = UIButton.init(type: .system)
        collectBg.addSubview(collect)
        
        collect.setTitle("想读", for: .normal)
        collect.adjustsImageWhenHighlighted = false
        collect.setTitleColor(Main_Theme_Color, for: .normal)
        collect.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        collect.addTarget(self, action: #selector(wantedAction), for: .touchUpInside)
        
        //推送
        push = UIButton.init(type: .system)
        pushBg.addSubview(push)
        
        push.setTitle("推送", for: .normal)
        push.setTitleColor(.white, for: .normal)
        push.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        push.addTarget(self, action: #selector(pushAction), for: .touchUpInside)
        
        readed.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(kTabH)
        }
        
        collect.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(kTabH)
        }
        
        push.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(kTabH)
        }
        
        //line
        let line = UIView()
        bottomBar.addSubview(line)
        line.backgroundColor = Line_Color
        line.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(0.5)
        }
    }
    
    //MARK: 已读
    @objc func readedAction() {
        
        if !KPUser.share.isLogin {
            
            let login = KPLoginController.instance
            
            self.navigationController?.pushViewController(login, animated: true)
            
            return
        }
        
        guard let statu = self.bookStatu else {
            return
        }
        
        if statu.status == .readed {
            KPHud.showText(text: "本书您已经读过了哦")
            return
        }
        
        if statu.status == .toRead {
            
            let alert = UIAlertController.init(title: nil, message: "您未推送过本图书，是否移动至已读?", preferredStyle: .alert)
            
            let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
            alert.addAction(cancel)
            
            let push = UIAlertAction.init(title: "是", style: .default, handler: { (_) in
                self.bookStatusAction(status: .readed)
            })
            alert.addAction(push)
            
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        bookStatusAction(status: .readed)
        
        //TODO: 写想法
    }
    
    //MARK: 想读
    @objc func wantedAction() {
        
        if !KPUser.share.isLogin {
            
            let login = KPLoginController.instance
            
            self.navigationController?.pushViewController(login, animated: true)
            
            return
        }
        
        guard let statu = self.bookStatu else {
            return
        }
        
        if statu.status == .toRead {
            KPHud.showText(text: "本书已在您的想读列表")
            return
        }
        
        if statu.status == .reading {
            KPHud.showText(text: "本书已在您的在读列表")
            return
        }
        
        if statu.status == .readed {
            KPHud.showText(text: "本书您已经读过了哦")
            return
        }
        
        bookStatusAction(status: .toRead)
    }
    
    //MARK: 推送
    @objc func pushAction() {
        
        if !KPUser.share.isLogin {
            
            let login = KPLoginController.instance
            
            self.navigationController?.pushViewController(login, animated: true)
            
            return
        }
        
        guard let statu = self.bookStatu else {
            return
        }
        
        if statu.status == .reading || statu.status == .readed {
            
            let msg = statu.status == .reading ? "本书已在您的在读列表是否重复推送?" : "本书已在您的已读列表是否重复推送?"
            
            let alert = UIAlertController.init(title: nil, message: msg, preferredStyle: .alert)
            
            let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
            alert.addAction(cancel)
            
            let push = UIAlertAction.init(title: "是", style: .default, handler: { (_) in
                self.pushBook()
            })
            alert.addAction(push)
            
            self.present(alert, animated: true, completion: nil)
            
            return
        }
        
        pushBook()
        //        bookStatusAction(status: .reading)
    }
    
    func pushBook() {
        
        //推送
        KPHud.showWaiting()
        KPNetWork.request(path: "m/auth/push/\(bookId)") { (result) in
            KPHud.hideNotice()
            
            guard let data = result.value,
                let json = try? JSON.init(data: data) else {
                    return
            }
            
            KPHud.showText(text: json["msg"].stringValue)
            
            self.updateBookStatus()
        }
    }
    
    func updateBookStatus() {
        
        KPNetWork.request(path: "m/book/\(self.bookId)", method: .get) {[unowned self] (result) in
            guard let data = result.data, let json = try? JSON.init(data: data) else {
                return
            }
            
            if result.response?.statusCode == 200 {
                
                self.bookStatu = KPBookStatuModel.init(json: json)
                
            } else {
                print(json["msg"].stringValue)
            }
            
        }
    }
    
    //MARK: 状态操作
    func bookStatusAction(status: KPBookStatuModel.KPBookStatus) {
        
        KPHud.showWaiting()
        KPNetWork.request(path: "m/auth/collect/create",requestType: .json, para: ["bookIds": bookId, "bookshelfType": status.rawValue]) { (result) in
            KPHud.hideNotice()
            
            guard let data = result.value,
                let json = try? JSON.init(data: data) else {
                    return
            }
            
            if json["code"].string == "success" {
                
                switch status {
                    
                case .readed:
                    KPHud.showText(text: "加入已读列表成功")
                    
                case .toRead:
                    KPHud.showText(text: "加入想读列表成功")
                    
                case .reading:
                    KPHud.showText(text: "推送成功!")
                    
                case .none:
                    break
                }
                
                self.bookStatu?.status = status
                
            } else {
                KPHud.showText(text: json["code"].stringValue)
            }
            
        }
    }
    
    //MARK: 登录
    override func userStatu(sender: NSNotification) {
        getBookInfo()
        getIdeaList()
        getGuessYouLikeBookInfo()
    }
    
}

extension KPBookInfoController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return tagData.count
        case 2:
            return 1
        case 3:
            return ideaData.count
        case 4:
            return guessData.count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell: KPBookInfoBaseCell?
        var data: Any?
        switch indexPath.section {
        case 0:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: kBookInfoDetailCellIdentifier, for: indexPath) as! KPBookInfoDetailCell
            data = bookStatu?.book
        case 1:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: kBookInfoKeyCellIdentifier, for: indexPath) as! KPBookInfoKeyCell
            data = tagData[indexPath.row]
        case 2:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: kBookInfoContentCellIdentifier, for: indexPath) as! KPBookInfoContentCell
            let contentCell = cell as! KPBookInfoContentCell
            contentCell.readAllBlock = { [weak self] sender in
                self?.bookStatu?.book.readAll = sender.isSelected
                collectionView.reloadItems(at: [indexPath])
            }
            data = bookStatu?.book
        case 3:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: kBookInfoIdeaCellIdentifier, for: indexPath) as! KPBookIdeaCell
            data = ideaData[indexPath.row]
            let ideacell: KPBookIdeaCell  = cell as! KPBookIdeaCell
            ideacell.readAllBlock = { [weak self] sender in
                self?.ideaData[indexPath.row].readAll = sender.isSelected
                collectionView.reloadItems(at: [indexPath])
            }
            ideacell.delegate = self
        case 4:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: kBookInfoGuessCellIdentifier, for: indexPath) as! KPGuessBookInfoCell
            data = guessData[indexPath.row]
        default:
            assert(false, "Unexpected section")
        }
        cell?.displayData(data: data)
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch indexPath.section {
        case 1:
            let tag = KPTagSearchController.instance
            (tag.kp_self as! KPTagSearchController).tag = tagData[indexPath.row]
            self.navigationController?.pushViewController(tag, animated: true)
            break
        case 4:
            let bookInfo = KPBookInfoController.instance
            bookInfo.kp_self.title = guessData[indexPath.row].name
            (bookInfo.kp_self as! KPBookInfoController).bookId = guessData[indexPath.row].id!
            self.navigationController?.pushViewController(bookInfo, animated: true)
            break
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader && indexPath.section != 0 {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: kBookInfoHeaderViewIdentifier,
                                                                             for: indexPath) as! KPBookInfoHeaderView
            var title = ["", "分类标签", "书籍详情", "热门想法", "猜你喜欢"]
            headerView.titleLabel.text = title[indexPath.section]
            headerView.changeGuessBooksView.isHidden = true
            if indexPath.section == 4 {
                headerView.changeGuessBooksView.isHidden = false
                headerView.refreshLabel.text = "换一批"
                headerView.changeNext = { [weak self] in
                    self?.getGuessYouLikeBookInfo()
                }
            }
            return headerView
            
        }
        else if kind == UICollectionElementKindSectionFooter && indexPath.section == 3 && totalPage > currentPage {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: kBookInfoFooterViewIdentifier,
                                                                             for: indexPath) as! KPBookInfoFooterView
            footerView.readAllAction = { [weak self] sender in
                self?.currentPage += 1
                self?.getIdeaList()
                self?.collectionView.reloadData()
            }
            footerView.readAllBtn.setTitle("查看更多", for: .normal)
            return footerView
        }
        
        return UICollectionReusableView()
    }
}

extension KPBookInfoController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            let bookIconHeight = 150 * Main_Screen_Width / 375
            return CGSize(width: collectionView.bounds.width, height: bookIconHeight)
        case 1:
            let tagWidth = KPBookInfoKeyCell.heightForData(text: tagData[indexPath.row])
            return CGSize(width: tagWidth, height: 30)
        case 2:
            guard let book = bookStatu?.book, book.readAll, let content = book.content else {
                return CGSize(width: collectionView.bounds.width, height: 103)
            }
            let height: CGFloat = KPBookInfoContentCell.heightForData(text: content)
            return CGSize(width: collectionView.bounds.width, height: height)
        case 3:
            guard ideaData[indexPath.row].readAll, let content = ideaData[indexPath.row].content else {
                return CGSize(width: collectionView.bounds.width, height: 150)
            }
            
            let height = KPBookIdeaCell.heightForData(text: content)
            return CGSize(width: collectionView.bounds.width, height: height)
        case 4:
            let guessBookWidth = (collectionView.bounds.width - 50) / 3
            return CGSize(width: guessBookWidth, height: guessBookWidth * 1.2 + 50)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case 0, 2:
            return UIEdgeInsetsMake(0, 0, 10, 0)
        case 1, 4:
            return UIEdgeInsetsMake(10, 10, 10, 10)
        default:
            return UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if section == 3 {
            return 0.0
        }
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        switch section {
        case 1:
            guard tagData.count > 0 else {
                return CGSize(width: 0, height: 0)
            }
        case 2:
            guard let content = bookStatu?.book.content, content.count > 0 else {
                return CGSize(width: 0, height: 0)
            }
        case 3:
            guard ideaData.count > 0 else {
                return CGSize(width: 0, height: 0)
            }
        case 4:
            guard guessData.count > 0 else {
                return CGSize(width: 0, height: 0)
            }
        default:
            return CGSize(width: 0, height: 0)
        }
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 3 && ideaData.count > 0 && totalPage > currentPage {
            return CGSize(width: collectionView.bounds.width, height: 44)
        }
        return CGSize(width: 0, height: 0)
    }
    
}

extension KPBookInfoController: KPBookIdeaCellDelegate {
    
    func praiseBtnTapped(sender: UIButton, data: Any?, closure: @escaping (_ result: Bool) -> ()) {
        
        guard let data = data as? KPIdeaModel else {
            return
        }
        
        let ideaId = data.id
        let method : KPNetWork.MethodType = sender.isSelected ? .post : .delete
        likeIdea(method: method, ideaId: ideaId, closure: closure)
    }
    
    func collectionBtnTapped(sender: UIButton, data: Any?, closure: @escaping (_ result: Bool) -> ()) {
        
        guard let data = data as? KPIdeaModel else {
            return
        }
        
        let ideaId = data.id
        let method : KPNetWork.MethodType = sender.isSelected ? .post : .delete
        collectIdea(method: method, ideaId: ideaId, closure: closure)
    }
    
    func likeIdea(method: KPNetWork.MethodType, ideaId: Int, closure: @escaping (_ result: Bool) -> ()) -> Void {
        KPNetWork.request(path: "m/auth/idea/\(ideaId)/like", method: method) { (result) in
            
            guard result.response?.statusCode == 200, let data = result.data else {
                closure(false)
                return
            }
            
            guard let json = try? JSON.init(data: data) else {
                closure(false)
                return
            }
            
            guard let code = json["code"].string, code == "success" else {
                closure(false)
                return
            }
            
            KPHud.showText(text: method == .delete ? "取消点赞成功" : "点赞成功", delay: 1)
            closure(true)
        }
    }
    
    func collectIdea(method: KPNetWork.MethodType, ideaId: Int, closure: @escaping (_ result: Bool) -> ()) -> Void {
        KPNetWork.request(path: "m/auth/idea/\(ideaId)/collect", method: method) { (result) in
            
            guard result.response?.statusCode == 200, let data = result.data else {
                closure(false)
                return
            }
            
            guard let json = try? JSON.init(data: data) else {
                closure(false)
                return
            }
            
            guard let code = json["code"].string, code == "success" else {
                closure(false)
                return
            }
            
            KPHud.showText(text: method == .delete ? "取消收藏成功" : "收藏成功", delay: 1)
            closure(true)
        }
    }
}
