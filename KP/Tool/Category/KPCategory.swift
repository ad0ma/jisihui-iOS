//
//  KPCategory.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/23.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit
import Foundation

extension UIView {
    
    @objc var kp_x: CGFloat {
        
        set {
            self.frame.origin.x = newValue
        }
        
        get {
            return self.frame.origin.x
        }
    }
    
    @objc var kp_y: CGFloat {
        
        set {
            self.frame.origin.y = newValue
        }
        
        get {
            return self.frame.origin.y
        }
    }
    
    @objc var kp_width: CGFloat {
        
        set {
            self.frame.size.width = newValue
        }
        
        get {
            return self.frame.size.width
        }
    }
    
    @objc var kp_height: CGFloat {
        
        set {
            self.frame.size.height = newValue
        }
        
        get {
            return self.frame.size.height
        }
    }
    
    @objc var kp_origin: CGPoint {
        
        set {
            self.frame.origin = newValue
        }
        
        get {
            return self.frame.origin
        }
    }
    
    @objc var kp_size: CGSize {
        
        set {
            self.frame.size = newValue
        }
        
        get {
            return self.frame.size
        }
    }
    
    @objc var kp_centerX: CGFloat {
        
        set {
            self.center.x = newValue
        }
        
        get {
            return self.center.x
        }
    }
    
    @objc var kp_centerY: CGFloat {
        
        set {
            self.center.y = newValue
        }
        
        get {
            return self.center.y
        }
    }
    
    @objc var kp_minX: CGFloat {
        
        get {
            return self.frame.minX
        }
    }
    
    @objc var kp_midX: CGFloat {
        
        get {
            return self.frame.midX
        }
    }
    
    @objc var kp_maxX: CGFloat {
        
        get {
            return self.frame.maxX
        }
    }
    
    @objc var kp_minY: CGFloat {
        
        get {
            return self.frame.minY
        }
    }
    
    @objc var kp_midY: CGFloat {
        
        get {
            return self.frame.midY
        }
    }
    
    @objc var kp_maxY: CGFloat {
        
        get {
            return self.frame.maxY
        }
    }
}

extension UIViewController {
    
    @objc class var instance: UIViewController {
        
        let base = UIViewController()
        
        base.view.backgroundColor = Content_Color
        
        let content = self.init()
        _ = content.view
        
        let navi = KPBaseNavigationController.init(rootViewController: content)
        
        base.addChildViewController(navi)
        base.view.addSubview(navi.view)
        
        return base
    }
    
    @objc var kp_navigationController: UINavigationController? {
        guard let base = self.navigationController?.next?.next as? UIViewController else {
            return nil
        }
        return base.navigationController
    }
    
    @objc var kp_self: UIViewController {
        guard let navi = self.childViewControllers.first as? UINavigationController,
        let content = navi.topViewController else {
            return self
        }
        return content
    }
    
    var kp_name: String {
        return NSStringFromClass(type(of: self))
    }
    
}

//MARK: 
protocol Reusable: class {
    static var reuseIdentifier: String { get }
    static var nib: UINib? { get }
}

extension UITableViewCell: Reusable {
    
    @objc class var nib: UINib? {
        
        if Bundle.main.path(forResource: String(describing: self), ofType: ".nib") != nil {
            return Optional.some(UINib.init(nibName: String(describing: self), bundle: nil))
        }
        
        return nil
    }

   @objc class var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UITableView {
    
    func registerReusableCell<T: UITableViewCell>(_ cls: T.Type) {
        if let nib = cls.nib {
            self.register(nib, forCellReuseIdentifier: cls.reuseIdentifier)
        } else {
            self.register(cls.self, forCellReuseIdentifier: cls.reuseIdentifier)
        }
    }
    
    func dequeueReusableCell<T: UITableViewCell>(indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath as IndexPath) as! T
    }
}

extension UICollectionViewCell: Reusable {
    
    @objc class var nib: UINib? {
        
        if Bundle.main.path(forResource: String(describing: self), ofType: ".nib") != nil {
            return Optional.some(UINib.init(nibName: String(describing: self), bundle: nil))
        }
        
        return nil
    }
    
    @objc class var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionView {
    
    func registerReusableCell<T: UICollectionViewCell>(_: T.Type) {
        if let nib = T.nib {
            self.register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
        } else {
            self.register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
        }
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath as IndexPath) as! T
    }
}

extension UIColor {
    
    @objc class var random: UIColor {
        
        get {
            
            let r = arc4random()%255
            let g = arc4random()%255
            let b = arc4random()%255
            
            return RGBCOLOR(r: Float(r), g: Float(g), b: Float(b))
        }
    }
}

extension UIFont {
    @objc class func layoutFont(size: CGFloat) -> UIFont {
        return .systemFont(ofSize: kp_layout(size))
    }
}

extension String {
    //计算文字高度
    func caculateHeight(size: CGSize, font: UIFont) -> CGFloat {
        let content = self as NSString
        let params = [NSAttributedStringKey.font: font]
        let contentSize = content.boundingRect(with: size, options: [.truncatesLastVisibleLine, .usesFontLeading ,.usesLineFragmentOrigin], attributes: params, context: nil).size
        return contentSize.height
    }
}

extension URL {
    static func kp_qiniuImage(picKey: String) -> URL? {
        return URL.init(string: "http://op894ot4r.bkt.clouddn.com/\(picKey)?imageView2/1/w/320/h/180/")
    }
}
