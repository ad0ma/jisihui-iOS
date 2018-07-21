//
//  KPBaseTabBarController.swift
//  KP
//
//  Created by Adoma's MacbookPro on 2017/5/23.
//  Copyright © 2017年 adoma. All rights reserved.
//

import UIKit

class KPBaseTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
                
        let appearance = UITabBarItem.appearance()
        
        let attrs = [NSAttributedStringKey.backgroundColor: Main_Theme_Color]
        
        appearance.setTitleTextAttributes(attrs, for: .selected)
        self.tabBar.tintColor = Main_Theme_Color
        
        addChildController(controller: KPMainController.instance, title: "首页", image: #imageLiteral(resourceName: "icon_home_nor"), selecedImage: #imageLiteral(resourceName: "icon_home_selected"))
        
        addChildController(controller: KPBookCategoryController.instance, title: "书城", image: #imageLiteral(resourceName: "icon_bookshelf_nor"), selecedImage: #imageLiteral(resourceName: "icon_bookshelf_selected"))
        
        addChildController(controller: KPBookCollectionController.instance, title: "书单", image: #imageLiteral(resourceName: "icon_list_nor"), selecedImage: #imageLiteral(resourceName: "icon_list_selected"))
        
        if !isAdoma {
            addChildController(controller: KPIdeaController.instance, title: "想法", image: #imageLiteral(resourceName: "icon_idea_nor"), selecedImage: #imageLiteral(resourceName: "icon_idea_selscted"))
            addChildController(controller: KPMineViewController.instance, title: "我的", image: #imageLiteral(resourceName: "icon_info_nor"), selecedImage: #imageLiteral(resourceName: "icon_info_selected"))
        }
    }
    
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        
        #if DEBUG
            let logList = KPLogController.log
            if logList.presentingViewController == nil {
                present(logList, animated: true, completion: nil)
            }
        #endif
    }

    
    @objc func addChildController(controller: UIViewController, title: String, image: UIImage, selecedImage: UIImage) {
        controller.title = title;
        controller.tabBarItem.image = image
        controller.tabBarItem.selectedImage = selecedImage
        
        let childNavi = KPRootNavigationController.init(rootViewController: controller)
        
        addChildViewController(childNavi)
    }

}
