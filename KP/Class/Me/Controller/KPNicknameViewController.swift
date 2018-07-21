//
//  KPNicknameViewController.swift
//  KP
//
//  Created by Shawley on 18/03/2018.
//  Copyright © 2018 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON

class KPNicknameViewController: KPBaseViewController {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var textField: UITextField!
    
    var nickname: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "修改昵称"
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "完成", style: .plain, target: self, action: #selector(changeNickNameAction))
        nickname = KPUser.share.nick
        textField.text = nickname
    }
    
    @objc private func changeNickNameAction() {
        textField.resignFirstResponder()
        KPHud.showWaiting()
        updateUserInfo { (result) in
            
            if result {
                KPUser.share.nick = self.nickname
                self.navigationController?.popViewController(animated: true)
            }
            
            KPHud.showText(text: result ? "修改成功" : "修改失败")
        }
    }
    
    func updateUserInfo(completion: @escaping (_ result: Bool) -> ()) {
        
        KPNetWork.updateUserInfo(nickName: nickname) { (result) in
            
            guard result.response?.statusCode == 200, let data = result.data, let json = try? JSON.init(data: data),
                let status = json["status"].string else {
                completion(false)
                return
            }
            
            completion(status == "success")
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension KPNicknameViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        nickname = textField.text
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 15
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
