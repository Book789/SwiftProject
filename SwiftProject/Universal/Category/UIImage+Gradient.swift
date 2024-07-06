//
//  UIImage+image.swift
//  Start
//
//  Created by Book on 2023/4/20.
//

import Foundation
import UIKit

enum GradientType{
    case GradientFromTopToBottom            //从上到下
    case GradientFromLeftToRight                //从左边到右
    case GradientFromLeftTopToRightBottom      //从上到下
    case GradientFromLeftBottomToRightTop        //从上到下
}


extension UIImage {
    
    class func createImageWithSize(imageSize:CGSize,colorsArray:NSArray)-> UIImage{
        
        return UIImage.createImageWithSize(imageSize: imageSize, colorsArray: colorsArray, percents: [(0.0),(1.0)])
        
    }
    
    class func createImageWithSize(imageSize:CGSize,colorsArray:NSArray,percents:NSArray)-> UIImage{
        
        return UIImage.createImageWithSize(imageSize:imageSize, colorsArray: colorsArray, percents: percents, gradientType: .GradientFromLeftToRight)
        
    }
    class func createImageWithSize(imageSize:CGSize,colorsArray:NSArray,gradientType:GradientType)-> UIImage{
        
        return UIImage.createImageWithSize(imageSize:imageSize, colorsArray: colorsArray, percents: [(0.0),(1.0)], gradientType:gradientType)
        
    }

    
    class func createImageWithSize(imageSize:CGSize,colorsArray:NSArray,percents:NSArray,gradientType:GradientType)-> UIImage{
        
        assert(percents.count <= 5, "输入颜色数量过多，如果需求数量过大，请修改locations[]数组的个数")

        let colors:NSMutableArray = []
        
        for color in colorsArray{
            colors.add((color as! UIColor).cgColor)
        }
        let layer : CAGradientLayer = CAGradientLayer ()
        let gradientColors: [CGColor] = colors as! [CGColor]
        let gradientLocations: [NSNumber] = percents as! [NSNumber]
        layer.colors = gradientColors
        layer.locations = gradientLocations

        switch gradientType{
        case .GradientFromTopToBottom:
            layer.startPoint = CGPoint(x: 0.5, y: 0)
            layer.endPoint = CGPoint(x: 0.5, y: 1)


        case .GradientFromLeftToRight:
            layer.startPoint = CGPoint(x: 0, y: 0.5)
            layer.endPoint = CGPoint(x: 1, y: 0.5)

        case .GradientFromLeftTopToRightBottom:
            layer.startPoint = CGPoint(x: 0, y: 0)
            layer.endPoint = CGPoint(x: 1, y: 1)

        case .GradientFromLeftBottomToRightTop:
            layer.startPoint = CGPoint(x: 0, y: 1)
            layer.endPoint = CGPoint(x: 1, y: 0)
        }
       
        layer.frame = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, 0)
        if let context = UIGraphicsGetCurrentContext() {
            layer.render(in: context)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!


    }



    
}
