//
//  UIButton+Debounce.swift
//  SwiftProject
//
//  Created by cloud on 2026/3/31.
//   UIbutton 防抖 防止多次点击
//
import UIKit

// 给 UIButton 添加防抖功能
extension UIButton {
    // 利用运行时绑定点击间隔属性
    private struct AssociatedKeys {
        static var debounceDelay: TimeInterval = 0.5 // 默认 0.5 秒防抖
        static var isIgnoreEvent = false
    }
    
    // 暴露给外部设置防抖时间（可选）
    @IBInspectable var debounceDelay: TimeInterval {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.debounceDelay) as? TimeInterval ?? 0.5
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.debounceDelay, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // 替换系统 sendAction 方法，实现拦截
    static func implementDebounce() {
        let originalSelector = #selector(UIButton.sendAction(_:to:for:))
        let swizzledSelector = #selector(UIButton.swizzled_sendAction(_:to:for:))
        
        guard let originalMethod = class_getInstanceMethod(self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(self, swizzledSelector) else {
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    @objc private func swizzled_sendAction(_ action: Selector, to target: Any?, for event: UIEvent?) {
        if !isIgnoreEvent {
            isIgnoreEvent = true
            swizzled_sendAction(action, to: target, for: event)
            
            // 延迟恢复可点击状态
            DispatchQueue.main.asyncAfter(deadline: .now() + debounceDelay) { [weak self] in
                self?.isIgnoreEvent = false
            }
        }
    }
    
    private var isIgnoreEvent: Bool {
        get { objc_getAssociatedObject(self, &AssociatedKeys.isIgnoreEvent) as? Bool ?? false }
        set { objc_setAssociatedObject(self, &AssociatedKeys.isIgnoreEvent, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
