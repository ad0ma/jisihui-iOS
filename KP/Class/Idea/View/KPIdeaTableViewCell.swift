//
//  KPIdeaTableViewCell.swift
//  KP
//
//  Created by 王宇宙 on 2018/2/6.
//  Copyright © 2018年 adoma. All rights reserved.
//

import UIKit
import SwiftyJSON
import Kingfisher

protocol IdeaTableViewCellActionDelegate {
    func likeAction(ideaId: String, cell: KPIdeaTableViewCell) -> Void
    func collectAction(ideaId: String, cell: KPIdeaTableViewCell) -> Void
    func shareAction(ideaId: String) -> Void
    func commentAction(ideaId: String) -> Void
    func headImageClickAction(ideaId: String) -> Void
    func authorClickAction(authorId: String) -> Void
    func bookClickAction(bookId: String) -> Void
    func deleteIdeaAction(ideaId: String) -> Void
    func showAllContent(showAll:Bool, ideaId: String, cell: KPIdeaTableViewCell) -> Void
}

class KPIdeaTableViewCell: UITableViewCell {
    
    let kImageViewWH = 100
    var delegate: IdeaTableViewCellActionDelegate?
    var pageControl: UIPageControl!
    var ideaId: String = ""
    var showAll: Bool = false
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var createTimeLabel: UILabel!
    @IBOutlet weak var contentLabel: UITextView!
    @IBOutlet weak var bookContainerView: UIView!
    @IBOutlet weak var collectButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var showAllContentButton: UIButton!
    
    @IBOutlet weak var showAllHeight: NSLayoutConstraint!
    @IBOutlet weak var bookheight: NSLayoutConstraint!
    var collectsCount: Int = 0
    var likesCount: Int = 0
    
