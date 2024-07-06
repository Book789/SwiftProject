//
//  File.swift
//  SwiftProject
//
//  Created by cloud on 2024/3/9.
//

import UIKit

extension UIViewController{
    
    func currentViewController()->UIViewController?{
        //调用方式
        let rootVC = keyWindow().rootViewController
        return getCurrentViewController(with: rootVC)
    }
    func getCurrentViewController(with rootViewController: UIViewController!)->UIViewController?{
        if nil == rootViewController{
            return nil
        }
        // UITabBarController就接着查找它当前显示的selectedViewController
        if rootViewController.isKind(of: UITabBarController.self){
            return self.getCurrentViewController(with: (rootViewController as! UITabBarController).selectedViewController)
            // UINavigationController就接着查找它当前显示的visibleViewController
        }else if rootViewController.isKind(of: UINavigationController.self){
            return self.getCurrentViewController(with: (rootViewController as! UINavigationController).visibleViewController)
            // 如果当前窗口有presentedViewController,就接着查找它的presentedViewController
        }else if nil != rootViewController.presentedViewController{
            return self.getCurrentViewController(with: rootViewController.presentedViewController)
        }
        // 否则就代表找到了当前显示的控制器
        return rootViewController
    }
    func currentNavigationController()->UINavigationController?{
        let rootVC = keyWindow().rootViewController
        return self.getCurrentNavigationController(with: getCurrentNavigationController(with: rootVC)) as? UINavigationController
    }
    
    func getCurrentNavigationController(with rootViewController: UIViewController!)->UIViewController?{
        
        if(rootViewController is UITabBarController){
            let navi = (rootViewController as! UITabBarController).selectedViewController
            return self.getCurrentViewController(with: navigationController)
        }else if(rootViewController is UINavigationController){
            if(((rootViewController as! UINavigationController).presentedViewController) != nil){
                return self.getCurrentNavigationController(with: (rootViewController as! UINavigationController).presentedViewController)
            }
            return self.getCurrentViewController(with: (rootViewController as! UINavigationController).topViewController)
        }else if(rootViewController.isKind(of: UIViewController.self)){
            if((rootViewController.presentedViewController) != nil){
                return self.getCurrentNavigationController(with: (rootViewController.presentedViewController))
            }
            return rootViewController.navigationController;
        }else{
            return nil
        }
    }

                                        
}

