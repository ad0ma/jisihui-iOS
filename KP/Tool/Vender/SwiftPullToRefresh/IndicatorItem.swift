//
//  IndicatorItem.swift
//  SwiftPullToRefresh
//
//  Created by Leo Zhou on 2017/4/30.
//  Copyright © 2017年 Leo Zhou. All rights reserved.
//

import UIKit

final class IndicatorItem {
    lazy var arrowLayer: CAShapeLayer = {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 8))
        path.addLine(to: CGPoint(x: 0, y: -8))
        path.move(to: CGPoint(x: 0, y: 8))
        path.addLine(to: CGPoint(x: 5.66, y: 2.34))
        path.move(to: CGPoint(x: 0, y: 8))
        path.addLine(to: CGPoint(x: -5.66, y: 2.34))

        let layer = CAShapeLayer()
        layer.path = path.cgPath
        layer.strokeColor = UIColor.black.withAlphaComponent(0.8).cgColor
        layer.lineWidth = 2
        layer.lineCap = kCALineCapRound
        return layer
    }()

    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.text = Default.noMoreDataText
        label.font = Default.font
        label.textColor = Default.color
        label.isHidden = true
        return label
    }()
    
    func didUpdateState(statu: RefreshView.Status) {
        
        switch statu {
            
        case .refreshing:
            arrowLayer.isHidden = true
            tipLabel.isHidden = true
            indicator.startAnimating()
            
        case .idle:
            arrowLayer.isHidden = false
            tipLabel.isHidden = true
            indicator.stopAnimating()
            
        case .noMoreData:
            arrowLayer.isHidden = true
            indicator.stopAnimating()
            tipLabel.isHidden = false
            
        default:
            tipLabel.isHidden = true
        }

    }

    func didUpdateProgress(_ progress: CGFloat, isFooter: Bool = false) {
        if isFooter {
            arrowLayer.transform = progress == 1 ? CATransform3DIdentity : CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
        } else {
            arrowLayer.transform = progress == 1 ? CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1) : CATransform3DIdentity
        }
    }
}
