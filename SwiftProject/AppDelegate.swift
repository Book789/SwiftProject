//
//  AppDelegate.swift
//  SwiftProject
//
//  Created by cloud on 2024/3/9.
//

import UIKit
import AVFAudio

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
  
    var tabbarController: BaseTabBarController = BaseTabBarController()
   
    var isLandscape: Bool = false


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        self.window = UIWindow(frame: UIScreen.main.bounds)
//        self.window?.backgroundColor = UIColor.clear
//      
//        self.window!.rootViewController = self.tabbarController
//
//        self.window?.makeKeyAndVisible()
//       
//        //启动程序时未登录时 选择 push 跳转登录 退出登录以及挤掉账号时 模态present 跳转到登录
//        if(S_UserInfoLocal.isLogin()){
//           
//
//        }else{
////            UIViewController.current().navigationController?.pushViewController(S_LoginViewController(), animated: true)
//        }
//
////        let splashView = S_SplashView.init(frame: self.window!.bounds)
////        self.window!.addSubview(splashView)
////
////        if ((UserDefaults.standard.object(forKey: FirstAgreementKey) == nil)) {
////            //同意隐私协议
////            self.window?.insertSubview(self.privacyAgreementView, at: 1)
//////            let appGuideView = S_AppGuideView.init(frame: self.window!.bounds)
//////            self.window?.insertSubview(appGuideView, at: 1)
////        }
//        
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            try audioSession.setCategory(.playAndRecord,mode: .videoRecording, options: [.defaultToSpeaker,.allowBluetoothHFP])
//            try audioSession.setActive(true)
//        } catch {
//
//        }

        return true
    }


}

