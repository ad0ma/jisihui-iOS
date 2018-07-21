//
//  KPAddIdeaController.swift
//  KP
//
//  Created by 王宇宙 on 2018/2/27.
//  Copyright © 2018年 adoma. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Qiniu

class KPAddIdeaController: UITableViewController {
    
    @IBOutlet var cells: [UITableViewCell]!
    @IBOutlet weak var ideaCoverButton: UIButton!
    @IBOutlet weak var ideaTextView: UITextView!
    @IBOutlet weak var bookCoverButton: UIButton!
    @IBOutlet weak var bookNameLabel: UILabel!
    @IBOutlet weak var authorNameLabel: UILabel!
    @IBOutlet weak var doubanScoreLabel: UILabel!
    var selectBook: JSON? = nil
    var selectImage: UIImage? = nil
    var picKey: String? = nil
    

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
        caremaBtn.backgroundColor = UIColor.clear
        caremaBtn.setBackgroundImage(UIImage.init(named: "paizhao"), for: .highlighted)
        caremaBtn.setBackgroundImage(UIImage.init(named: "paizhao"), for: .normal)
        caremaBtn.addTarget(self, action: #selector(cameraAction), for: .touchUpInside)
        pickerView.addSubview(caremaBtn)
        let albumBtn = UIButton()
        albumBtn.frame = CGRect(x: 105, y: 20, width: 45, height: 59)
        albumBtn.setBackgroundImage(UIImage.init(named: "xiangce"),
                                    for: .highlighted)
        albumBtn.setBackgroundImage(UIImage.init(named: "xiangce"), for: .normal)
        albumBtn.addTarget(self, action: #selector(albumAction), for: .touchUpInside)
        pickerView.addSubview(albumBtn)
        return pickerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.title = "编辑想法";
        self.edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        ideaTextView.layer.borderColor = RGBCOLOR(r: 220, g: 220, b: 220).cgColor
        ideaTextView.layer.borderWidth = 0.5
        ideaCoverButton.imageView?.contentMode = .scaleAspectFill
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addIdeaCover(_ sender: UIButton) {
        
        showImagePicker()
    }
    
    @IBAction func addBook(_ sender: UIButton) {
        let vc = UIStoryboard.init(name: "SelectBookStoryboard", bundle: nil).instantiateInitialViewController() as! KPSelectBookController
        vc.selectBookblock = {(book)-> () in
            self.selectBook = book
            self.bookCoverButton.kf.setImage(with: URL.init(string: book["imgUrl"].stringValue), for: .normal)
            self.bookNameLabel.text = book["name"].stringValue
            self.authorNameLabel.text = book["author"].stringValue
            self.doubanScoreLabel.text = "豆瓣评分:\(String(format: "%.1f", book["doubanScore"].floatValue))"
            
        }
        self.present(vc, animated: true, completion: nil);
    }
    
    
    @IBAction func publishIdea(_ sender: UIButton) {
        view.endEditing(true)
//        if selectImage == nil {
//            KPHud.showText(text: "请选择一张封面图")
//            return
//        }
//        if picKey == nil || picKey?.count == 0 {
//            KPHud.showText(text: "图片未上传成功,请重试!")
//            return
//        }
        if ideaTextView.text.count == 0 {
            KPHud.showText(text: "请输入您的想法")
            return
        }
        var para = ["content": ideaTextView.text] as [String: Any]
//        if selectBook == nil {
//            KPHud.showText(text: "请选择一本图书")
//            return
//        }
        if (selectBook != nil) {
            para["bookId"] = selectBook!["id"].stringValue
        }
        if picKey != nil && picKey?.count != 0 {
            para["pictureKey"] = picKey!
        }
        KPHud.showWaiting()
        KPNetWork.request(path: "m/auth/idea", method: .post, requestType: .json, para: para) { (result) in
            KPHud.hideNotice()
            guard let data = result.data else {
                return
            }
            if let json = try? JSON.init(data: data) {
                guard json["data"].number != nil else{
                    KPHud.showText(text: json["code"].stringValue, delay: 1)
                    return
                }
                KPHud.showText(text: "发表成功!", delay: 0.8)
                NotificationCenter.default.post(name: NSNotification.Name.init("NewIdeaPostSuccess"), object: nil)
                self.perform(#selector(self.pop), with: nil, afterDelay: 1)
            }else{
                KPHud.showText(text: "发表失败, 请重试!", delay: 1)
            }
        }
    }
    
    @objc func pop() -> Void {
        self.kp_navigationController?.popViewController(animated: true)
    }
    
}




//Delegate/Datasource
extension KPAddIdeaController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 2
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.cells[indexPath.row]
        return cell
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}


//图片选择相关
extension KPAddIdeaController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePicker() -> Void {
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
   @objc func cameraAction()-> Void {
        hideImagePicker()
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        self.present(cameraPicker, animated: true, completion: nil)
    }
    
    @objc func albumAction()-> Void {
        hideImagePicker()
        let photoPicker = UIImagePickerController()
        photoPicker.delegate = self
        photoPicker.sourceType = .photoLibrary
        photoPicker.navigationBar.isTranslucent = false;//解决视图被导航栏遮蔽
        self.present(photoPicker, animated: true, completion: nil)
    }
    
    //
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.dismiss(animated: true, completion: nil)
        //获得照片
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        ideaCoverButton.setImage(image, for: .normal)
        self.selectImage = image
    
        let token = "CA-L8M9-lX5NsZ8eqUCHTd-JV0w_jHqrdOiRxI9r:WSfQb6Ol4l6Di9uIdS3EO0SA2sg=:eyJzY29wZSI6ImtpbmRsZXB1c2gtdGVzdCIsImRlYWRsaW5lIjoxODgxMDExMTUxfQ=="
        let timeInterval = Date().timeIntervalSince1970 * 1000
        let key = "\(KPUser.share.account!)\(timeInterval)"//key规则为用户account加时间戳
        let imgData = UIImageJPEGRepresentation(image, 0.8)
        let uploadManager = QNUploadManager()
        uploadManager?.put(imgData!, key: key, token: token, complete: { (info, key, resp) in
            if (info?.isOK)! {
                KPHud.showText(text: "上传成功!");
                self.picKey = key
            }else{
                KPHud.showText(text: "上传失败,请稍后重试!");
            }
        }, option: nil)
    }
    

}

