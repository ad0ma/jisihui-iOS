//
// ImagePreview.swift
// ImagePreview
//
// Created by wyz on 2018/2/5.
// Copyright © 2017年 wyz. All rights reserved.
//

import UIKit

class ImagePreview: UIView {
    
    fileprivate let minScale: CGFloat = 1.0 //最小的缩放比例
    fileprivate var newImage: UIImageView!  //新图
    fileprivate var oldImage: UIImageView!  //原图
    fileprivate let animDuration: TimeInterval = 0.3 //动画时长
    fileprivate var scale: CGFloat = 1.0    //当前的缩放比例
    fileprivate var touchX: CGFloat = 0.0   //双击点的X坐标
    fileprivate var touchY: CGFloat = 0.0   //双击点的Y坐标
    fileprivate var isHideAnimate = false   //是否隐藏动画
    fileprivate var maxScale: CGFloat { //最大的缩放比例
        get {
            let bounds = self.oldImage.bounds
            let imageHeight = bounds.height / bounds.width * self.frame.width
            return self.frame.height / imageHeight
        }
    }
    static let blurViewAlpha: CGFloat = 0.9
    
    
    convenience init(imageView: UIImageView) {
        self.init(frame: UIScreen.main.bounds)
        UIApplication.shared.isStatusBarHidden = true
        
        self.oldImage = imageView//保存原始frame
        self.addSubview(self.blurView)
        self.addSubview(self.scrollView)

        self.newImage = UIImageView(image: imageView.image)
        self.newImage.frame = CGRect(origin: self.oldPoint, size: self.oldImage.bounds.size)
        self.scrollView.addSubview(self.newImage)
    
        
    }

    //原位置
    fileprivate lazy var oldPoint: CGPoint = {
        let superview = self.oldImage.superview
        let view = UIApplication.shared.keyWindow
        let frame = superview?.convert(self.oldImage.frame, to: view)
        return frame?.origin ?? CGPoint.zero
    }()
    
    //毛玻璃效果
    fileprivate lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = ImagePreview.blurViewAlpha
        blurView.frame.size = UIScreen.main.bounds.size
        return blurView
    }()
    
    //滚动视图
    fileprivate lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.minimumZoomScale = self.minScale
        scrollView.maximumZoomScale = self.maxScale
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.clear
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        //单击
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(sender:)))
        tap.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(tap)
        //双击
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(sender:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)
        tap.require(toFail: doubleTap)
        return scrollView
    }()
    
    //显示动画
    func showAnimate() {
        UIView.animate(
            withDuration: self.animDuration,
            delay: 0,
            options: UIViewAnimationOptions.beginFromCurrentState,
            animations: {
                self.newImage.frame.size.width = self.scrollView.frame.width
                self.newImage.frame.size.height = self.oldImage.frame.height / self.oldImage.frame.width * self.scrollView.frame.width
                self.newImage.frame.origin.x = 0
                self.newImage.frame.origin.y = (self.scrollView.frame.height - self.newImage.frame.height) / 2
        }) { (finished) in
            
        }
    }
    
    //隐藏动画
    @objc fileprivate func hideAnimate() {
        UIView.animate(
            withDuration: self.animDuration,
            delay: 0,
            options: UIViewAnimationOptions.beginFromCurrentState,
            animations: {
                self.blurView.alpha = 0
                self.newImage.frame = CGRect(origin: self.oldPoint, size: self.oldImage.frame.size)
                UIApplication.shared.isStatusBarHidden = false
                
        }) { (finished) in
            self.oldImage.isHidden = false
            self.scale = self.minScale
            self.scrollView.removeFromSuperview()
            self.removeFromSuperview()
            
        }
    }
    
    
    //手势点击事件
    @objc private func tapGestureAction(sender: UITapGestureRecognizer) {
        //显示隐藏导航
        if sender.numberOfTapsRequired == 1 {
            self.hideAnimate()
            
        } else if sender.numberOfTapsRequired > 1 {
            self.touchX = sender.location(in: sender.view).x
            self.touchY = sender.location(in: sender.view).y
            if self.scale > 1.0 {
                self.scale = 1.0
                self.scrollView.setZoomScale(self.scale, animated: true)
            } else {
                self.scale = self.maxScale
                self.scrollView.setZoomScale(self.maxScale, animated: true)
            }
        }
    }
    
}

extension ImagePreview: UIScrollViewDelegate {
    
    //设置要缩放的 scrollView 上面的子视图
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.newImage
    }
    
    //当scrollView缩放时，调用该方法, 计算保持newImage在放大过程中的位置居中
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if self.frame.height > self.newImage.frame.height {
            self.newImage.frame.origin.y = (self.frame.height - self.newImage.frame.height) / 2
        } else {
            self.newImage.frame.origin.y = 0
        }
    }
    
    //保存当前缩放倍数
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.scale = scale
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let top = abs(scrollView.contentOffset.y)
        if !self.isHideAnimate {
            blurView.alpha = ImagePreview.blurViewAlpha * (70-top) / 70
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let top = abs(scrollView.contentOffset.y)
        self.isHideAnimate = top > 70

        if self.isHideAnimate {
            guard self.scale == 1 else {
                return
            }
            self.hideAnimate()
        }
    }
}
