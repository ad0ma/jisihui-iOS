//
//  KPAboutController.swift
//  KP
//
//  Created by ad0ma on 2017/6/29.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

typealias Info = (title: String, value: String)
var infos: [Info]?

class KPAboutController: KPBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var version: UILabel!
    
    @IBOutlet weak var infoTable: UITableView!
    
    convenience init() {
        self.init(nibName: "KPAboutController", bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "关于我们"
        
        let infoDictionary = Bundle.main.infoDictionary
        
        let shortVerion = infoDictionary!["CFBundleShortVersionString"] as! String
        
        let versionNum = infoDictionary!["CFBundleVersion"] as! String
        
        version.text = "版本: v" + shortVerion + "   " + "版本号: " + versionNum
        
        infoTable.tableFooterView = UIView()
        
        if infos == nil {
            infoTable.isHidden = true
            
            KPHud.showWaiting()
            let random = arc4random()%10
            Alamofire.request("http://ohuvywma6.bkt.clouddn.com/about.json?v=\(random)").responseJSON { (complete) in
                
                KPHud.hideNotice()
                if complete.result.isSuccess {
                    guard let data = complete.data else {
                        return
                    }
                    
                    let json = JSON(data)
                    
                    if let infoArr = json.array {
                        
                        infos = infoArr.map {($0["title"].stringValue,$0["value"].stringValue)}
                    }
                    
                    self.infoTable.isHidden = false
                    self.infoTable.delegate = self
                    self.infoTable.dataSource = self
                    self.infoTable.reloadData()
                }
            }
            
        } else {
            
            self.infoTable.delegate = self
            self.infoTable.dataSource = self
            self.infoTable.reloadData()
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infos?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier")
        
        if cell == nil {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: "reuseIdentifier")
            cell?.selectionStyle = .none
            cell?.textLabel?.font = UIFont.systemFont(ofSize: 15)
            cell?.textLabel?.textColor = Main_Text_Color
            cell?.detailTextLabel?.font = UIFont.systemFont(ofSize: 14)
            cell?.detailTextLabel?.textColor = Sub_Text_Color
        }
        
        let attrDic = [NSAttributedStringKey.foregroundColor: RGBCOLOR(r: 43, g: 229, b: 206), NSAttributedStringKey.underlineStyle: 1, NSAttributedStringKey.baselineOffset: 1] as [NSAttributedStringKey : Any]
        
        let info = (infos?[indexPath.row])!
        
        let title = info.title + "："
        let value = info.value
        
        if value.hasPrefix("http://") {
            cell?.detailTextLabel?.attributedText = NSAttributedString.init(string: value, attributes: attrDic)
        } else {
            cell?.detailTextLabel?.text = value
        }
        
        cell?.textLabel?.text = title
        
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let info = (infos?[indexPath.row])!
        
        let value = info.value
        
        if value.hasPrefix("http://") {
            UIApplication.shared.openURL(URL.init(string: value)!)
        }
    }
}
