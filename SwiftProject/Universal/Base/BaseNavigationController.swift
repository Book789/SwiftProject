//
//  BaseNavigationController.swift
//  swiftBase
//
//  Created by Book on 2023/3/21.
//

import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.setNavAttributeSet()
    }
    
    func setNavAttributeSet(){
                
        //设置NavigationBar背景颜色
        self.navigationBar.tintColor = kColorWithHex(0x999999)  //NavigationBar 控件颜色
        self.navigationBar.isTranslucent = true

//        self.navigationBar.setBackgroundImage(UIImage.init(color: MainBackgroundColor), for: .default)
        //导航栏下线条
//        UIGraphicsBeginImageContextWithOptions(CGSizeMake(kScreenWidth, 1), NO, 0);
//        CGContextRef context = UIGraphicsGetCurrentContext();
//        CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
//        CGContextFillRect(context, CGRectMake(0, 0, kScreenWidth, .5));
//        CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
//        CGContextFillRect(context, CGRectMake(0, .5, kScreenWidth, .5));
//        _shadowImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        [self.navigationBar setShadowImage:_shadowImage];


        /**
              更换系统 返回图片
         */
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset.init(horizontal: -200, vertical: 0), for: UIBarMetrics.default)
        
        if #available(iOS 13.0, *){
            let appearance = self.navigationBar.standardAppearance

            appearance.configureWithOpaqueBackground()
            appearance.setBackIndicatorImage(UIImage.init(named: "nabar_back"), transitionMaskImage: UIImage.init(named: "nabar_back"))
            appearance.shadowColor = UIColor.clear
            appearance.shadowImage = UIImage.init()
            appearance.backgroundColor = UIColor.clear
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.font:UIFont.regularFontOfSize(size: 17)];
            self.navigationBar.scrollEdgeAppearance = appearance;
            self.navigationBar.standardAppearance = appearance;

            if #available(iOS 15.0, *){
                self.navigationBar.compactScrollEdgeAppearance = appearance;
            }


        }else{
            let backButtonImage = UIImage.init(named: "nabar_back")?.withRenderingMode(UIImage.RenderingMode.alwaysOriginal)
            UINavigationBar.appearance().backIndicatorImage = backButtonImage
            UINavigationBar.appearance().backIndicatorTransitionMaskImage = backButtonImage
            UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white,NSAttributedString.Key.font:UIFont.regularFontOfSize(size: 17)];
        }
        
        
        
        
    }
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool){
        
        if (self.viewControllers.count > 0) {
            viewController.hidesBottomBarWhenPushed = true;
        }
        super.pushViewController(viewController, animated: animated)
    }
}
