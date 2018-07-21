//
//  KPMineSettingViewController.swift
//  KP
//
//  Created by Shawley on 17/03/2018.
//  Copyright © 2018 adoma. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

@objc protocol KPMineSettingViewControllerDelegate {
    func userHeaderIconChanged(icon: UIImage)
    func userBgThemeIconChanged(icon: UIImage)
}

class KPMineSettingViewController: KPBaseTableViewController {
    
    typealias CellAction = (title: String, action: Selector?)
    
    var data: [[CellAction]] {
        return [[("头像", #selector(showImagePicker)), ("主页背景", #selector(showImagePicker)), ("昵称", #selector(toNickname))],
                [("账号与邮箱设置", #selector(toUserInfo))]]
    }
    
    lazy var footerView: KPCustomSignatureView = {
        let footer = Bundle.main.loadNibNamed("KPCustomSignatureView", owner: nil, options: nil)?.first as! KPCustomSignatureView
        
        return footer
    }()
    
    var selectedIndexPath: IndexPath?
    var headerIcon: UIImage?
    var themeBgIcon: UIImage?
    
    weak var delegate: KPMineSettingViewControllerDelegate?
    
    var selectedTitle: String? {
        if let indexPath = selectedIndexPath {
            return data[indexPath.section][indexPath.row].title
        }
        return nil
    }
    
    var cellActionList: Array<CellAction>? {
        if let indexPath = selectedIndexPath {
            return data[indexPath.section]
        }
        return nil
    }
    
    lazy var imagePickerView: UIView = {
        let backView = UIView()
        backView.backgroundColor = UIColor.clear
        backView.frame = UIScreen.main.bounds
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(hideImagePicker));
        backView.addGestureRecognizer(tap)
        return backView
    }()
    
    lazy var pickerView: UIView = {
        let pickerView = UIView();
        pickerView.backgroundColor = UIColor.white
        pickerView.frame = CGRect(x: Main_Screen_Width/2-85, y: -100, width: 170, height: 100)
        let caremaBtn = UIButton()
        caremaBtn.frame = CGRect(x: 20, y: 20, width: 45, height: 59)
        caremaBtn.setBackgroundImage(UIImage.init(named: "paizhao"), for: .normal)
        caremaBtn.addTarget(self, action: #selector(cameraAction), for: .touchUpInside)
        pickerView.addSubview(caremaBtn)
        let albumBtn = UIButton()
        albumBtn.frame = CGRect(x: 105, y: 20, width: 45, height: 59)
        albumBtn.setBackgroundImage(UIImage.init(named: "xiangce"), for: .normal)
        albumBtn.addTarget(self, action: #selector(albumAction), for: .touchUpInside)
        pickerView.addSubview(albumBtn)
        return pickerView
    }()
    
    override init(style: UITableViewStyle) {
        super.init(style: .grouped)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = UIColor.clear
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = Content_Color
        tableView.registerReusableCell(KPMineSettingTableViewCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @objc private func toNickname() {
        let nickname = KPNicknameViewController.instance
        
        self.navigationController?.pushViewController(nickname, animated: true)
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
}

extension KPMineSettingViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(indexPath: indexPath) as KPMineSettingTableViewCell
        let title = data[indexPath.section][indexPath.row].title
        cell.title.text = title
        
        var image: UIImage?
        var imageString: String?
        var detail: String?
        switch title {
        case "头像":
            cell.icon.layer.cornerRadius = cell.icon.bounds.width / 2
            cell.icon.layer.masksToBounds = true
            imageString = KPUser.share.headerIcon
            image = headerIcon
        case "主页背景":
            imageString = KPUser.share.themeBgIcon
            image = themeBgIcon
        case "昵称":
            detail = KPUser.share.nick
        default:
            break
        }
        
        if let image = image {
            cell.icon.image = image
        } else if let imageString = imageString {
            cell.icon.kf.setImage(with: URL(string: imageString))
        }
        
        cell.detail.text = detail
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        selectedIndexPath = indexPath
        guard let sel = data[indexPath.section][indexPath.row].action else {
            return
        }
        perform(sel)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 150.0
        }
        return 10.0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            let footerView = Bundle.main.loadNibNamed("KPCustomSignatureView", owner: nil, options: nil)?.first as! KPCustomSignatureView
            footerView.delegate = self
            footerView.textView.text = KPUser.share.introduce
            footerView.count.text = "\(KPUser.share.introduce?.count ?? 0)/\(KPCustomSignatureView.maxLength)"
            return footerView
        }
        return nil
    }
    
}

extension KPMineSettingViewController: KPCustomSignatureViewDelegate {
    
    func textChanged(text: String?) {
        changeSignature(text: text)
    }
    
    func changeSignature(text: String?) {
        
        if KPUser.share.introduce == text {
            return
        }
        
        KPHud.showWaiting()
        KPNetWork.updateUserInfo(introduce: text) { (result) in
            
            KPHud.hideNotice()
            guard result.response?.statusCode == 200, let data = result.data, let json = try? JSON.init(data: data),
                let status = json["status"].string else {
                    KPHud.showText(text: "操作失败")
                    return
            }
            
            if status == "success" {
                KPHud.showText(text: "修改成功")
                KPUser.share.introduce = text
            } else {
                KPHud.showText(text: "操作失败")
            }
            
        }
    }
}

//图片选择相关
extension KPMineSettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @objc func showImagePicker() -> Void {
        imagePickerView.addSubview(pickerView)
        navigationController?.view.addSubview(imagePickerView);
        UIView.animate(withDuration: 0.25) {
            self.imagePickerView.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
            self.pickerView.center = self.view.center
        }
    }
    
    @objc func hideImagePicker() -> Void {
        UIView.animate(withDuration: 0.25, animations: {
            self.imagePickerView.backgroundColor = UIColor.clear
            self.pickerView.frame = CGRect(x: Main_Screen_Width/2-85, y: -100, width: 170, height: 100)
        }) { (true) in
            self.imagePickerView.removeFromSuperview()
        }
    }
    
    //
    @objc func cameraAction() -> Void {
        hideImagePicker()
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        if self.selectedTitle == "头像" {
            cameraPicker.allowsEditing = true
        }
        self.present(cameraPicker, animated: true, completion: nil)
    }
    
    @objc func albumAction() -> Void {
        hideImagePicker()
        let photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        photoPicker.sourceType = .photoLibrary
        photoPicker.navigationBar.isTranslucent = false;//解决视图被导航栏遮蔽
        if self.selectedTitle == "头像" {
            photoPicker.allowsEditing = true
        }
        self.present(photoPicker, animated: true, completion: nil)
    }
    
    //
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        
        //获得照片
        guard let title = self.selectedTitle, let image = info[title == "头像" ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        var type = KPNetWork.IconType.Header
        if title == "主页背景" {
            type = KPNetWork.IconType.Background
        }
        
        uploadUserIcon(img: image, type: type) { [weak self] result, icon in
            switch title {
            case "头像":
                self?.headerIcon = icon
                self?.delegate?.userHeaderIconChanged(icon: icon)
            case "主页背景":
                self?.themeBgIcon = icon
                self?.delegate?.userBgThemeIconChanged(icon: icon)
            default:
                break
            }
            self?.tableView.reloadData()
        }
    }
    
    private func compressImage(_ image: UIImage, toByte maxLength: Int) -> Data? {
        
        var compression: CGFloat = 1
        let oriData = UIImageJPEGRepresentation(image, compression)
        
        guard var data = oriData, data.count > maxLength else { return oriData }
        
        // Compress by size
        var max: CGFloat = 1
        var min: CGFloat = 0
        for _ in 0..<6 {
            compression = (max + min) / 2
            data = UIImageJPEGRepresentation(image, compression)!
            if CGFloat(data.count) < CGFloat(maxLength) * 0.9 {
                min = compression
            } else if data.count > maxLength {
                max = compression
            } else {
                break
            }
        }
        var resultImage: UIImage = UIImage(data: data)!
        if data.count < maxLength { return data }
        
        // Compress by size
        var lastDataLength: Int = 0
        while data.count > maxLength, data.count != lastDataLength {
            lastDataLength = data.count
            let ratio: CGFloat = CGFloat(maxLength) / CGFloat(data.count)
            let size: CGSize = CGSize(width: Int(resultImage.size.width * sqrt(ratio)),
                                      height: Int(resultImage.size.height * sqrt(ratio)))
            UIGraphicsBeginImageContext(size)
            resultImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            resultImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            data = UIImageJPEGRepresentation(resultImage, compression)!
        }
        return data
    }
    
    func uploadUserIcon(img: UIImage, type: KPNetWork.IconType, closure: @escaping (_ result: Bool, _ icon: UIImage) -> Void) {
        
        guard let imageData = compressImage(img, toByte: 100_000) else {
            return
        }
        print("jpeg image length: \(imageData.count)")
        KPHud.showWaiting()
        KPNetWork.uploadUserIcon(data: imageData, type: type) { (result) in
        
            guard result.response?.statusCode == 200, let data = result.data, let json = try? JSON.init(data: data),
                let status = json["status"].string else {
                    KPHud.showText(text: "上传失败")
                    return
            }
            
            let urlString = json["resData"].stringValue
            let result = status == "success"
            closure(result, img)
            print("status:\(status), icon:\(String(describing: urlString))")
            KPHud.showText(text: result ? "上传成功" : "上传失败")
        }
    }
}
