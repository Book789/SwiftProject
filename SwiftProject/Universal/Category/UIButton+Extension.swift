//
//  UIButton+Extension.swift
//
//  Created by cloud on 2024/1/19.
//

import UIKit

// 图片位置枚举
public enum ButtonImagePlacement {
    case leading
    case trailing
    case top
    case bottom
}

extension UIButton {
    
    public func setImagePlacement(_ placement: ButtonImagePlacement, spacing: CGFloat = 8) {
        if #available(iOS 15.0, *) {
            var configuration = self.configuration ?? UIButton.Configuration.plain()
            
            configuration.imagePadding = spacing
            
            switch placement {
            case .leading:
                configuration.imagePlacement = .leading
            case .trailing:
                configuration.imagePlacement = .trailing
            case .top:
                configuration.imagePlacement = .top
            case .bottom:
                configuration.imagePlacement = .bottom
            }
            
            configuration.image = self.image(for: .normal)
            configuration.title = self.title(for: .normal)
            
            self.configuration = configuration
            
            // 核心：强制不换行
            self.titleLabel?.numberOfLines = 1
            self.titleLabel?.lineBreakMode = .byTruncatingTail
            
        } else {
            guard let imageView = self.imageView, let titleLabel = self.titleLabel else { return }
            titleLabel.numberOfLines = 1
            titleLabel.lineBreakMode = .byTruncatingTail
            
            let imageWidth = imageView.frame.size.width
            let imageHeight = imageView.frame.size.height
            let titleWidth = titleLabel.frame.size.width
            let titleHeight = titleLabel.frame.size.height
            
            switch placement {
            case .leading:
                self.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing/2, bottom: 0, right: -spacing/2)
                self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing/2, bottom: 0, right: spacing/2)
                self.contentEdgeInsets = UIEdgeInsets(top: 0, left: spacing/2, bottom: 0, right: spacing/2)
                
            case .trailing:
                self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageWidth + spacing/2), bottom: 0, right: imageWidth + spacing/2)
                self.imageEdgeInsets = UIEdgeInsets(top: 0, left: titleWidth + spacing/2, bottom: 0, right: -(titleWidth + spacing/2))
                
            case .top:
                self.titleEdgeInsets = UIEdgeInsets(top: (imageHeight + spacing)/2, left: -imageWidth/2, bottom: -(imageHeight + spacing)/2, right: imageWidth/2)
                self.imageEdgeInsets = UIEdgeInsets(top: -(titleHeight + spacing)/2, left: titleWidth/2, bottom: (titleHeight + spacing)/2, right: -titleWidth/2)
                
            case .bottom:
                self.titleEdgeInsets = UIEdgeInsets(top: -(imageHeight + spacing)/2, left: -imageWidth/2, bottom: (imageHeight + spacing)/2, right: imageWidth/2)
                self.imageEdgeInsets = UIEdgeInsets(top: (titleHeight + spacing)/2, left: titleWidth/2, bottom: -(titleHeight + spacing)/2, right: -titleWidth/2)
            }
        }
    }
    
    func iconInRight(with spacing: CGFloat) {
        self.setImagePlacement(.trailing, spacing: spacing)
    }
    
    func iconInLeft(with spacing: CGFloat) {
        self.setImagePlacement(.leading, spacing: spacing)
    }
    
    func iconInTop(with spacing: CGFloat) {
        self.setImagePlacement(.top, spacing: spacing)
    }
    
    func iconInBottom(with spacing: CGFloat) {
        self.setImagePlacement(.bottom, spacing: spacing)
    }
}

// MARK: - 扩大点击区域
extension UIButton {
    private static var clickEdgeInsets: Void?
    
    public var enlargeEdgeInsets: UIEdgeInsets? {
        set {
            objc_setAssociatedObject(self, &Self.clickEdgeInsets, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return objc_getAssociatedObject(self, &Self.clickEdgeInsets) as? UIEdgeInsets ?? .zero
        }
    }
    
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let inset = enlargeEdgeInsets else {
            return super.point(inside: point, with: event)
        }
        let bounds = self.bounds.inset(by: UIEdgeInsets(
            top: -inset.top,
            left: -inset.left,
            bottom: -inset.bottom,
            right: -inset.right
        ))
        return bounds.contains(point)
    }
}
