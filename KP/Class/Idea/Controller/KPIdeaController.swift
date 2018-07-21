//
//  KPIdeaController.swift
//  KP
//
//  Created by 王宇宙 on 2018/2/6.
//  Copyright © 2018年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class KPIdeaController: UIViewController {

    var ideas: [JSON] = []
    var currentPage: Int = 1
    var totalPage: Int = 1
    var likeDic: [String: String] = ["-1": "false"]
    var collectDic: [String: String] = ["-1": "false"]
    var showAllDic: [String: String] = ["-1": "false"]

    //关注/热门Segment
    lazy var segment: UISegmentedControl = {
        var segment = UISegmentedControl(items: ["关注", "热门"])
        segment.frame = CGRect(x: 0, y: 0, width: 120, height: 30)
        segment.selectedSegmentIndex = 0
        segment.tintColor = RGBCOLOR(r: 31, g: 177, b: 138)
        segment.backgroundColor = UIColor.clear
        segment.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .selected)
        segment.addTarget(self, action: #selector(segmentChanged(sender:)), for: .valueChanged)
        return segment
    }()
   
    //新增想法
    lazy var addButtonItem: UIButton = {
        var btn = UIButton()
        btn.frame = CGRect(x: Main_Screen_Width-50, y: Main_Screen_Height-kLayoutTabH-50, width: 44, height: 44)
        btn.setImage(UIImage.init(named: "add"), for: .normal)
        btn.addTarget(self, action: #selector(addIdeaAction), for: .touchUpInside)
        return btn
    }()
    //空白页面
    lazy var whiteView: UIView = {
        var view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: Main_Screen_Width, height: Main_Screen_Height-kLayoutNavH-kLayoutTabH)
        view.backgroundColor = UIColor.white
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 40, width: Main_Screen_Width, height: 20)
        label.text = "暂无数据..."
        label.textColor = UIColor.lightGray
        label.textAlignment = .center
        view.addSubview(label)
        return view
    }()
    //Main
    lazy var tableView: UITableView = {
        let frame = CGRect(x: 0, y: kLayoutNavH, width: Main_Screen_Width, height: Main_Screen_Height - kLayoutNavH - kLayoutTabH)
        var tableview = UITableView(frame: frame, style: .grouped)
        tableview.backgroundColor = RGBCOLOR(r: 238, g: 238, b: 238)
        tableview.register(UINib.init(nibName: "KPIdeaTableViewCell", bundle: nil), forCellReuseIdentifier: "ideacell");
        tableview.delegate = self
        tableview.dataSource = self
        tableview.showsVerticalScrollIndicator = false
        tableview.tableFooterView = UIView()
        tableview.tableHeaderView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0.01))
        tableview.spr_setIndicatorHeader {
           
            self.currentPage = 1
            self.getIdeaList()
        }
        tableview.spr_headerEnable()
        return tableview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //self.navigationItem.titleView = segment
        self.navigationItem.title = "想法"
        self.view.addSubview(tableView)
        self.view.addSubview(addButtonItem)
        
        tableView.spr_beginRefreshing()
        
        NotificationCenter.default.addObserver(self, selector: #selector(userPostNewIdea), name: NSNotification.Name.init("NewIdeaPostSuccess"), object: nil)
    }
    
    @objc func userPostNewIdea() {
        tableView.spr_beginRefreshing()
    }

}

//事件相关
extension KPIdeaController{
    @objc func segmentChanged(sender: UISegmentedControl) -> Void {
        print("segmentChanged:\(sender.selectedSegmentIndex)")
    }
    
    @objc func addIdeaAction() -> Void {
        print("add")
        if !KPUser.share.isLogin {
//            KPHud.showText(text: "请登录!")
            let login = KPLoginController.instance
            self.navigationController?.pushViewController(login, animated: true)
            return
        }
        let vc = UIStoryboard.init(name: "AddIdeaStoryboard", bundle: nil).instantiateInitialViewController()
        let base = UIViewController()
        base.view.backgroundColor = Content_Color
        let navi = KPBaseNavigationController.init(rootViewController: vc!)
        base.addChildViewController(navi)
        base.view.addSubview(navi.view)
        self.navigationController?.pushViewController(base, animated: true)
    }
}


//网络相关
extension KPIdeaController{
    
    //列表
    func getIdeaList() -> Void {
        
//        let temp = "auth/idea/my"
        let temp = "idea/hot"
        KPNetWork.request(path: "m/\(temp)/page?page=\(currentPage)&pageSize=10", method: .get) { (result) in
            self.tableView.spr_headerEndRefreshing()
            guard result.response?.statusCode == 200 else{
                return
            }
            guard let data = result.data, let json = try? JSON.init(data: data)  else {
                return
            }
            print(json);
            if self.currentPage == 1 {
                self.ideas = []
            }
            self.ideas += json.dictionaryValue["data"]!.arrayValue
            self.totalPage = json.dictionaryValue["totalPage"]!.intValue
            //刷新列表
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        }
    }
    //删除
    //     请求地址： /m/auth/idea/{ideaId}
     //    请求方法： DELETE
    func deleteIdea(ideaId: String) -> Void {
        KPNetWork.request(path: "m/auth/idea/\(ideaId)", method: .delete) { (result) in
            
            if result.response?.statusCode == 200 {
                guard let data = result.data else {
                    return
                }
                if let json = try? JSON.init(data: data) {
                    print(json);
                    KPHud.showText(text: "想法删除成功!", delay: 1)
                    self.tableView.spr_beginRefreshing()
                }
            }
        }
    }
    //喜欢
    //    请求地址： /m/auth/idea/{ideaId}/like
    //    请求方法：POST
    //    请求方法： DELETE
    
