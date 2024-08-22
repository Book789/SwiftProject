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
    
}
