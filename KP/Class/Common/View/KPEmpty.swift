//
//  YQLEmptyView.swift
//  YQL
//
//  Created by Adoma on 2017/9/26.
//  Copyright © 2017年 huazhiying. All rights reserved.
//

import UIKit

class KPEmpty: UIView {
    
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    class func empty(image: String = "results_icon_fail", title: String) -> KPEmpty {
        
        let emptyView = Bundle.main.loadNibNamed("KPEmpty", owner: nil, options: nil)?.last! as! KPEmpty
        
        emptyView.image.image = UIImage.init(named: image)
        
        emptyView.title.text = title
        
        return emptyView
    }
    

}
