//
//  GradientCircleProgressView.swift
//  Start
//
//  Created by cloud on 2023/4/28.
//

import Foundation

class GradientCircleProgressView: UIView {
    
    private var bgColor: CGColor = kColorWithHex(0x66D6D2).cgColor
    private var lineWidth: CGFloat = 0.0
    private var colors: [CGColor] = []
    private var locations: [Double] = []
    private var progress: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    convenience init(frame: CGRect, lineWidth: CGFloat, bgColor: CGColor, colors: [CGColor], locations: [Double]) {
        self.init(frame: frame)
        self.bgColor = bgColor
        self.lineWidth = lineWidth
        self.colors = colors
        self.locations = locations
        
        draw(frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.circleLayer.removeFromSuperlayer()
        self.gradientLayer.removeFromSuperlayer()
                
        //画一个环形的layer
        self.circleLayer.frame = self.bounds
        self.layer.addSublayer(self.circleLayer)
        self.circleLayer.fillColor = UIColor.clear.cgColor
        self.circleLayer.strokeColor = self.bgColor
        self.circleLayer.opacity = 1
        self.circleLayer.lineWidth = self.lineWidth
        
        let center: CGPoint = CGPoint(x: rect.size.width/2, y: rect.size.height/2)
        //画贝塞尔曲线
        let bezierPath = UIBezierPath(arcCenter: center, radius: (rect.size.width - self.lineWidth)/2, startAngle: CGFloat(-0.5 * Double.pi), endAngle: CGFloat(1.5 * Double.pi), clockwise: true)
        self.circleLayer.path = bezierPath.cgPath //将曲线添加到layer层
        
        self.layer.addSublayer(self.circleLayer)//添加蒙版
        
        //渐变色 加蒙版 显示蒙版区域
        self.gradientLayer.frame = self.bounds
        self.gradientLayer.colors = self.colors
        self.gradientLayer.locations = self.locations as [NSNumber]
        self.gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        self.gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        
        self.layer.addSublayer(self.gradientLayer)
        
        self.progressLayer.frame = self.bounds
        self.progressLayer.lineWidth = self.lineWidth
        self.progressLayer.fillColor = UIColor.clear.cgColor
        self.progressLayer.strokeColor = UIColor.red.cgColor
        
        self.progressLayer.lineCap = .round //设置画笔
        self.progressLayer.path = bezierPath.cgPath
        //修改渐变layer层的遮罩，关键代码
        self.gradientLayer.mask = self.progressLayer
    }
    
    
    public func setProgress(_ value: CGFloat, animated: Bool = false) {
        self.progress = value
        if animated {
            CATransaction.begin()
            CATransaction.setDisableActions(false)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeIn))
            CATransaction.setAnimationDuration(1.0)
            self.progressLayer.strokeEnd = self.progress
            CATransaction.commit()
        } else {
            self.progressLayer.strokeEnd = self.progress
        }
    }
    
    //MARK: - lazy load -
        
    private lazy var circleLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        return layer
    }()
    
    private lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeEnd = 0.0
        return layer
    }()
    
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        return layer
    }()
    
}
