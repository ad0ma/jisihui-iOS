//
//  KPBookCategoryController.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/6/1.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class KPBookCategoryController: KPBaseViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    typealias CategoryType = (name: String, img: UIImage)
    var categorys: [CategoryType]? = []
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "分类"

        getData()
        
        let laylout = UICollectionViewFlowLayout.init()
        
        laylout.minimumLineSpacing = 10
        laylout.minimumInteritemSpacing = 10
        
        let collection = UICollectionView.init(frame: CGRect.init(x: 0, y: kLayoutNavH, width: Main_Screen_Width, height: Main_Screen_Height - kLayoutNavH - kLayoutTabH), collectionViewLayout: laylout)
        
        collection.backgroundColor = Content_Color
        collection.showsVerticalScrollIndicator = false
        collection.delegate = self
        collection.dataSource = self
        collection.registerReusableCell(KPBookCategoryCell.self)
        
        view.addSubview(collection)
    }
    
    @objc func getData() -> Void {
        
        guard let source = Bundle.main.path(forResource: "category", ofType: "json") else {
            return
        }
        
        guard let data = FileManager.default.contents(atPath: source) else {
            return
        }
        
        guard let categoryArr = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [Dictionary<String, String>] else {
            return
        }
        
        categoryArr.forEach { dic in
            
            let title = dic["name"]
            let imgName = dic["image"]
            
            let img = UIImage.init(named: imgName!)
            
            categorys?.append((name: title!, img: img!))
        }
        
    }

     func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }


    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return categorys?.count ?? 0
    }


     func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let category = collectionView.dequeueReusableCell(indexPath: indexPath) as KPBookCategoryCell
        
        if indexPath.section == 0 {
            
            category.categoryName.isHidden = true
            category.allName.isHidden = false
            category.imgV.image = UIImage.init(named: "allBook")
            
            let attrStr = NSAttributedString.init(string: "全部图书", attributes: [NSAttributedStringKey.kern: 3])
            category.allName.attributedText = attrStr
            
        } else {
            let categoryType = categorys![indexPath.row]
            
            category.categoryName.isHidden = false
            category.allName.isHidden = true
            category.categoryName.text = categoryType.name
            category.imgV.image = categoryType.img
        }

        return category
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            let width = Main_Screen_Width - 20
            
            return CGSize.init(width: width, height: width * 0.3)
            
        } else {
            let width = floor((Main_Screen_Width - 40) / 3)
            
            return CGSize.init(width: width, height: width)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if section == 0 {
            return UIEdgeInsetsMake(10, 10, 0, 10)
        } else {
            return UIEdgeInsetsMake(10, 10, 10, 10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        var idx = indexPath.row
        
        let bookList = KPBookListController.instance
        
        if indexPath.section == 0 {
            
            idx = -1
            bookList.kp_self.title = "全部图书"

        } else {
            
            idx += 1
            
            if idx == categorys?.count {
                idx = 0
            }
            
            bookList.kp_self.title = categorys![indexPath.row].name
        }
        
        (bookList.kp_self as! KPBookListController).entryType = .category(idx)
        navigationController?.pushViewController(bookList, animated: true)
        
    }
    
}
