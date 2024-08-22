//
//  CALayer+layer.swift
//  Start
//
//  Created by Book on 2023/4/22.
//

import UIKit

private var key: Void?

private var layerKey: Void?

extension CALayer {
    
    var animation: CAAnimation?{
        get {
            return objc_getAssociatedObject(self, &key) as? CAAnimation
        }
        set {
            objc_setAssociatedObject(self, &key, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    var animationKey: String?{
        get {
            return objc_getAssociatedObject(self, &layerKey) as? String
        }
        set {
            objc_setAssociatedObject(self, &layerKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    //MARK: 暂停动画
    func pauseAnimation() {
        let keys = self.animationKeys()
        guard let animationKey = keys?.first else { return  }
        self.animationKey = animationKey
        animation = self.animation(forKey: self.animationKey!)
        let pauseTime = convertTime(CACurrentMediaTime(), from: nil)
        speed = 0.0
        timeOffset = pauseTime
    }
    //MARK: 恢复动画
    func resumeAnimation() {
        
        guard let animation = animation else{
            return
        }
        guard let animationKey = self.animationKey else{
            return
        }
        self.add(animation, forKey: animationKey)
        self.animation = nil
        self.animationKey = nil
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
    /**
     override func didMove(toParent parent: UIViewController?) {
     if(parent == nil){
     testView.layer.removeAllAnimations()
     basicAnimation = nil
     }
     }
     */
}
