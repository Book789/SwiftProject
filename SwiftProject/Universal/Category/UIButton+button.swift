//
//  button.swift
//  Start
//
//  Created by cloud on 2024/1/19.
//

import UIKit
 
extension UIButton {
    
    /// 图片在右位置
    /// - Parameter spacing: 间距
    func iconInRight(with spacing: CGFloat) {
        let img_w = self.imageView?.frame.size.width ?? 0
        let title_w = self.titleLabel?.frame.size.width ?? 0
        
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -(img_w+spacing / 2.0), bottom: 0, right: (img_w+spacing / 2.0))
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: (title_w+spacing / 2.0), bottom: 0, right: -(title_w+spacing / 2.0))
    }
    
    /// 图片在左位置
    /// - Parameter spacing: 间距
    func iconInLeft(spacing: CGFloat) {
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: spacing / 2.0, bottom: 0, right: -spacing / 2.0)
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: -spacing / 2.0, bottom: 0, right: spacing / 2.0)
    }
    
    /// 图片在上面
    /// - Parameter spacing: 间距
    func iconInTop(spacing: CGFloat) {
        let img_W = self.imageView?.frame.size.width ?? 0
        let img_H = self.imageView?.frame.size.height ?? 0
        let tit_W = self.titleLabel?.frame.size.width ?? 0
        let tit_H = self.titleLabel?.frame.size.height ?? 0
        
        self.titleEdgeInsets = UIEdgeInsets(top: (tit_H / 2 + spacing / 2), left: -(img_W / 2), bottom: -(tit_H / 2 + spacing / 2), right: (img_W / 2))
        self.imageEdgeInsets = UIEdgeInsets(top: -(img_H / 2 + spacing / 2), left: (tit_W / 2), bottom: (img_H / 2 + spacing / 2), right: -(tit_W / 2))
    }
    
    /// 图片在 下面
    /// - Parameter spacing: 间距
    func iconInBottom(spacing: CGFloat) {
        let img_W = self.imageView?.frame.size.width ?? 0
        let img_H = self.imageView?.frame.size.height ?? 0
        let tit_W = self.titleLabel?.frame.size.width ?? 0
        let tit_H = self.titleLabel?.frame.size.height ?? 0
        
        self.titleEdgeInsets = UIEdgeInsets(top: -(tit_H / 2 + spacing / 2), left: -(img_W / 2), bottom: (tit_H / 2 + spacing / 2), right: (img_W / 2))
        self.imageEdgeInsets = UIEdgeInsets(top: (img_H / 2 + spacing / 2), left: (tit_W / 2), bottom: -(img_H / 2 + spacing / 2), right: -(tit_W / 2))
    }
}
