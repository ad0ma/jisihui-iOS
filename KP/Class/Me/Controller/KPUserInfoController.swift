//
//  KPUserInfoController.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/6/5.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON

class KPUserInfoController: KPBaseTableViewController {
    
    typealias UserInfo = (imageName: String, title: String, info: String?)
    var info: [UserInfo] = [("ic_drawer_account", "账号:", ""), ("ic_email", "推送邮箱:", "")]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "账号"
        
        info[0].info = KPUser.share.account
        info[1].info = KPUser.share.pushMail
        
        tableView.separatorColor = Line_Color
        tableView.separatorInset = UIEdgeInsetsMake(0, 14, 0, 14)
        tableView.rowHeight = 50
        tableView.contentInset = UIEdgeInsetsMake(15, 0, 0, 0)
        tableView.registerReusableCell(KPUserInfoCell.self)
        
        //MARK: footer
        let footerBg = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Main_Screen_Width, height: 60))
        footerBg.backgroundColor = .clear
        
        tableView.tableFooterView = footerBg
        
        let resign = UIButton.init(type: .custom)
        footerBg.addSubview(resign)
        resign.backgroundColor = Main_Theme_Color.withAlphaComponent(0.8)
        resign.layer.cornerRadius = 5
        resign.titleLabel?.font = UIFont.layoutFont(size: 15)
        resign.layer.shadowColor = Detail_Text_Color.cgColor
        resign.layer.shadowOffset = CGSize.init(width: 0, height: 2)
        resign.layer.shadowOpacity = 0.5
        resign.setTitle("退出登录", for: .normal)
        resign.addTarget(self, action: #selector(resignAction), for: .touchUpInside)
        
        resign.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(20, 30, 0, 30))
        }
    }
    
    @objc func resignAction() -> Void {
        KPUser.share.resign()
        if let tabBarController = UIApplication.shared.keyWindow?.rootViewController as? KPBaseTabBarController {
            let naviVC = tabBarController.selectedViewController as? KPRootNavigationController
            naviVC?.popToRootViewController(animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return info.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as KPUserInfoCell
        
        let userInfo = info[indexPath.row]
    
        cell.imgV.image = UIImage.init(named: userInfo.imageName)
        cell.title.text = userInfo.title
        cell.info.text = userInfo.info

        cell.rightImg.isHidden = indexPath.row != 1
        
        return cell
    }
    
    func editPushEmail(newEmail: String) -> Void {
        
        KPHud.showWaiting()
        
        KPNetWork.request(path: "m/auth/editpushmail", para: ["pushMail": newEmail]) { (result) in
            
            guard let data = result.data, let json = try? JSON.init(data: data) else {
                return
            }
            
            KPHud.showText(text: json["msg"].stringValue)
            
            if let status = json["status"].string,
                status == "success" {
                KPUser.share.getUserInfo()
                self.info[1].info = newEmail
                self.tableView.reloadData()
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let alert = UIAlertController.init(title: "修改推送邮箱", message: "", preferredStyle: .alert)
            
            let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
            
            let sure = UIAlertAction.init(title: "确定", style: .default, handler: { (_) in
                guard let newEmail = alert.textFields?.first?.text, (newEmail as NSString).length > 0 else {
                    KPHud.showText(text: "请输入有效邮箱")
                    return
                }
                
                self.editPushEmail(newEmail: newEmail)
            })
            
            alert.addAction(cancel)
            
            alert.addAction(sure)
            
            alert.addTextField(configurationHandler: { (textFiled) in
                textFiled.placeholder = "仅支持kindle或多看邮箱"
                textFiled.text = self.info[1].info
            })
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}
