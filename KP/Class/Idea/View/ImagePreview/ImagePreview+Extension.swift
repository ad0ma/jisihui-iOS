//
//  ImagePreview+Extension.swift
//  ImagePreview
//
//  Created by wyz on 2018/2/5.
//  Copyright © 2017年 wyz. All rights reserved.
//

import UIKit

// MARK: - 使用方法
extension UIImageView {

    // 开启预览
    func preview() {
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(show))
        self.addGestureRecognizer(tap)
    }
    
    // show
    @objc private func show() {
        let ip = ImagePreview(imageView: self)
        self.isHidden = true
        ip.show()
    }

}

extension ImagePreview {
    
    // 显示图片放大器
    public func show() {
        UIApplication.shared.keyWindow?.addSubview(self)
        self.showAnimate()
    }
}


