//
//  CALayer+layer.swift
//  Start
//
//  Created by Book on 2023/4/22.
//

import UIKit

extension CALayer {
    
    class func addSubLayer(frame:CGRect,color:UIColor,baseView:UIView)->CALayer{
        
        let layer = CALayer()
        layer.frame = frame
        layer.backgroundColor = color.cgColor
        baseView.layer.addSublayer(layer)
        return layer

    }
    
    func layerBoderColor(frame:CGRect,colors:Array<CGColor>,cornerRadius:CGFloat,lineWidth:CGFloat){
        let gradientLayer:CAGradientLayer = CAGradientLayer()
        gradientLayer.frame = frame
        gradientLayer.startPoint = CGPointMake(0, 0)
        gradientLayer.endPoint = CGPointMake(0, 1)
        gradientLayer.colors = colors
        gradientLayer.locations = [(0), (1.0)]
        gradientLayer.masksToBounds = true
        gradientLayer.cornerRadius = cornerRadius
        
        let maskLayer = CAShapeLayer()
        maskLayer.lineWidth = lineWidth
        maskLayer.path = UIBezierPath(roundedRect: CGRect(x: lineWidth / 2, y: lineWidth / 2, width: bounds.width - lineWidth, height: bounds.height - lineWidth), cornerRadius: cornerRadius).cgPath
        maskLayer.fillColor = UIColor.clear.cgColor
        maskLayer.strokeColor = UIColor.black.cgColor
        
        gradientLayer.mask = maskLayer
        self.addSublayer(gradientLayer)
    }
    
    //MARK: 暂停动画
    func pauseAnimation() {
        let pauseTime = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0.0
        timeOffset = pauseTime
    }
    //MARK: 恢复动画
    func resumeAnimation() {
        // 1.取出时间
        let pauseTime = timeOffset
        // 2.设置动画的属性
        speed = 1.0
        timeOffset = 0.0
        beginTime = 0.0
        // 3.设置开始动画
        let startTime = convertTime(CACurrentMediaTime(), from: nil) - pauseTime
        beginTime = startTime
    }
}
