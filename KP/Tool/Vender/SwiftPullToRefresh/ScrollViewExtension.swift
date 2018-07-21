//
//  ScrollViewExtension.swift
//  SwiftPullToRefresh
//
//  Created by Leo Zhou on 2017/4/30.
//  Copyright © 2017年 Leo Zhou. All rights reserved.
//

import UIKit

private var refreshHeaderKey: UInt8 = 0
private var refreshFooterKey: UInt8 = 0

public extension UIScrollView {
    
    @objc private var spr_refreshHeader: RefreshView? {
        get {
            return objc_getAssociatedObject(self, &refreshHeaderKey) as? RefreshView
        }
        set {
            objc_setAssociatedObject(self, &refreshHeaderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            newValue.map { insertSubview($0, at: 0) }
        }
    }
    
    @objc private var spr_refreshFooter: RefreshView? {
        get {
            return objc_getAssociatedObject(self, &refreshFooterKey) as? RefreshView
        }
        set {
            objc_setAssociatedObject(self, &refreshFooterKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            newValue.map { insertSubview($0, at: 0) }
        }
    }
    
    
    @objc public func spr_setIndicatorHeader(height: CGFloat = Default.short,
                                             action: @escaping () -> Void) {
        spr_refreshHeader = IndicatorHeader(height: height, action: action)
    }
    
    @objc public func spr_setIndicatorFooter(height: CGFloat = Default.short,
                                             action: @escaping () -> Void) {
        spr_refreshFooter = IndicatorFooter(height: height, isAuto: true, action: action)
    }
    
    /// begin refreshing
    @objc public func spr_beginRefreshing() {
        if spr_refreshHeader?.statu == .idle {
            spr_refreshHeader?.beginRefreshing()
        }
    }
    
    /// headerEndRefreshing
    @objc public func spr_headerEndRefreshing() {
        if spr_refreshHeader?.statu == .refreshing {
            spr_refreshHeader?.endRefreshing()
        }
    }
    
    /// footerEndRefreshing
    @objc public func spr_footerEndRefreshing(_ noMoreData: Bool = false) {
        if spr_refreshFooter?.statu == .refreshing {
            spr_refreshFooter?.endRefreshing(noMoreData: noMoreData)
        }
    }
    
    /// footerRest
    @objc public func spr_footerRest() {
        if spr_refreshFooter?.statu == .noMoreData {
            spr_refreshFooter?.statu = .idle
        }
    }
    
    /// headerEnable
    @objc public func spr_headerEnable() {
        if spr_refreshHeader?.statu == .ready {
            spr_refreshHeader?.statu = .idle
        }
    }
    
    /// footerEnable
    @objc public func spr_footerEnable() {
        if spr_refreshFooter?.statu == .ready {
            spr_refreshFooter?.statu = .idle
        }
        
        if spr_refreshFooter?.statu == .noMoreData {
            spr_refreshFooter?.statu = .idle
        }
    }
}

// MARK: default values
public struct Default {
   public static let color: UIColor = UIColor.black.withAlphaComponent(0.8)
   public static let font: UIFont = UIFont.systemFont(ofSize: 14)
   public static let loadingText = "Loading..."
   public static let pullingText = "Pull down to refresh"
   public static let releaseText = "Release to refresh"
   public static let pullingFooterText = "Pull up to load more"
   public static let releaseFooterText = "Release to load more"
   public static let noMoreDataText = "没有更多了哦~"
   public static let high: CGFloat = 100
   public static let short: CGFloat = 40
}
