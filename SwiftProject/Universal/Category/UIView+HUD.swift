//
//  UIView+HUD.swift
//  Logger
//
//  Created on 2025/1/27.
//

import UIKit
import MBProgressHUD

// MARK: - HUD 显示位置

public enum MBProgressHUDPosition {
    case center
    case top
    case bottom
}

// MARK: - HUD 协议

/// HUD 显示协议
public protocol MBProgressHUDProtocol {
    /// 显示加载 HUD（会一直显示直到调用 hideHUD）
    func showLoadingHUD(position: MBProgressHUDPosition)
    
    /// 显示带文本的加载 HUD
    /// - Parameter text: 显示的文本（支持格式化字符串）
    func showLoadingHUD(text: String, position: MBProgressHUDPosition)
    
    /// 显示自定义动画的加载 HUD
    /// - Parameters:
    ///   - animationView: 自定义动画视图
    ///   - text: 文字内容
    ///   - position: 位置
    func showCustomLoadingHUD(animationView: UIView, text: String?, position: MBProgressHUDPosition)
    
    /// 显示带点击回调的加载 HUD
    /// - Parameter clickBlock: 点击 HUD 时的回调
    func showLoadingHUD(clickBlock: @escaping () -> Void)
    
    /// 显示进度 HUD
    /// - Parameter progress: 进度值（0.0 - 1.0）
    func showProgress(_ progress: Float)
    
    /// 隐藏当前的 HUD
    func hideHUD()
    
    /// 显示文本 HUD（会自动消失）
    /// - Parameter text: 显示的文本（支持格式化字符串）
    func showTextHUD(_ text: String, position: MBProgressHUDPosition)
    
    /// 显示带延迟的文本 HUD
    /// - Parameters:
    ///   - delay: 延迟时间（秒），0 表示根据文本长度自动计算
    ///   - text: 显示的文本
    func showTextHUD(delay: TimeInterval, text: String, position: MBProgressHUDPosition)
    
    /// 显示带图片的文本 HUD
    /// - Parameters:
    ///   - delay: 延迟时间（秒）
    ///   - image: 显示的图片
    ///   - text: 显示的文本
    func showTextHUD(delay: TimeInterval, image: UIImage?, text: String, position: MBProgressHUDPosition)
    
    /// 显示自定义视图的 HUD
    /// - Parameters:
    ///   - delay: 延迟时间（秒）
    ///   - view: 自定义视图
    ///   - text: 显示的文本
    func showTextHUD(delay: TimeInterval, view: UIView?, text: String, position: MBProgressHUDPosition)
}

// MARK: - NSObject 扩展（核心实现）

extension NSObject: MBProgressHUDProtocol {
    
    /// 根据显示位置设置偏移
    private func apply(position: MBProgressHUDPosition, to hud: MBProgressHUD) {
        guard let superview = hud.superview else { return }
        let height = superview.bounds.height
        switch position {
        case .center:
            hud.offset = .zero
        case .top:
            hud.offset = CGPoint(x: 0, y: -(height / 2 - 100))
        case .bottom:
            hud.offset = CGPoint(x: 0, y: height / 2 - 100)
        }
    }
    
    /// 获取 HUD 应该添加到的视图
    /// - Returns: 目标视图
    public func hudInView() -> UIView? {
        if let viewController = self as? UIViewController {
            return viewController.view
        } else if let view = self as? UIView {
            return view
        } else {
            return UIWindow.getShowTopWindow()
        }
    }
    
    // MARK: - Loading HUD
    
    public func showLoadingHUD(position: MBProgressHUDPosition = .center) {
        showLoadingHUD(text: "", position: position)
    }
    
