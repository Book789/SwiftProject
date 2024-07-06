//
//  S_UIButton.swift
//  Start
//
//  Created by cloud on 2023/5/11.
//

import UIKit

public enum Layout {
    /// 标题在左
    case titleLeft
    /// 标题在右
    case titleRight
    /// 标题在上
    case titleTop
    /// 标题在下
    case titleBottom
}

class S_UIButton: UIControl {
    
    var titleLabel:UILabel!
    
    public var layout: Layout = .titleLeft {
        didSet { layoutIfNeeded() }
    }

    
    fileprivate var imageView = UIImageView()

    /// 水平间距
    public var horizontalSpace: CGFloat = 4.0

    /// 竖直间距
    public var verticalSpace: CGFloat = 4.0

    fileprivate var imageCache = NSMutableDictionary()
    
    fileprivate var titleCache = NSMutableDictionary()
    
    fileprivate var titleColorCache = NSMutableDictionary()

    override var isSelected: Bool{
        didSet{
            if(isSelected){
                self.titleLabel.text = (self.titleCache["selected"] as? String) ?? self.titleCache["normal"] as! String
                self.titleLabel.textColor = self.titleColorCache["selected"] as? UIColor ?? self.titleColorCache["normal"] as! UIColor
                self.imageView.image = self.imageCache["selected"] as? UIImage ?? self.imageCache["normal"] as? UIImage

            }else{
                
                self.titleLabel.text = self.titleCache["normal"] as? String
                self.titleLabel.textColor = self.titleColorCache["normal"] as? UIColor
                self.imageView.image = self.imageCache["normal"] as? UIImage

            }
        }
    }
   

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleLabel = UILabel.init(frame: CGRectZero)
        
        self.addSubview(self.titleLabel)
        
        self.addSubview(self.imageView)
        
    }
    func setTitle(_ title: String?, for state: UIControl.State){
       
        if(state == .normal){
            titleCache.setObject(title ?? "", forKey: "normal" as NSCopying)
            titleLabel.text = title
        }
        if(state == .selected){
            titleCache.setObject(title ?? "", forKey: "selected" as NSCopying)
        }
    }

    func setTitleColor(_ color: UIColor?, for state: UIControl.State){
        guard let color = color else { return }
        if(state == .normal){
            titleColorCache.setObject(color, forKey: "normal" as NSCopying)
            titleLabel.textColor = color
        }
        if(state == .selected){
            titleColorCache.setObject(color, forKey: "selected" as NSCopying)
        }
    }
    func setImage(_ image: UIImage?, for state: UIControl.State){
    
   
        guard let image = image else {
            imageView.isHidden = true
            return
        }
        if(state == .normal){
            imageCache.setObject(image, forKey: "normal" as NSCopying)
            imageView.image = image
        }
        if(state == .selected){
            imageCache.setObject(image, forKey: "selected" as NSCopying)
        }
        imageView.isHidden = false
        layoutIfNeeded()
        setNeedsLayout()
    }

    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
extension S_UIButton {
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard frame.size.width > 0, frame.size.height > 0 else { return }
       

        // ======== 子控件布局部分 ============
        let viewWidth = frame.size.width
        let viewHeight = frame.size.height
        let text = titleLabel.text
        let image = imageView.image
        if let text = text, let image = image {
            var titleLabelSize: CGSize = CGSize.zero
            titleLabelSize = labelSize(text: text, maxSize: CGSize(width: viewWidth, height: viewHeight), font: titleLabel.font)

            updateViewSize(with: titleLabel, size: titleLabelSize)
            updateViewSize(with: imageView, size: image.size)
            let horizontalSpaceImage = horizontalSpace + image.size.width / 2.0
            let horizontalSpaceTitle = horizontalSpace + titleLabelSize.width / 2.0
            let verticalSpaceImage = verticalSpace + image.size.height / 2.0
            let verticalSpaceTitle = verticalSpace + titleLabelSize.height / 2.0

            switch layout {
            case .titleLeft:
                titleLabel.center = CGPoint(x: viewWidth / 2.0 - horizontalSpaceImage, y: viewHeight / 2.0)
                imageView.center = CGPoint(x: viewWidth / 2.0 + horizontalSpaceTitle, y: viewHeight / 2.0)
            case .titleRight:
                titleLabel.center = CGPoint(x: viewWidth / 2.0 + horizontalSpaceImage, y: viewHeight / 2.0)
                imageView.center = CGPoint(x: viewWidth / 2.0 - horizontalSpaceTitle, y: viewHeight / 2.0)
            case .titleTop:
                titleLabel.center = CGPoint(x: viewWidth / 2.0, y: viewHeight / 2.0 - verticalSpaceImage)
                imageView.center = CGPoint(x: viewWidth / 2.0, y: viewHeight / 2.0 + verticalSpaceTitle)
            case .titleBottom:
                titleLabel.center = CGPoint(x: viewWidth / 2.0, y: viewHeight / 2.0 + verticalSpaceImage)
                imageView.center = CGPoint(x: viewWidth / 2.0, y: viewHeight / 2.0 - verticalSpaceTitle)
            }
        } else if let text = text {
            let size = labelSize(text: text, maxSize: CGSize(width: viewWidth, height: viewHeight), font: titleLabel.font)
            updateViewSize(with: titleLabel, size: size)
            titleLabel.center = CGPoint(x: viewWidth / 2.0, y: viewHeight / 2.0)
        } else if let image = image {
            updateViewSize(with: imageView, size: image.size)
            imageView.center = CGPoint(x: viewWidth / 2.0, y: viewHeight / 2.0)
        }
    }

    /// 更新控件大小
    func updateViewSize(with targetView: UIView, size: CGSize) {
        var rect = targetView.frame
        rect.size.width = size.width
        rect.size.height = size.height
        targetView.frame = rect
    }

    /// 计算文本大小
    func labelSize(text: String?, maxSize: CGSize, font: UIFont) -> CGSize {
        guard let text = text else { return CGSize.zero }
        let constraintRect = CGSize(width: maxSize.width, height: maxSize.height)
        let boundingBox = text.boundingRect(with: constraintRect, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [.font: font], context: nil)
        return boundingBox.size
    }
}
