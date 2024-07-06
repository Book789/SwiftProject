//
//  CustomButton.swift
//  Start
//
//  Created by Book on 2023/4/21.
//

import UIKit

class CustomButtonView: UIView {
    
    var shadowView:UIView!
    
    var button:UIButton!
    
    var isShadow:Bool=false{
        didSet{
            self.shadowView.isHidden = isShadow
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        button = UIButton.init(frame: self.bounds)
        self.addSubview(button)

        button.backgroundColor = UIColor.init(patternImage: UIImage.createImageWithSize(imageSize: button.size, colorsArray: [kColorWithHex(0x2F63F8),kColorWithHex(0xE30B9A)]))
        button.titleLabel?.font =  UIFont.regularFontOfSize(size: 14)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = 22
        button.clipsToBounds = true
        
        self.shadowView = UIView.init(frame: self.bounds)
        self.shadowView.backgroundColor = kColorWithHex(0x04875B)
        self.shadowView.alpha = 0.2
        self.addSubview(self.shadowView)
        self.shadowView.layer.cornerRadius = 22
        self.shadowView.clipsToBounds = true

        
    }
    

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}
