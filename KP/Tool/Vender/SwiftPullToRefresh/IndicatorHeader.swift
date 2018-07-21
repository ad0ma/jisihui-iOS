//
//  IndicatorHeader.swift
//  SwiftPullToRefresh
//
//  Created by Leo Zhou on 2017/4/30.
//  Copyright © 2017年 Leo Zhou. All rights reserved.
//

import UIKit

final class IndicatorHeader: RefreshView {
    private let indicatorItem = IndicatorItem()

    init(height: CGFloat, action: @escaping () -> Void) {
        super.init(height: height, action: action)

        layer.addSublayer(indicatorItem.arrowLayer)
        addSubview(indicatorItem.indicator)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("SwiftPullToRefresh: init(coder:) has not been implemented")
    }
    
    override func didUpdateState(statu: RefreshView.Status) {
        super.didUpdateState(statu: statu)
        indicatorItem.didUpdateState(statu: statu)
    }

    override func didUpdateProgress(_ progress: CGFloat) {
        indicatorItem.didUpdateProgress(progress)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        indicatorItem.arrowLayer.position = center
        indicatorItem.indicator.center = center
    }
}
