//
//  BaseViewController.swift
//  swiftBase
//
//  Created by Book on 2023/3/18.
//

import UIKit
import Kingfisher

class BaseViewController: UIViewController {
    
    
    //MARK:  是否自动隐藏底部横条
    override var prefersHomeIndicatorAutoHidden: Bool {isHiddenHomeIndicator}

    var isHiddenHomeIndicator = false


    var emptyView:S_EmptyView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if #available(iOS 11.0, *){
            UIScrollView.appearance().contentInsetAdjustmentBehavior = UIScrollView.ContentInsetAdjustmentBehavior.never
        }else{
        
        }
        //    //去除返回按钮的文案
        let backButtonItem = UIBarButtonItem.init(title: "", style: .plain, target: nil, action: nil)
        self.navigationItem.backBarButtonItem = backButtonItem
        
        
        self.view.backgroundColor = MainBackgroundColor
        
        
        self.emptyView = S_EmptyView.addToView(view: self.view, show: false)

    }
    func setScreenOrientation(isLandscape:Bool) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        appdelegate.isLandscape = isLandscape
        if #available(iOS 16.0, *) {
            self.setNeedsUpdateOfSupportedInterfaceOrientations()
        } else {
            if(isLandscape){
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            }else{
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            }
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }

    
    override func didReceiveMemoryWarning() {
        
        //立即清除内存缓存
        ImageCache.default.clearMemoryCache()
        //清除磁盘缓存（异步操作）
        ImageCache.default.clearDiskCache()


    }
    deinit {
        print(self)
    }
}
