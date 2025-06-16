//
//  File.swift
//  SwiftProject
//
//  Created by cloud on 2024/3/9.
//

import UIKit

extension UIViewController{
    
    class func currentViewController()->UIViewController?{
        //调用方式
        let rootVC = keyWindow().rootViewController
        return UIViewController.getCurrentViewController(with: rootVC)
    }
    class func getCurrentViewController(with rootViewController: UIViewController!)->UIViewController?{
        if nil == rootViewController{
            return nil
        }
        // UITabBarController就接着查找它当前显示的selectedViewController
        if rootViewController.isKind(of: UITabBarController.self){
            return UIViewController.getCurrentViewController(with: (rootViewController as! UITabBarController).selectedViewController)
            // UINavigationController就接着查找它当前显示的visibleViewController
        }else if rootViewController.isKind(of: UINavigationController.self){
            return UIViewController.getCurrentViewController(with: (rootViewController as! UINavigationController).visibleViewController)
            // 如果当前窗口有presentedViewController,就接着查找它的presentedViewController
        }else if nil != rootViewController.presentedViewController{
            return UIViewController.getCurrentViewController(with: rootViewController.presentedViewController)
        }
        // 否则就代表找到了当前显示的控制器
        return rootViewController
    }
    class func currentNavigationController()->UINavigationController?{
        let rootVC = keyWindow().rootViewController
        return UIViewController.getCurrentNavigationController(with: getCurrentNavigationController(with: rootVC)) as? UINavigationController
    }
    
    class func getCurrentNavigationController(with rootViewController: UIViewController!)->UIViewController?{
        
        if(rootViewController is UITabBarController){
            let navi = (rootViewController as! UITabBarController).selectedViewController
            return UIViewController.getCurrentViewController(with: navi)
        }else if(rootViewController is UINavigationController){
            if(((rootViewController as! UINavigationController).presentedViewController) != nil){
                return UIViewController.getCurrentNavigationController(with: (rootViewController as! UINavigationController).presentedViewController)
            }
            return UIViewController.getCurrentViewController(with: (rootViewController as! UINavigationController).topViewController)
        }else if(rootViewController.isKind(of: UIViewController.self)){
            if((rootViewController.presentedViewController) != nil){
                return UIViewController.getCurrentNavigationController(with: (rootViewController.presentedViewController))
            }
            return rootViewController.navigationController;
        }else{
            return nil
        }
    }

                                        
}

