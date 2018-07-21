//
//  KPPaymentController.swift
//  KP
//
//  Created by Adoma on 2017/7/13.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class KPPaymentController: KPBaseTableViewController {
    
    var payInfos: [KPPayInfoModel]?
    
    var payType: String?
    
    typealias statuCallBack = (Bool) -> Void
    var callBack: statuCallBack?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "会员中心"

        tableView.rowHeight = 50
        tableView.registerReusableCell(KPPayInfoCell.self)
        getPayInfo()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    override init(style: UITableViewStyle) {
        super.init(style: .grouped)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getPayInfo() -> Void {
        
        KPHud.showWaiting()
        
        KPNetWork.request(path: "m/pay/info", method: .get) { (result) in
            
            KPHud.hideNotice()
            
            guard let data = result.data else {
                return
            }
            
            if result.response?.statusCode == 200, let json = try? JSON.init(data: data) {
                
                self.payInfos = json.arrayValue.compactMap{ KPPayInfoModel.init(json: $0) }
                
                self.payType = self.payInfos?.first?.type
                
                self.addHeaderFooter()
                
                self.tableView.reloadData()
                
            } else {
                KPHud.showText(text: "网络请求失败")
            }
        }
    }
    
    func addHeaderFooter() -> Void {
        //MARK: header
        let headerBg = UIView.init(frame: CGRect.init(x: 0, y: 0, width: Main_Screen_Width, height: 100))
        headerBg.backgroundColor = .clear
        
        tableView.tableHeaderView = headerBg
        
        let name = UILabel.init()
        headerBg.addSubview(name)
        
        name.text = KPUser.share.nick
        name.textColor = Main_Text_Color
        name.font = UIFont.systemFont(ofSize: 18)
        name.textAlignment = .center
        
        name.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(headerBg.snp.centerY)
        }
        
        let tip = UILabel.init()
        headerBg.addSubview(tip)
        
        tip.text = KPUser.share.isVip ? "到期时间：" + KPUser.share.vipDate : "开通会员可享更多推送数量哦~"
        tip.textColor = Sub_Text_Color
        tip.font = UIFont.systemFont(ofSize: 15)
        tip.textAlignment = .center
        
        tip.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(name.snp.bottom).offset(10)
        }
        
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
        
        if KPUser.share.isVip {
            resign.setTitle("续费", for: .normal)
        } else {
            resign.setTitle("开通", for: .normal)
        }
        
        resign.addTarget(self, action: #selector(payAction), for: .touchUpInside)
        
        resign.snp.makeConstraints { (make) in
            make.edges.equalTo(UIEdgeInsetsMake(20, 30, 0, 30))
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return payInfos?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let payCell = tableView.dequeueReusableCell(indexPath: indexPath) as KPPayInfoCell
        
        payCell.textLabel?.font = UIFont.systemFont(ofSize: 18)
        payCell.textLabel?.textColor = Main_Text_Color
        
        let info = payInfos![indexPath.row]
        
        payCell.desc?.text = info.description
        
        if let realStr = info.realMoney {
            
            let mAttr = NSMutableAttributedString.init()
            
            let real = NSAttributedString.init(string: realStr, attributes: [NSAttributedStringKey.foregroundColor: Red_Text_Color, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)])
            
            mAttr.append(real)
            mAttr.append(NSAttributedString.init(string: "元  ", attributes: [NSAttributedStringKey.foregroundColor: Red_Text_Color, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)]))
            
            if info.sale,
               let oriStr = info.originMoney {
                
                let ori = NSAttributedString.init(string:"原价" + oriStr + "元", attributes: [NSAttributedStringKey.foregroundColor: Sub_Text_Color, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12), NSAttributedStringKey.strikethroughStyle: 1, NSAttributedStringKey.baselineOffset: 0])
                
                mAttr.append(ori)
            }
            
            payCell.price?.attributedText = mAttr
        } else {
            payCell.price?.attributedText = nil
        }
        
        payCell.check.isHidden = info.type != payType;
        
        return payCell
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Main_Screen_Width / 4.54
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIImageView.init(image: UIImage.init(named: "tequan"))
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let info = payInfos![indexPath.row]
        payType = info.type
        tableView.reloadData()
    }
    
    @objc func payAction() -> Void {
        
        guard let payType = payType else {
            return
        }
        
        KPHud.showWaiting()
        
        KPNetWork.request(path: "m/auth/pay/\(payType)", method: .get) { (result) in
            
            KPHud.hideNotice()
            
            guard let data = result.data else {
                return
            }
            
            let json = JSON.init(data)
            
            let qrdata = json["data"]
            
            let qrcode = KPPaymentQRCodeController.instance

            let qr = qrcode.kp_self as! KPPaymentQRCodeController

            qr.titleLabel.text = qrdata["subject"].string
            qr.qrcode.image = UIImage.init(data: Data.init(base64Encoded: qrdata["qrCode"].stringValue.components(separatedBy: ",").last!)!)
            qr.orderId = qrdata["orderId"].stringValue
            
            qr.callBack = self.callBack

            self.navigationController?.pushViewController(qrcode, animated: true)
        }
    }
}
