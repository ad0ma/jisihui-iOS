//
//  KPMineViewController.swift
//  KP
//
//  Created by Shawley on 11/03/2018.
//  Copyright © 2018 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON

let kMineHeaderViewIdentifier = "kMineHeaderViewIdentifier"
let kMineCellIdentifier = "kMineCellIdentifier"
let kMineDetailCellIdentifier = "kMineDetailCellIdentifier"

class KPMineViewController: KPBaseViewController {
    
    typealias CellAction = (title: String, icon: String, action: Selector?)
    
    let data: [[CellAction]] = [[("书架", "button_book", #selector(toCollection)), ("想法", "button_idea", #selector(toAddIdea))],
                                [("我的会员","icon_VIP", #selector(toShowVipInfo)),("我的推送","icon_push", #selector(toPushHistory)), ("使用帮助","icon_help", #selector(toUseGuide)),("关于我们","icon_about us", #selector(toAboutUS))]]
    
    var headerIcon: UIImage?
    var themeBgIcon: UIImage?
    
    lazy var collectionView: UICollectionView = {
        let laylout = UICollectionViewFlowLayout.init()
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: laylout)
        collectionView.backgroundColor = UIColor.white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UINib.init(nibName: "KPMineHeaderView", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: kMineHeaderViewIdentifier)
        collectionView.register(UINib.init(nibName: "KPMineCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: kMineCellIdentifier)
        collectionView.register(UINib.init(nibName: "KPMineDetailCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: kMineDetailCellIdentifier)
        
        collectionView.spr_setIndicatorHeader { [weak self] in
            self?.refreshUserIcon {
                self?.collectionView.spr_headerEndRefreshing()
            }
        }
        collectionView.spr_headerEnable()
        
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        NotificationCenter.default.addObserver(self, selector: #selector(loginRefresh), name: NSNotification.Name.init(APP_USER_LOGIN_KEY), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        collectionView.reloadData()
    }
    
    @objc private func toShowVipInfo()
    {
        if !KPUser.share.isLogin {
            
            let login = KPLoginController.instance
            
            self.navigationController?.pushViewController(login, animated: true)
            
            return
        }
        
        
        let pay = KPPaymentController.instance
        
        (pay.kp_self as! KPPaymentController).callBack = {[unowned self] success in
            self.collectionView.spr_beginRefreshing()
        }
        
        self.navigationController?.pushViewController(pay, animated: true)
    }
    
    @objc private func toUserInfo() {
        
        if !KPUser.share.isLogin {
            
            let login = KPLoginController.instance
            
            self.navigationController?.pushViewController(login, animated: true)
            
            return
        }
        
        
        let userInfo = KPUserInfoController.instance
        
        self.navigationController?.pushViewController(userInfo, animated: true)
    }
    
    @objc private func toCollection() {
        
        if !KPUser.share.isLogin {
            
            let login = KPLoginController.instance
            
            self.navigationController?.pushViewController(login, animated: true)
            
            return
        }
        
        
        let shelf = KPBookShelfController.instance
        
        self.navigationController?.pushViewController(shelf, animated: true)
    }
    
    @objc func toAddIdea() {
        if !KPUser.share.isLogin {
            
            let login = KPLoginController.instance
            
            self.navigationController?.pushViewController(login, animated: true)
            
            return
        }
        // 我的想法列表
        let history = KPIdeaHistoryController.instance
        navigationController?.pushViewController(history, animated: true)
    }
    
    @objc private func toPushHistory() {
        
        if !KPUser.share.isLogin {
            
            let login = KPLoginController.instance
            
            self.navigationController?.pushViewController(login, animated: true)
            
            return
        }
        
        
        let pushHistory = KPPushCollectionController.instance
        
        (pushHistory.kp_self as! KPPushCollectionController).type = .push
        
        self.navigationController?.pushViewController(pushHistory, animated: true)
    }
    
    
    @objc private func toBookActive() {
        
        let notice = KPWebViewController.instance
        
        notice.kp_self.title = "读书活动"
        
        (notice.kp_self as! KPWebViewController).urlStr = "http://www.jisihui.com/main/activity"
        
        self.navigationController?.pushViewController(notice, animated: true)
    }
    
    @objc private func toUseGuide() {
        
        let notice = KPWebViewController.instance
        
        notice.kp_self.title = "使用帮助"
        
        (notice.kp_self as! KPWebViewController).urlStr = "http://www.jisihui.com/user/notice"
        
        self.navigationController?.pushViewController(notice, animated: true)
    }
    
    @objc private func toAboutUS() {
        
        let aboutUs = KPAboutController.instance
        
        self.navigationController?.pushViewController(aboutUs, animated: true)
        
    }

}

extension KPMineViewController: UICollectionViewDelegate, UICollectionViewDataSource  {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell: KPMineBaseCell?
        switch indexPath.section {
        case 0:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: kMineCellIdentifier, for: indexPath) as! KPMineCollectionViewCell
        case 1:
            cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: kMineDetailCellIdentifier, for: indexPath) as! KPMineDetailCollectionViewCell
        default:
            return UICollectionViewCell()
        }
        
        let title = data[indexPath.section][indexPath.row].title
        let icon = data[indexPath.section][indexPath.row].icon
        cell?.label.text = title
        cell?.icon.image = UIImage.init(named: icon)
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let sel = data[indexPath.section][indexPath.row].action else {
            return
        }
        perform(sel)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if indexPath.section == 0 && kind == UICollectionElementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: kMineHeaderViewIdentifier,
                                                                             for: indexPath) as! KPMineHeaderView
            headerView.showData(headerImage: headerIcon, themeBgImage: themeBgIcon)
            headerView.delegate = self
            return headerView
        }
        return UICollectionReusableView()
    }
    
}

extension KPMineViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch indexPath.section {
        case 0:
            return CGSize(width: 75, height: 90)
        case 1:
            return CGSize(width: collectionView.bounds.width, height: 60)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        switch section {
        case 0:
            return UIEdgeInsetsMake(10, 20, 10, 20)
        default:
            return .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
         return CGFloat.leastNonzeroMagnitude
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.width * 3 / 5)
        }
        return .zero
    }
}

extension KPMineViewController: KPMineSettingViewDelegate {
    
    func editButtonTapped() {
        
        if !KPUser.share.isLogin {
            
            let login = KPLoginController.instance
            
            self.navigationController?.pushViewController(login, animated: true)
            
            return
        }
        
        let setting = KPMineSettingViewController.instance
        setting.kp_self.title = "设置"
        (setting.kp_self as! KPMineSettingViewController).delegate = self
        self.navigationController?.pushViewController(setting, animated: true)
    }
}

extension KPMineViewController {
    
    @objc func loginRefresh() {
        refreshUserIcon {
            
        }
    }
    
    func refreshUserIcon(completion: @escaping () -> ()) {
        getUserHeaderIcon { [weak self] in
            self?.getUserBackgroundIcon {
                self?.collectionView.reloadData()
                completion()
            }
        }
    }
    
    func getUserHeaderIcon(completion: @escaping () -> ()) {
        getUserIcon(type: KPNetWork.IconType.Header) { (icon) in
            guard let icon = icon else {
                return
            }
            
            KPUser.share.headerIcon = icon
            completion()
        }
    }
    
    func getUserBackgroundIcon(completion: @escaping () -> ()) {
        getUserIcon(type: KPNetWork.IconType.Background) { (icon) in
            guard let icon = icon else {
                return
            }
            
            KPUser.share.themeBgIcon = icon
            completion()
        }
    }
    
    //MARK: 获取用户原始头像
    func getUserIcon(type: KPNetWork.IconType, completion: @escaping (_ icon: String?) -> ()) {
        
        KPNetWork.getUserIcon(type: type) { (result) in
            
            guard result.response?.statusCode == 200, let data = result.data, let json = try? JSON.init(data: data),
                let status = json["status"].string else {
                    return
            }
            
            let icon = json["resData"].string
            print("get user icon: \(status), icon:\(String(describing: icon))")
            completion(icon)
        }
        
    }
}

extension KPMineViewController: KPMineSettingViewControllerDelegate {
    func userHeaderIconChanged(icon: UIImage) {
        headerIcon = icon
    }
    
    func userBgThemeIconChanged(icon: UIImage) {
        themeBgIcon = icon
    }
}
