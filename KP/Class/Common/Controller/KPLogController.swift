//
//  KPLogController.swift
//  KP
//
//  Created by Adoma on 2017/12/31.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON

let tagTextFont = UIFont.systemFont(ofSize: 16)
let keyTextFont = UIFont.boldSystemFont(ofSize: 14)
let detailTextFont = UIFont.systemFont(ofSize: 14)



extension NSMutableAttributedString {
    
    func append(element: Any) {
        
        switch element {
        case let dict as [String: Any]:
            append(dicStr(dic: dict))
            
        case let array as [Any]:
            append(arrStr(arr: array))
            
        case let str as String:
            append(NSAttributedString.init(string: "\"\(str)\"", attributes: [NSAttributedStringKey.foregroundColor: Main_Text_Color]))
            
        case let num as NSNumber:
            append(NSAttributedString.init(string: "\(num)", attributes: [NSAttributedStringKey.foregroundColor: Green_Text_Color, NSAttributedStringKey.font: detailTextFont]))
            
        case let bool as Bool:
            append(NSAttributedString.init(string: bool ? "true":"false", attributes: [NSAttributedStringKey.foregroundColor: Red_Text_Color, NSAttributedStringKey.font: detailTextFont]))
        default:
            append(NSAttributedString.init(string: "\(element)"))
        }
        
    }
}

func dicStr(dic: [String: Any]) -> NSAttributedString {
    
    let muAttr = NSMutableAttributedString.init(string: "{\n", attributes: [NSAttributedStringKey.foregroundColor: Blue_Color, NSAttributedStringKey.font: tagTextFont])
    
    for (key, value) in dic {
        
        let keyAttr = NSAttributedString.init(string: key, attributes: [NSAttributedStringKey.foregroundColor: UIColor.black,NSAttributedStringKey.font: keyTextFont])
        
        muAttr.append(keyAttr)
        
        muAttr.append(NSAttributedString.init(string: "："))

        muAttr.append(element: value)
        
        muAttr.append(NSAttributedString.init(string: " ,\n", attributes: [NSAttributedStringKey.foregroundColor: UIColor.blue, NSAttributedStringKey.font: keyTextFont]))

    }
    
    muAttr.append(NSAttributedString.init(string: "}", attributes: [NSAttributedStringKey.foregroundColor: Blue_Color, NSAttributedStringKey.font: tagTextFont]))
    
    return muAttr
}

func arrStr(arr: [Any]) -> NSAttributedString {
    
    let muAttr = NSMutableAttributedString.init(string: "[\n", attributes: [NSAttributedStringKey.foregroundColor: Green_Text_Color, NSAttributedStringKey.font: tagTextFont])

    for (idx, element) in arr.enumerated() {

        muAttr.append(NSAttributedString.init(string: "\(idx)：", attributes: [NSAttributedStringKey.foregroundColor: UIColor.black,NSAttributedStringKey.font: UIFont.systemFont(ofSize: 13)]))

        muAttr.append(element: element)
        
        muAttr.append(NSAttributedString.init(string: ",\n", attributes: [NSAttributedStringKey.foregroundColor: UIColor.blue, NSAttributedStringKey.font: keyTextFont]))

    }
    
    muAttr.append(NSAttributedString.init(string: "]", attributes: [NSAttributedStringKey.foregroundColor: Green_Text_Color, NSAttributedStringKey.font: tagTextFont]))

    return muAttr
}

struct KPLog {
    
    var requestType = "POST"
    var requestUrl = ""
    var requestHeader: [String : String]? 
    var parament: [String: Any]?
    var requestTime = ""
    var requestDuration = ""
    var result = ""
    var attrResult: NSAttributedString {
        
        let resultJson = JSON.init(parseJSON: result)
        
        let muAttr = NSMutableAttributedString.init(string:"\n  [\(requestType)] " + requestUrl, attributes: [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 13), NSAttributedStringKey.foregroundColor: Blue_Color])
        
        muAttr.append(NSAttributedString.init(string: "\n\n"))
        
        muAttr.append(NSAttributedString.init(string: "请求头:\n", attributes: [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 15), NSAttributedStringKey.foregroundColor: UIColor.darkText]))
        
        if let header = requestHeader {
            muAttr.append(element: header)
        }
        
        muAttr.append(NSAttributedString.init(string: "\n\n\n"))

        muAttr.append(NSAttributedString.init(string: "请求参数:\n", attributes: [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 15), NSAttributedStringKey.foregroundColor: UIColor.darkText]))
        
        if let parament = parament {
            muAttr.append(dicStr(dic: parament))
        } else {
            muAttr.append(NSAttributedString.init(string: "\t无", attributes: [NSAttributedStringKey.font: keyTextFont, NSAttributedStringKey.foregroundColor: Red_Text_Color]))
        }
        
        muAttr.append(NSAttributedString.init(string: "\n\n\n"))
        
        muAttr.append(NSAttributedString.init(string: "响应数据:\n", attributes: [NSAttributedStringKey.font:UIFont.boldSystemFont(ofSize: 15), NSAttributedStringKey.foregroundColor: UIColor.darkText]))
        
        if let resultDic = resultJson.dictionaryObject {
            muAttr.append(dicStr(dic: resultDic))
        }
        else if let resultArr = resultJson.arrayObject {
            muAttr.append(arrStr(arr: resultArr))
        }
        else if let htmlData = result.data(using: .utf8),
            let resultHtmlStr = try? NSAttributedString.init(data: htmlData, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            muAttr.append(resultHtmlStr)
        }
        else {
            muAttr.append(NSAttributedString.init(string: result, attributes: [NSAttributedStringKey.foregroundColor: Main_Text_Color]))
        }
        
        return muAttr
    }
}

struct KPLogManager {
    static var logs = [KPLog]()
}

class KPLogController: KPBaseTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "close"), style: .plain, target: self, action: #selector(close))
        
        title = "接口日志"
        tableView.estimatedRowHeight = 50
    }
    
    static var log: UIViewController = {
        let vc = instance
        let navi = KPRootNavigationController.init(rootViewController: vc)
        return navi
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    @objc func close() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  KPLogManager.logs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var logCell = tableView.dequeueReusableCell(withIdentifier: "logCell")
        
        if logCell == nil {
            logCell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "logCell")
        }
        
        let log = KPLogManager.logs[indexPath.row]
        
        logCell?.textLabel?.font = UIFont.systemFont(ofSize: 13)
        logCell?.textLabel?.textColor = Main_Text_Color
        
        logCell?.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        logCell?.detailTextLabel?.textColor = Blue_Color
        logCell?.detailTextLabel?.numberOfLines = 0
        
        logCell?.textLabel?.text = log.requestTime + " 耗时: " + log.requestDuration
        logCell?.detailTextLabel?.text = "[\(log.requestType)] " + log.requestUrl
        logCell?.accessoryType = .disclosureIndicator
        
        return logCell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let moreIns = KPMoreInsController.instance
        
        moreIns.kp_self.title = "日志详情"
        
        let log = KPLogManager.logs[indexPath.row]
        
        (moreIns.kp_self as! KPMoreInsController).setAttrText(text:log.attrResult)
        
        self.navigationController?.pushViewController(moreIns, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

