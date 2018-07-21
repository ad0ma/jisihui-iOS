//
//  KPPaymentQRCodeController.swift
//  KP
//
//  Created by Adoma on 2018/6/27.
//  Copyright © 2018年 adoma. All rights reserved.
//

import UIKit

class KPPaymentQRCodeController: UIViewController {
    
    @IBOutlet weak var qrcode: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var orderId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "扫码支付"
        
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressAction(sender:)))
        qrcode.addGestureRecognizer(longPress)
    }
    
    @objc func longPressAction(sender: UIGestureRecognizer) {
        
        guard let img = qrcode.image else {
            return
        }
        
        if sender.state == .began {
            UIImageWriteToSavedPhotosAlbum(img, self, #selector(saveQRImageDone(image:error:info:)), nil)
        }
    }
    
    //  - (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
    @objc func saveQRImageDone(image: UIImage, error: NSError, info: UnsafeMutableRawPointer?) {
        
        let alert = UIAlertController.init(title: "二维码已保存至相册", message: "可通过支付宝或微信扫码支付\n如果确认充值成功却未能刷新VIP状态,可尝试多次刷新或联系客服QQ2171571258", preferredStyle: .alert)
        
        let success = UIAlertAction.init(title: "支付成功", style: .default) { (_) in
            KPHud.showWaiting()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5, execute: {
                self.orderSuccess()
            })
        }
        
        let fail = UIAlertAction.init(title: "取消", style: .default) { (_) in
            
        }
        
        alert.addAction(success)
        alert.addAction(fail)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    var time = 30
    
    typealias statuCallBack = (Bool) -> Void
    var callBack: statuCallBack?
    
    func orderSuccess() -> Void {
        
        if time == 0 {
            KPHud.showText(text: "订单确认失败")
            time = 30
            return
        }
        
        time -= 1
        
        self.checkOrderStatu(callBack: { (success) in
            if success {
                KPHud.showText(text: "支付成功")
                self.callBack?(true)
                self.navigationController?.popViewController(animated: true)
            } else {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1, execute: {
                    self.orderSuccess()
                })
            }
        })
        
    }
    
    func checkOrderStatu(callBack: @escaping statuCallBack) -> Void {
        
        KPNetWork.request(path: "m/auth/pay/status") { (result) in
            
            guard let data = result.data else {
                return
            }
            
            if result.response?.statusCode == 200, let json = try? JSON.init(data: data) {
                
                let statu = json["status"].string
                
                if statu == "paid" /*, cha < 10*60*/ {
                    callBack(true)
                } else {
                    callBack(false)
                }
                
            } else {
                KPHud.showText(text: "网络请求失败")
            }
            
        }
    }
    
    convenience init() {
        self.init(nibName: "KPPaymentQRCodeController", bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
