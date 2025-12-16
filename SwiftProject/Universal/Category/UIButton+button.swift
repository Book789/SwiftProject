//
//  button.swift
//
//
//  Created by cloud on 2024/1/19.
//
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
            // 设置字体大小
            if let title = configuration.attributedTitle {
                configuration.attributedTitle = title
            } else {
                if  let front =  self.titleLabel?.font,let textColor =  self.titleLabel?.textColor {
                    let attributes = AttributeContainer([
                        .font: front,
                        .foregroundColor: textColor
                    ])
                    configuration.attributedTitle = AttributedString(self.titleLabel?.text ?? "", attributes: attributes)
                }
                if let image = self.imageView?.image {
                    configuration.image = image
                }
            }
            self.configurationUpdateHandler = { button in
                button.configuration = configuration
            }

        } else {
            guard let imageView = self.imageView, let titleLabel = self.titleLabel else { return }
            
            let imageWidth = imageView.frame.size.width
            let imageHeight = imageView.frame.size.height
            let titleWidth = titleLabel.frame.size.width
            let titleHeight = titleLabel.frame.size.height
            
            switch placement {
            case .leading:
                // 图标在左侧（对应原iconInLeft方法）
                self.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing/2, bottom: 0, right: -spacing/2)
                self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing/2, bottom: 0, right: spacing/2)
                self.contentEdgeInsets = UIEdgeInsets(top: 0, left: spacing/2, bottom: 0, right: spacing/2)
                
            case .trailing:
                // 图标在右侧
                self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(imageWidth + spacing/2), bottom: 0, right: imageWidth + spacing/2)
                self.imageEdgeInsets = UIEdgeInsets(top: 0, left: titleWidth + spacing/2, bottom: 0, right: -(titleWidth + spacing/2))
                
            case .top:
                // 图标在上方
                self.titleEdgeInsets = UIEdgeInsets(top: (imageHeight + spacing)/2, left: -imageWidth/2, bottom: -(imageHeight + spacing)/2, right: imageWidth/2)
                self.imageEdgeInsets = UIEdgeInsets(top: -(titleHeight + spacing)/2, left: titleWidth/2, bottom: (titleHeight + spacing)/2, right: -titleWidth/2)
                
            case .bottom:
                // 图标在下方
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
    
    /// 居中显示图片和标题（垂直排列）
    /// - Parameter spacing: 图片与标题之间的间距
//    func iconAndTitleCenter(with spacing: CGFloat) {
//        guard let imageView = self.imageView, let titleLabel = self.titleLabel else { return }
//
//        let imageWidth = imageView.frame.size.width
//        let imageHeight = imageView.frame.size.height
//        let titleWidth = titleLabel.frame.size.width
//        let titleHeight = titleLabel.frame.size.height
//
//        let totalHeight = imageHeight + titleHeight + spacing
//
//        self.titleEdgeInsets = UIEdgeInsets(top: (totalHeight - titleHeight)/2, left: -imageWidth, bottom: -(totalHeight - titleHeight)/2, right: 0)
//        self.imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - imageHeight)/2, left: 0, bottom: (totalHeight - imageHeight)/2, right: -titleWidth)
//    }
}


extension UIButton {
    
    private static var clickEdgeInsets: Void?
    /// 扩充点击的范围
    /// 使用方式 btn.enlargeEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    public var enlargeEdgeInsets: UIEdgeInsets? {
        set {
            objc_setAssociatedObject(self, &Self.clickEdgeInsets, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
        get {
            return objc_getAssociatedObject(self, &Self.clickEdgeInsets) as? UIEdgeInsets ?? UIEdgeInsets.zero
        }
        
    }
    

    /// 重写系统方法修改点击区域
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let inset = enlargeEdgeInsets else {
            return super.point(inside: point, with: event)
        }
        var bounds = self.bounds

        let x: CGFloat = -inset.left
        let y: CGFloat = -inset.top
        let width: CGFloat = bounds.width + inset.left + inset.right
        let height: CGFloat = bounds.height + inset.top + inset.bottom
        bounds = CGRect(x: x, y: y, width: width, height: height) // 负值是方法响应范围

        return bounds.contains(point)
    }
}
