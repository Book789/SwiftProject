//
//  UIView+view.swift
//  Start
//
//  Created by Book on 2023/4/25.
//

import Foundation

extension UIView {
    
    //radius:切圆角的半径
    //corner:要切四个角中的哪个角
    func cornerCut(radius:Int,corner:UIRectCorner){
        let maskPath = UIBezierPath.init(roundedRect: bounds, byRoundingCorners: corner, cornerRadii: CGSize.init(width: radius, height: radius))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
    }
}
