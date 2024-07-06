//
//  CustomButton.swift
//  Start
//
//  Created by cloud on 2023/5/8.
//

import UIKit

class CustomTitleImageView: UIView {
    
    var title:String = ""{
        didSet{
            self.titleLabel.text = title
            let width = title.getTextWith(font: UIFont.regularFontOfSize(size: 14))+6
            self.titleLabel.x = self.width/2-width/2-8
            self.titleLabel.width = width
            self.iconImageView.left = self.titleLabel.right
        }
    }
    var isSelect:Bool = false{
        didSet{
            if(isSelect){
                self.iconImageView.image = UIImage.init(named: "icon_down_blue")
                self.titleLabel.textColor = BlueTextColor

            }else{
                self.iconImageView.image = UIImage.init(named: "icon_down_white")
                self.titleLabel.textColor = UIColor.white

            }
        }
    }
    
    private var iconImageView:UIImageView!
    
    private var titleLabel:UILabel!


    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.titleLabel = UILabel.init(frame: self.bounds)
        self.titleLabel.textAlignment = .left
        self.titleLabel.textColor = UIColor.white
        self.titleLabel.font = UIFont.regularFontOfSize(size: 14)
        self.addSubview(self.titleLabel)
        
        self.iconImageView = UIImageView.init(frame: CGRect(x: 0, y: frame.height/2-8, width: 16, height: 16))
        self.addSubview(self.iconImageView)
        self.iconImageView.image = UIImage.init(named: "icon_down_white")

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