    func likeIdea(method: KPNetWork.MethodType, ideaId: String) -> Void {
        KPNetWork.request(path: "m/auth/idea/\(ideaId)/like", method: method) { (result) in
            
            if result.response?.statusCode == 200 {
                guard let data = result.data else {
                    return
                }
                if let json = try? JSON.init(data: data) {
                    print(json);
                    KPHud.showText(text: method == .delete ? "取消点赞成功" : "点赞成功", delay: 1)
                }
            }
        }
    }
    
    //收藏
    //    请求地址：/m/auth/idea/{id}/collect
    //    请求方法：POST
    //    请求方法：DELETE
    func collectIdea(method: KPNetWork.MethodType, ideaId: String) -> Void {
        KPNetWork.request(path: "m/auth/idea/\(ideaId)/collect", method: method) { (result) in
            
            if result.response?.statusCode == 200 {
                guard let data = result.data else {
                    return
                }
                if let json = try? JSON.init(data: data) {
                    print(json);
                    KPHud.showText(text: method == .delete ? "取消收藏成功" : "收藏成功", delay: 1)
                }
            }
        }
    }
    
    //分享
    
    
    //搜索
    func search(text: String) -> Void {
         let ecode = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        KPNetWork.request(path: "m/search/idea/\(ecode)", method: .get) { (result) in
            
            guard let data = result.data else {
                return
            }
            if let json = try? JSON.init(data: data) {
                print(json);
                self.ideas = json.arrayValue
                self.tableView.reloadData()
            }
        }
    }
}



//TableView相关
extension KPIdeaController: UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        tableView.tableFooterView = ideas.count == 0 ? whiteView : UIView()
        return ideas.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let data = ideas[indexPath.section]
        
        let content = data["content"].stringValue
        
        let contentHeight = KPIdeaTableViewCell.getContentLabelHeight(content)
        
        let rowHeight = contentHeight + 57/*作者*/ + 30 + (data["book"].dictionary != nil ? 90 : 0) + 35;
        
        return showAllDic[data["id"].stringValue] == "true" ? rowHeight+10 : min(320, rowHeight)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ideacell", for: indexPath) as! KPIdeaTableViewCell
        cell.selectionStyle = .none
        cell.delegate = self
        let data = ideas[indexPath.section];
        cell.data = data
        let ideaId = data["id"].stringValue
        cell.showAll = showAllDic[ideaId]=="true"
        cell.showAllContentButton.setTitle(cell.showAll ? "收起" : "展开", for: .normal)

        return cell;
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == ideas.count-2 && totalPage>currentPage {
            currentPage += 1
            getIdeaList()
        }
    }
}


//Cell上的点击事件
extension KPIdeaController: IdeaTableViewCellActionDelegate{
    func showAllContent(showAll: Bool, ideaId: String, cell: KPIdeaTableViewCell) {
        showAllDic[ideaId] = showAll ? "true" : "false"
        print(showAllDic);
        let indexPath = tableView.indexPath(for: cell)!
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    func deleteIdeaAction(ideaId: String) {
         print("this is delete action: \(ideaId)")
        let alert = UIAlertController.init(title: nil, message: "确定删除该想法吗?", preferredStyle: .alert)
        let cancel = UIAlertAction.init(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancel)
        let push = UIAlertAction.init(title: "确定", style: .default, handler: { (_) in
            self.deleteIdea(ideaId: ideaId)
        })
        alert.addAction(push)
        self.present(alert, animated: true, completion: nil)
    }
    
    func commentAction(ideaId: String) {
        print("this is comment action: \(ideaId)")

    }
    func likeAction(ideaId: String, cell: KPIdeaTableViewCell) {
        print("this is like action: \(ideaId)")
        if likeDic[ideaId] != "true" {
            likeDic[ideaId] = "true"
            cell.likesCount += 1
            cell.likeButton.setTitle("(\(cell.likesCount))", for: .normal)
            cell.likeButton.isSelected = true;
            likeIdea(method: .post, ideaId: ideaId)
        }else{
            likeDic[ideaId] = "false"
            if (cell.likesCount > 0){
                cell.likesCount -= 1
            }
            cell.likeButton.setTitle("(\(cell.likesCount))", for: .normal)
            cell.likeButton.isSelected = false;
            likeIdea(method: .delete, ideaId: ideaId)
        }
        
    }
    
    func collectAction(ideaId: String, cell: KPIdeaTableViewCell) {
        print("this is collect action: \(ideaId)")
        if collectDic[ideaId] != "true" {
            collectDic[ideaId] = "true"
            cell.collectsCount += 1
            cell.collectButton.setTitle("(\(cell.collectsCount))", for: .normal)
            cell.collectButton.isSelected = true;
            collectIdea(method: .post, ideaId: ideaId)
        }else{
            collectDic[ideaId] = "false"
            cell.collectsCount -= 1
            cell.collectButton.setTitle("(\(cell.collectsCount))", for: .normal)
            cell.collectButton.isSelected = false;
            collectIdea(method: .delete, ideaId: ideaId)
        }
    }
    
    func shareAction(ideaId: String) {
        print("this is share action: \(ideaId)")
    }
    
    func headImageClickAction(ideaId: String) {
        print("this is head image click action: \(ideaId)")
    }
    
    func authorClickAction(authorId: String) {
        print("this is author click action: \(authorId)")
        
        
    }
    func bookClickAction(bookId: String) {
        print("this is book click action: \(bookId)")
        let bookInfo = KPBookInfoController.instance
        (bookInfo.kp_self as! KPBookInfoController).bookId = bookId
        self.navigationController?.pushViewController(bookInfo, animated: true)
    }
    
}
