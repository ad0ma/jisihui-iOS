//
//  KPSelectBookController.swift
//  KP
//
//  Created by 王宇宙 on 2018/3/3.
//  Copyright © 2018年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON

class KPSelectBookController: UIViewController {
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var headerHeight: NSLayoutConstraint!
    
    
    var books: [JSON] = []
    var selectBookblock: ((_ selectedBook: JSON) -> ())?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        searchTextField.layer.borderColor = RGBCOLOR(r: 220, g: 220, b: 220).cgColor
        searchTextField.layer.borderWidth = 0.5
        searchTextField.layer.cornerRadius = 17
        let paddingView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 5, height: 34))
        searchTextField.leftView = paddingView;
        searchTextField.leftViewMode = .always;
        tableView.register(UINib.init(nibName: "KPSelectBookCell", bundle: nil), forCellReuseIdentifier: "book");
        tableView.tableFooterView = UIView()
        headerHeight.constant = kLayoutNavH
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancelAction(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func TextChanged(_ sender: UITextField) {
        searchBook()
    }
    func searchBook() -> Void {
        let ecode = self.searchTextField.text!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        KPNetWork.request(path: "m/search/" + ecode, method: .get){ (result) in
            guard let data = result.data else {
                return
            }
            if result.response?.statusCode == 200, let json = try? JSON.init(data: data) {
                self.books = json.arrayValue
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
    }
}


extension KPSelectBookController: UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "book", for: indexPath) as! KPSelectBookCell
        cell.data = books[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
        if  selectBookblock != nil {
            selectBookblock!(books[indexPath.row])
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return books.count > 0 ? 40 : 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerView
    }
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBook()
        view.endEditing(true)
        return true
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

