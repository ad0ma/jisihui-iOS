//
//  KPRankListController.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/29.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON

class KPRankListController: KPBaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @objc var rankList = UITableView()
    
    var weekList: [KPBookModel]?
    var monthList: [KPBookModel]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "排行榜"

        rankList = UITableView.init(frame: CGRect.init(x: 0, y: kLayoutNavH, width: Main_Screen_Width, height: Main_Screen_Height - kLayoutNavH))
        
        rankList.backgroundColor = Content_Color
        rankList.separatorInset = .zero
        rankList.separatorColor = Separator_Color
        rankList.tableFooterView = UIView()
        
        rankList.rowHeight = 50
        
        view.addSubview(rankList)
        
        rankList.spr_setIndicatorHeader {
            self.getRankData()
        }
        
        rankList.spr_headerEnable()
        rankList.spr_beginRefreshing()
    }
    
    func getRankData() -> Void {
        
        KPNetWork.request(path: "m/weekAndMonth", method: .get) { (result) in
            
            guard let data = result.data else {
                return
            }
            
            if result.response?.statusCode == 200, let json = try? JSON.init(data: data) {
                                
                self.weekList = json["week"].arrayValue.compactMap{KPBookModel.init(json: $0)}
                self.monthList = json["month"].arrayValue.compactMap{KPBookModel.init(json: $0)}
                
                self.rankList.delegate = self
                self.rankList.dataSource = self
                
                self.rankList.reloadData()
                self.rankList.spr_headerEndRefreshing()
            }
            
        }
    }
    
    //MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return weekList?.count ?? 0
        case 1:
            return monthList?.count ?? 0
            
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0 where weekList?.count == 0:
            return 0
            
        case 1 where monthList?.count == 0:
            return 0
            
        default:
            return 40
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        switch section {
        case 0 where weekList?.count == 0:
            return nil
        case 1 where monthList?.count == 0:
            return nil
            
        default:
            break
        }
        
        let headerBase  = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Main_Screen_Width, height: 40))
        
        headerBase.backgroundColor = Content_Color
        
        let title = UIButton.init(type: .custom)
        title.setTitleColor(Detail_Text_Color, for: .normal)
        title.isUserInteractionEnabled = false
        title.setImage(UIImage.init(named: "ic_hot"), for: .normal)
        
        headerBase.addSubview(title)
        
        title.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.centerY.equalToSuperview()
            make.height.lessThanOrEqualToSuperview()
        }
        
        let titleStr = section == 0 ? "周推榜" : "月推榜"
        
        title.setTitle(titleStr, for: .normal)
        
        return headerBase
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var rankCell = tableView.dequeueReusableCell(withIdentifier: "rankCell")
        
        if rankCell == nil {
            rankCell = UITableViewCell.init(style: .value1, reuseIdentifier: "rankCell")
            
            rankCell?.selectionStyle = .none
            rankCell?.textLabel?.font = UIFont.systemFont(ofSize: 13)
            rankCell?.textLabel?.textColor = Main_Text_Color
            rankCell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
            rankCell?.detailTextLabel?.textColor = Sub_Text_Color
        }
        
        let attrTitle = NSMutableAttributedString()
        
        var name: String = ""
        var author: String? = ""
        
        let idxAttr: NSAttributedString!
        let idx = String.init(format: "%d. ", indexPath.row + 1)
        
        if indexPath.row < 3 {
            idxAttr = NSAttributedString.init(string: idx, attributes: [NSAttributedStringKey.foregroundColor:Red_Text_Color])
        } else {
            idxAttr = NSAttributedString.init(string: idx, attributes: [NSAttributedStringKey.foregroundColor:UIColor.black])
        }
        
        attrTitle.append(idxAttr)
        
        switch indexPath.section {
        case 0:
            name = weekList?[indexPath.row].name ?? ""
            author = weekList?[indexPath.row].author ?? ""
            
        case 1:
            name = monthList?[indexPath.row].name ?? ""
            author = monthList?[indexPath.row].author ?? ""
            
        default:
            break
        }
        
        let nameAttr = NSAttributedString.init(string: name, attributes: [NSAttributedStringKey.foregroundColor:Main_Text_Color, NSAttributedStringKey.font:UIFont.systemFont(ofSize: 15)])
        
        attrTitle.append(nameAttr)

        rankCell?.textLabel?.attributedText = attrTitle
        rankCell?.detailTextLabel?.text = author
        
        return rankCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let bookInfo = KPBookInfoController.instance

        
        switch indexPath.section {
        case 0:
            (bookInfo.kp_self as! KPBookInfoController).bookId = weekList![indexPath.row].id!
            
        case 1:
            (bookInfo.kp_self as! KPBookInfoController).bookId = monthList![indexPath.row].id!
        default:
            break
        }

        self.navigationController?.pushViewController(bookInfo, animated: true)
    }

}
