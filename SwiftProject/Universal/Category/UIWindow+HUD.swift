//
//  UIWindow+HUD.swift
//  Logger
//
//  Created on 2025/1/27.
//

import UIKit

extension UIWindow {
    
    /// 获取当前显示的最顶层 window
    /// - Returns: 最顶层的 window
    public static func getShowTopWindow() -> UIWindow? {
        var window: UIWindow?
        
        // 优先查找有键盘的 window（UITextEffectsWindow）
        if #available(iOS 13.0, *) {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                window = windowScene.windows.first { window in
                    let className = NSStringFromClass(type(of: window))
                    return className.contains("TextEffects") || className.contains("Keyboard")
                }
            }
        }
        
        if #available(iOS 15.0, *) {
            window = UIApplication.shared.connectedScenes
                .map({ $0 as? UIWindowScene })
                .compactMap({ $0 })
                .first?.windows.first ?? UIWindow()
        }else{
            window = UIApplication.shared.windows.first ?? UIWindow()
        }
        return window
    }
    
    /// 在顶层 window 显示加载 HUD（可选位置）
    public static func showLoadingHUD(position: MBProgressHUDPosition = .center) {
        UIWindow.getShowTopWindow()?.showLoadingHUD(position: position)
    }
    
    /// 在顶层 window 显示带文本的加载 HUD
    /// - Parameter text: 显示的文本
    public static func showLoadingHUD(text: String, position: MBProgressHUDPosition = .center) {
        UIWindow.getShowTopWindow()?.showLoadingHUD(text: text, position: position)
    }
    
    /// 在顶层 window 显示自定义动画的加载 HUD
    public static func showCustomLoadingHUD(animationView: UIView, text: String? = nil, position: MBProgressHUDPosition = .center) {
        UIWindow.getShowTopWindow()?.showCustomLoadingHUD(animationView: animationView, text: text, position: position)
    }
    
    /// 在顶层 window 显示带点击回调的加载 HUD
    /// - Parameter clickBlock: 点击回调
    public static func showLoadingHUD(clickBlock: @escaping () -> Void) {
        UIWindow.getShowTopWindow()?.showLoadingHUD(clickBlock: clickBlock)
    }
    
    /// 在顶层 window 显示进度 HUD
    /// - Parameter progress: 进度值（0.0 - 1.0）
    public static func showProgress(_ progress: Float) {
        UIWindow.getShowTopWindow()?.showProgress(progress)
    }
    
    /// 隐藏顶层 window 的 HUD
    public static func hideHUD() {
        UIWindow.getShowTopWindow()?.hideHUD()
    }
    
    /// 在顶层 window 显示文本 HUD
    /// - Parameter text: 显示的文本
    public static func showTextHUD(_ text: String, position: MBProgressHUDPosition = .center) {
        UIWindow.getShowTopWindow()?.showTextHUD(text, position: position)
    }
    
    /// 在顶层 window 显示带延迟的文本 HUD
    /// - Parameters:
    ///   - delay: 延迟时间（秒）
    ///   - text: 显示的文本
    public static func showTextHUD(delay: TimeInterval, text: String, position: MBProgressHUDPosition = .center) {
        UIWindow.getShowTopWindow()?.showTextHUD(delay: delay, text: text, position: position)
    }
    
    /// 在顶层 window 显示带图片的文本 HUD
    /// - Parameters:
    ///   - delay: 延迟时间（秒）
    ///   - image: 显示的图片
    ///   - text: 显示的文本
    public static func showTextHUD(delay: TimeInterval, image: UIImage?, text: String, position: MBProgressHUDPosition = .center) {
        UIWindow.getShowTopWindow()?.showTextHUD(delay: delay, image: image, text: text, position: position)
    }
    
    /// 在顶层 window 显示自定义视图的 HUD
    /// - Parameters:
    ///   - delay: 延迟时间（秒）
    ///   - view: 自定义视图
    ///   - text: 显示的文本
    public static func showTextHUD(delay: TimeInterval, view: UIView?, text: String, position: MBProgressHUDPosition = .center) {
        UIWindow.getShowTopWindow()?.showTextHUD(delay: delay, view: view, text: text, position: position)
    }

}