    var data: JSON? {
        didSet {
            
            ideaId = data!["id"].stringValue
            let content = data!["content"].stringValue;
            
            contentLabel.text = content
            
            let bookInfo = data!["book"].dictionary
            bookContainerView.viewWithTag(10001)?.removeFromSuperview()
            if bookInfo != nil {
                bookheight.constant = 90
                self.loadBooks(books: [bookInfo!])
            }else{
                bookheight.constant = 0
            }
            
            let contentHeight = KPIdeaTableViewCell.getContentLabelHeight(content)
            let overMaxHeight = (contentHeight + 35 + 57 + 30 + (bookInfo == nil ? 0 : 90)) > 320
            showAllContentButton.isHidden = !overMaxHeight
            showAllHeight.constant = overMaxHeight ? 20 : 0
            
            let userInfo = data!["user"].dictionaryValue
            nameLabel.text = userInfo["nickName"]?.stringValue
            if let avatarUrl = userInfo["originalImageUrl"]?.string {
                avatarImageView.kf.setImage(with: URL.init(string: avatarUrl), placeholder: #imageLiteral(resourceName: "icon_user"))
            } else {
                avatarImageView.image = #imageLiteral(resourceName: "icon_user")
            }
            
            if(KPUser.share.isLogin){
                let currentUid = KPUser.share.id
                let uid = data!["userId"].intValue
                deleteButton.isHidden = currentUid != uid;
            }
            
            collectsCount = data!["collectsCount"].intValue
            likesCount = data!["likesCount"].intValue
            collectButton.setTitle("(\(collectsCount))", for: .normal)
            likeButton.setTitle("(\(likesCount))", for: .normal)
            
            //时间戳
            let timeStamp = data!["createDate"].intValue/1000
            let timeInterval:TimeInterval = TimeInterval(timeStamp)
            let date = Date(timeIntervalSince1970: timeInterval)
            let dformatter = DateFormatter()
            dformatter.dateFormat = "yyyy/MM/dd HH:mm"
            createTimeLabel.text = dformatter.string(from: date)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        avatarImageView.layer.borderColor = Main_Theme_Color.cgColor
        avatarImageView.layer.borderWidth = 1
        avatarImageView.layer.cornerRadius = CGFloat(avatarImageView.bounds.width / 2)
        avatarImageView.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}


//子视图相关
extension KPIdeaTableViewCell: IdeaBookViewActionDelegate, UIScrollViewDelegate {
    
    //加载书籍
    func loadBooks(books: [[String: JSON]]) -> Void {
        let scrollView = UIScrollView()
        scrollView.tag = 10001
        scrollView.frame = CGRect(x: 0, y: 0, width: Main_Screen_Width, height: 90)
        scrollView.contentSize = CGSize(width: Int(Main_Screen_Width) * books.count, height: 90)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        bookContainerView.addSubview(scrollView)
        
        pageControl = UIPageControl()
        pageControl.frame = CGRect(x: 0, y: 94-30, width: Main_Screen_Width, height: 30)
        pageControl.numberOfPages = books.count
        pageControl.currentPageIndicatorTintColor = Main_Theme_Color
        pageControl.pageIndicatorTintColor = UIColor.lightGray
        pageControl.isHidden = books.count < 2
        bookContainerView.addSubview(pageControl)
        
        for index in 0..<books.count {
            let bookView = Bundle.main.loadNibNamed("KPIdeaBookView", owner: self, options: nil)?.last as! KPIdeaBookView
            bookView.frame = CGRect(x: CGFloat(index) * Main_Screen_Width,
                                    y: 0,
                                    width: Main_Screen_Width,
                                    height: 90)
            bookView.bookInfo = books[index]
            bookView.delegate = self
            scrollView.addSubview(bookView);
        }
    }
    
    //书籍点击事件代理
    func bookDidClicked(bookId: String) {
        guard delegate != nil else {
            return
        }
        delegate?.bookClickAction(bookId: bookId)
    }
    
    //UIScrollView代理
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentIndex = scrollView.contentOffset.x/Main_Screen_Width
        pageControl.currentPage = Int(currentIndex)
    }
}


//事件相关
extension KPIdeaTableViewCell {
    //喜欢
    @IBAction func likeAction(_ sender: UIButton) {
        guard delegate != nil else {
            return
        }
        delegate?.likeAction(ideaId: ideaId, cell: self)
    }
    //收藏
    @IBAction func collectAction(_ sender: UIButton) {
        guard delegate != nil else {
            return
        }
        delegate?.collectAction(ideaId: ideaId, cell: self)
    }
    //评论
    @IBAction func commentAction(_ sender: UIButton) {
        guard delegate != nil else {
            return
        }
        delegate?.commentAction(ideaId: ideaId)
    }
    //分享
    @IBAction func shareAction(_ sender: UIButton) {
        guard delegate != nil else {
            return
        }
        delegate?.shareAction(ideaId: ideaId)
    }
    //封面图片点击
    @IBAction func headImageClickAction(_ sender: UIButton) {
        guard delegate != nil else {
            return
        }
        delegate?.headImageClickAction(ideaId: "headImage")
    }
    //作者点击
    @IBAction func authorClickAction(_ sender: UIButton) {
        guard delegate != nil else {
            return
        }
        delegate?.authorClickAction(authorId: "author")
    }
    //删除想法
    @IBAction func deleteIdeaAction(_ sender: UIButton) {
        guard delegate != nil else {
            return
        }
        delegate?.deleteIdeaAction(ideaId: ideaId)
    }
    @IBAction func showAllContentAction(_ sender: UIButton) {
        guard delegate != nil else {
            return
        }
        showAll = !showAll;
        delegate?.showAllContent(showAll: showAll, ideaId: ideaId, cell: self)
    }
}


//计算高度的类方法
extension KPIdeaTableViewCell {
    
    //计算字符串需要的高度
    static func getContentLabelHeight(_ content: String) -> CGFloat {
        let content = content as NSString
        let maxSize = CGSize(width: Main_Screen_Width - 30, height: 1000)
        let params = [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14.1)]
        let contentSize = content.boundingRect(with: maxSize, options: [.truncatesLastVisibleLine, .usesFontLeading ,.usesLineFragmentOrigin], attributes: params, context: nil).size
        return contentSize.height
    }
}
