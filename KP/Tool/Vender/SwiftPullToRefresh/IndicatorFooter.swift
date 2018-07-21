//
//  IndicatorFooter.swift
//  SwiftPullToRefresh
//
//  Created by Leo Zhou on 2017/5/1.
//  Copyright © 2017年 Leo Zhou. All rights reserved.
//

import UIKit

final class IndicatorFooter: RefreshView {
    private let indicatorItem = IndicatorItem()

    private let isAuto: Bool

    @objc init(height: CGFloat, isAuto: Bool = false, action: @escaping () -> Void) {
        self.isAuto = isAuto
        super.init(height: height, style: isAuto ? .autoFooter : .footer, action: action)

        if !isAuto {
            layer.addSublayer(indicatorItem.arrowLayer)
        }

        addSubview(indicatorItem.indicator)
        addSubview(indicatorItem.tipLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("SwiftPullToRefresh: init(coder:) has not been implemented")
    }

    override func didUpdateState(statu: RefreshView.Status) {
        super.didUpdateState(statu: statu)
        indicatorItem.didUpdateState(statu: statu)
    }

    override func didUpdateProgress(_ progress: CGFloat) {
        indicatorItem.didUpdateProgress(progress, isFooter: true)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        if !isAuto {
            indicatorItem.arrowLayer.position = center
        }

        indicatorItem.indicator.center = center
        indicatorItem.tipLabel.sizeToFit()
        indicatorItem.tipLabel.center = center
    }
}
