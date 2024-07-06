//
//  S_SplashView.swift
//  Start
//
//  Created by Book on 2023/4/26.
//

import UIKit

class S_SplashView: UIView {

    var  loadingImageView:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = MainBackgroundColor
        
        loadingImageView = UIImageView.init(frame: self.bounds)
        loadingImageView.isUserInteractionEnabled = true
        self.addSubview(loadingImageView)
        let loadingImageArray:NSMutableArray = []
        for i in 0...24{
            let image = UIImage.init(named: "logo2x_000"+String(format:"%02ld", i))
            if(image != nil){
                loadingImageArray.add(image!)
            }
        }
        loadingImageView.animationImages = loadingImageArray as? [UIImage];
        loadingImageView.animationDuration = 24 * 0.05;
        loadingImageView.startAnimating()
        loadingImageView.contentMode = .scaleAspectFill
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 24 * 0.05) {
            self.removeFromSuperview()
        }


    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
