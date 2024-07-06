//
//  BaseTabbarController.swift
//  swiftBase
//
//  Created by Book on 2023/3/18.
//

import UIKit


class BaseTabBarController: UITabBarController,UITabBarControllerDelegate{

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
 
    override func viewDidLoad() {
        
        
        self.delegate = self
        
        self.tabBar.backgroundColor = MainBackgroundColor
        self.tabBar.isTranslucent = false
        
//        self.tabBar.backgroundImage = UIImage.init(color: MainBackgroundColor, size: self.tabBar.bounds.size)

        let view = UIView.init(frame: CGRect(x: 0, y: -1, width: kScreenWidth, height: 1))
        view.backgroundColor = UIColor.clear
        UITabBar.appearance().insertSubview(view, at: 0)
        
        
        let attributDicNormal = NSMutableDictionary();
        let attributDicSelect = NSMutableDictionary();
        let tabbar = UITabBar.appearance();

        let normalColor = kColorWithHex(0x858B92)
        let selectColor = BlueTextColor

        if #available(iOS 11.0, *){

            tabbar.unselectedItemTintColor = normalColor
        }else{
            attributDicNormal.setValue(normalColor, forKey: NSAttributedString.Key.foregroundColor.rawValue)
        }
        attributDicNormal.setValue(UIFont.systemFont(ofSize: 10), forKey: NSAttributedString.Key.font.rawValue)
        
        
        attributDicSelect.setValue(selectColor, forKey: NSAttributedString.Key.foregroundColor.rawValue)
        attributDicSelect.setValue(UIFont.systemFont(ofSize: 10), forKey: NSAttributedString.Key.font.rawValue)

        
        UITabBarItem.appearance().setTitleTextAttributes(attributDicNormal as? [NSAttributedString.Key : Any], for: UIControl.State.normal)
        UITabBarItem.appearance().setTitleTextAttributes(attributDicSelect as? [NSAttributedString.Key : Any], for: UIControl.State.selected)
        UITabBarItem.appearance().setBadgeTextAttributes([.font : UIFont.mediumFontOfSize(size: 10)], for: .normal)
        UITabBarItem.appearance().setBadgeTextAttributes([.font : UIFont.mediumFontOfSize(size: 10)], for: .selected)
        
        if #available(iOS 15.0, *){

            let appearance = UITabBarAppearance();
//            appearance.backgroundImage = UIImage.init(color: MainBackgroundColor, size: self.tabBar.bounds.size)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [NSAttributedString.Key.foregroundColor:normalColor]
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [NSAttributedString.Key.foregroundColor:selectColor]
            tabbar.scrollEdgeAppearance = appearance
            tabbar.standardAppearance = appearance
        }
        
//        self.setupChildVC(vc: SportsViewController(), title: "运动", norImage: "icon_tabbar_sport_normal", selectImage: "icon_tabbar_sport_sel")
//        self.setupChildVC(vc: HealthTestViewController(), title: "体测", norImage: "icon_tabbar_healthTest_normal", selectImage: "icon_tabbar_healthTest_sel")
//        self.setupChildVC(vc: MyViewController(), title: "我的", norImage: "icon_tabbar_my_normal", selectImage: "icon_tabbar_my_sel")

    }
    
    func setupChildVC(vc:BaseViewController,title:String, norImage:String,selectImage:String){
        
        let baseNavi = BaseNavigationController.init(rootViewController: vc)
        baseNavi.title = title
        baseNavi.tabBarItem.image = UIImage.init(named: norImage)?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        baseNavi.tabBarItem.selectedImage = UIImage.init(named: selectImage)?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
        baseNavi.tabBarItem.imageInsets = UIEdgeInsets(top: -1.5, left: 0, bottom: 1.5, right: 0)
        self.addChild(baseNavi)
        
    }
    
    /*
     // MARK: - UITabBarControllerDelegate
     */
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let baseNavi:BaseNavigationController = viewController as! BaseNavigationController
//        if(baseNavi.viewControllers.first is HealthTestViewController){
//            if(S_UserInfoLocal.isNeedSwitchLogin()){
//                return false
//            }
//        }
        return true
    }

    
}