    public func showLoadingHUD(text: String, position: MBProgressHUDPosition = .center) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.showLoadingHUD(text: text, position: position)
            }
            return
        }
        
        guard let hudInView = hudInView() else { return }
        
        // 先隐藏之前的 HUD
        MBProgressHUD.hide(for: hudInView, animated: true)
        
        // 创建新的 HUD
        let hud = MBProgressHUD.showAdded(to: hudInView, animated: true)
        hud.contentColor = .white
        hud.bezelView.color = UIColor(red: 0x1c / 255.0, green: 0x23 / 255.0, blue: 0x2c / 255.0, alpha: 0.4)
        hud.bezelView.style = .solidColor
        apply(position: position, to: hud)
        
        if !text.isEmpty {
            hud.detailsLabel.font = .systemFont(ofSize: 16)
            hud.margin = 16
            hud.bezelView.layer.cornerRadius = 8
            hud.detailsLabel.text = text
            hud.detailsLabel.textColor = .white
        }
    }
    
    public func showLoadingHUD(clickBlock: @escaping () -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.showLoadingHUD(clickBlock: clickBlock)
            }
            return
        }
        
        guard let hudInView = hudInView() else { return }
        
        // 先隐藏之前的 HUD
        MBProgressHUD.hide(for: hudInView, animated: true)
        
        // 创建新的 HUD
        let hud = MBProgressHUD.showAdded(to: hudInView, animated: true)
        hud.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        apply(position: .center, to: hud)
        
        // 添加点击手势
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hudTapped))
        hud.addGestureRecognizer(tapGesture)
        
        // 使用关联对象存储回调
        objc_setAssociatedObject(hud, &AssociatedKeys.clickBlock, clickBlock, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    // MARK: - Custom Loading HUD
    public func showCustomLoadingHUD(animationView: UIView, text: String?, position: MBProgressHUDPosition) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.showCustomLoadingHUD(animationView: animationView, text: text, position: position)
            }
            return
        }
        
        guard let hudInView = hudInView() else { return }
        
        MBProgressHUD.hide(for: hudInView, animated: true)
        
        let hud = MBProgressHUD.showAdded(to: hudInView, animated: true)
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor(red: 0x1c / 255.0, green: 0x23 / 255.0, blue: 0x2c / 255.0, alpha: 0.8)
        hud.bezelView.layer.cornerRadius = 8
        hud.contentColor = .white
        hud.margin = 16
        hud.mode = .customView
        hud.isUserInteractionEnabled = false
        apply(position: position, to: hud)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        animationView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(animationView)
        
        var constraints: [NSLayoutConstraint] = [
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor),
            animationView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ]
        
        if let text = text, !text.isEmpty {
            let label = UILabel()
            label.text = text
            label.textColor = .white
            label.font = .systemFont(ofSize: 16)
            label.textAlignment = .center
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(label)
            
            constraints.append(contentsOf: [
                label.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 12),
                label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
                label.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        } else {
            constraints.append(animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor))
        }
        
        NSLayoutConstraint.activate(constraints)
        hud.customView = containerView
     
    }
    @objc func hudTapped(_ gesture: UITapGestureRecognizer) {
        if let hud = gesture.view as? MBProgressHUD,
           let clickBlock = objc_getAssociatedObject(hud, &AssociatedKeys.clickBlock) as? () -> Void {
            clickBlock()
        }
    }
    
    // MARK: - Progress HUD
    
    public func showProgress(_ progress: Float) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.showProgress(progress)
            }
            return
        }
        
        guard let hudInView = hudInView() else { return }
        
        let hud = MBProgressHUD.showAdded(to: hudInView, animated: true)
                
        hud.mode = .determinate
        hud.progress = progress
        hud.label.text = String(format: "%.2f%%", progress * 100)
    }
    
    // MARK: - Hide HUD
    
    public func hideHUD() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.hideHUD()
            }
            return
        }
        
        guard let hudInView = hudInView() else { return }
        MBProgressHUD.hide(for: hudInView, animated: true)
    }
    
    // MARK: - Text HUD
    
    public func showTextHUD(_ text: String, position: MBProgressHUDPosition = .center) {
        showTextHUD(delay: 0, view: nil, text: text, position: position)
    }
    
    public func showTextHUD(delay: TimeInterval, text: String, position: MBProgressHUDPosition = .center) {
        showTextHUD(delay: delay, view: nil, text: text, position: position)
    }
    
    public func showTextHUD(delay: TimeInterval, image: UIImage?, text: String, position: MBProgressHUDPosition = .center) {
        let imageView = image.map { UIImageView(image: $0) }
        showTextHUD(delay: delay, view: imageView, text: text, position: position)
    }
    
    public func showTextHUD(delay: TimeInterval, view: UIView?, text: String, position: MBProgressHUDPosition = .center) {
        if view == nil && text.isEmpty {
            return
        }
        
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in
                self?.showTextHUD(delay: delay, view: view, text: text, position: position)
            }
            return
        }
        
        guard let hudInView = hudInView() else { return }
        
        // 先隐藏之前的 HUD
        MBProgressHUD.hide(for: hudInView, animated: true)
        
        // 创建新的 HUD
        let hud = MBProgressHUD.showAdded(to: hudInView, animated: true)
        hud.contentColor = .white
        hud.bezelView.color = UIColor(red: 0x1c / 255.0, green: 0x23 / 255.0, blue: 0x2c / 255.0, alpha: 0.8)
        hud.mode = .text
        hud.bezelView.style = .solidColor
        hud.isUserInteractionEnabled = false
        apply(position: position, to: hud)
        
        if !text.isEmpty {
            hud.detailsLabel.font = .systemFont(ofSize: 16)
            hud.margin = 16
            hud.bezelView.layer.cornerRadius = 8
            hud.detailsLabel.text = text
            hud.detailsLabel.textColor = .white
        }
        
        if let customView = view {
            hud.customView = customView
            hud.mode = .customView
        }
        
        // 计算显示时长
        var duration: TimeInterval = 1.0
        if delay > 0 {
            duration = delay
        } else {
            duration = Double(text.count) * 0.08 + 0.3
            duration = min(3.0, max(1.0, duration))
        }
        
        // 延迟隐藏
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            if hud.superview != nil {
                hud.removeFromSuperViewOnHide = true
                hud.hide(animated: true)
            }
        }
    }
}
// MARK: - 关联对象键

private struct AssociatedKeys {
     static var clickBlock: Void?
}



