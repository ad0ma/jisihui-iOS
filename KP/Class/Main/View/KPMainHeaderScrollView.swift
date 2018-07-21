//
//  KPMainHeaderScrollView.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/26.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import Kingfisher

class KPMainHeaderScrollView: UIView, UIScrollViewDelegate {
    
    private var pageControl: UIPageControl! = nil
    
    private var scroll: UIScrollView! = nil
    
    typealias TapBlock = (Int) -> ()
    
    var tapBlock: TapBlock?
    
    
    init(images: [String]) {
        
        let height: CGFloat = 200
        
        //MARK: 设置宽高
        let frame = CGRect.init(x: 0, y: 0, width: Main_Screen_Width, height: height)
        super.init(frame: frame)
        
        scroll = UIScrollView.init(frame: self.bounds)
        scroll.showsHorizontalScrollIndicator = false
        scroll.isPagingEnabled = true
        scroll.delegate = self;
        
        addSubview(scroll)
        
        let imageArr = [images.last!] + images //3 1 2 3
        
        for (idx, str) in imageArr.enumerated() {
            let imgV = UIImageView.init(frame: CGRect.init(x: CGFloat(idx) * Main_Screen_Width, y: 0, width: Main_Screen_Width, height: height))
            
            imgV.kf.setImage(with: URL.init(string: str), placeholder: UIImage.init(named: "book_default"))
            
//            imgV.backgroundColor = .random
            
            scroll.addSubview(imgV)
            
            let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapImage(sender:)))
            
            imgV.isUserInteractionEnabled = true
            imgV.addGestureRecognizer(tap)
            
        }
        
        scroll.contentSize = CGSize.init(width: Main_Screen_Width * CGFloat(imageArr.count), height: height)
        
        scroll.contentOffset = CGPoint.init(x: Main_Screen_Width, y: 0)
        
        //MARK: pagecontrol
        pageControl = UIPageControl.init()
        addSubview(pageControl)
        
        pageControl.numberOfPages = images.count
        
        pageControl.snp.makeConstraints { (make) in
            make.width.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        //MARK: start timer
        let timer = Timer.init(timeInterval: 10, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer, forMode: .commonModes)
    }
    
    //MARK: UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        var scrollCurrentIndex = scrollView.contentOffset.x / Main_Screen_Width - 1
        
        let scrollMaxIndex = scrollView.contentSize.width / Main_Screen_Width - 2
        
        if (scrollCurrentIndex < 0) {
            scrollCurrentIndex = scrollMaxIndex;
        }
        
        pageControl?.currentPage = Int(scrollCurrentIndex)
        
        if ((scrollView.contentOffset.x + Main_Screen_Width) > scrollView.contentSize.width) {
            
            scrollView.setContentOffset(.zero, animated: false)
        }
        
        if (scrollView.contentOffset.x < 0) {
            
            scrollView.setContentOffset(CGPoint.init(x: Main_Screen_Width * (scrollMaxIndex + 1), y: 0), animated: false)
        }
    }
    
    //MARK: timer action
    @objc func timerAction() {
        
        var currentOffsetX = scroll.contentOffset.x
        
        if currentOffsetX + Main_Screen_Width == scroll.contentSize.width {
            scroll.contentOffset = .zero
            currentOffsetX = 0
        }

        scroll.setContentOffset(CGPoint.init(x: currentOffsetX + Main_Screen_Width, y: 0), animated: true)
    }
    
    //MARK: tap image
    @objc private func tapImage(sender: UIGestureRecognizer) {
        let tag = pageControl.currentPage
        tapBlock?(tag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
