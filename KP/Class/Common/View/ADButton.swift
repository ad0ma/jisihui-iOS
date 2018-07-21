//
//  ADButton.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/31.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit

class ADButton: UIButton {

    /// 从0到3 -> 上、左、下、右
    @IBInspectable var imageAlignmentType: Int = 1
    
    @IBInspectable var spaceBetweenTitleAndImage: CGFloat = 5
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let space = spaceBetweenTitleAndImage
        
        let titleW: CGFloat = self.titleLabel?.bounds.size.width ?? 0
        let titleH: CGFloat = self.titleLabel?.bounds.size.height ?? 0
        
        let imageW: CGFloat = self.imageView?.bounds.size.width ?? 0
        let imageH: CGFloat = self.imageView?.bounds.size.height ?? 0
        
        let btnCenterX = self.bounds.size.width*0.5
        let imageCenterX = btnCenterX - titleW*0.5
        let titleCenterX = btnCenterX + imageW*0.5

        switch (imageAlignmentType)
        {
        case 1: //left
            titleEdgeInsets = UIEdgeInsetsMake(0, space/2, 0,  -space/2);
            
            imageEdgeInsets = UIEdgeInsetsMake(0, -space/2, 0, space);
            
        case 2: //bottom
            titleEdgeInsets = UIEdgeInsetsMake(-(imageH/2+space/2), -(titleCenterX-btnCenterX), imageH/2 + space/2, titleCenterX-btnCenterX)
            
            imageEdgeInsets = UIEdgeInsetsMake(titleH/2 + space/2, btnCenterX-imageCenterX,-(titleH/2+space/2), -(btnCenterX-imageCenterX))
            
        case 3: //right
            titleEdgeInsets = UIEdgeInsetsMake(0, -(imageW + space/2), 0, imageW + space/2)
            
            imageEdgeInsets = UIEdgeInsetsMake(0, titleW+space/2, 0, -(titleW+space/2))
            
        default: // 0 top
            titleEdgeInsets = UIEdgeInsetsMake(imageH/2
                + space/2, -(titleCenterX-btnCenterX), -(imageH/2 + space/2), titleCenterX-btnCenterX)
            
            imageEdgeInsets = UIEdgeInsetsMake(-(titleH/2 + space/2), btnCenterX-imageCenterX, titleH/2+space/2, -(btnCenterX-imageCenterX))
        }
    }

}
