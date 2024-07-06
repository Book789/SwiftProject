//
//  S_AppGuideView.swift
//  Start
//
//  Created by Book on 2023/4/26.
//

import UIKit

class S_AppGuideView: UIView {


    fileprivate var scrollView: UIScrollView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollView = UIScrollView(frame: frame)
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollsToTop = false
        scrollView.bounces = false
        // 将 scrollView 的 contentSize 设为屏幕宽度的3倍(根据实际情况改变)
        scrollView.contentSize = CGSize(width: frame.size.width * 3, height: frame.size.height)
        self.addSubview(scrollView)
        scrollView.delegate = self
        
        for i in 0...2{
        
            let imageView = UIImageView(frame: CGRect(x: CGFloat(i)*kScreenWidth, y: 0, width: kScreenWidth, height: kScreenHeight))
            imageView.image = UIImage.init(named: "app_guide_"+i.description)
            scrollView.addSubview(imageView)
        
            let pageImageView = UIImageView(frame: CGRectZero)
            if(i==0){
                pageImageView.frame = CGRect(x: kScreenWidth/2-25, y: kScreenHeight-150, width: 18, height: 10)
                pageImageView.image = UIImage.init(named: "rectangle")
            }else{
                pageImageView.frame = CGRect(x: kScreenWidth/2-25+24+16*CGFloat(i-1), y: kScreenHeight-150, width: 10, height: 10)
                pageImageView.image = UIImage.init(named: "circle")
                
            }
            pageImageView.tag = 100+i
            self.addSubview(pageImageView)
            pageImageView.contentMode = .scaleAspectFill

            if(i==2){
                
                let experienceButton = UIButton.init(frame: CGRect(x: kScreenWidth*2+kScreenWidth/2-Ratio(57.5), y: kScreenHeight-170-Ratio(27), width: Ratio(115), height: Ratio(27)))
                experienceButton.titleLabel?.font = UIFont.regularFontOfSize(size: 15)
                experienceButton.setTitle("立即体验", for: .normal)
                experienceButton.setTitleColor(BlueTextColor, for: .normal)
                scrollView.addSubview(experienceButton)
                experienceButton.layer.cornerRadius = Ratio(13.5)
                experienceButton.clipsToBounds = true
                experienceButton.layer.borderWidth = 1
                experienceButton.layer.borderColor = UIColor.init(patternImage: UIImage.createImageWithSize(imageSize: experienceButton.size, colorsArray: [kColorWithHex(0x2F63F8),kColorWithHex(0xE30B9A)])).cgColor
                experienceButton.addTarget(self, action: #selector(endGuide), for: .touchUpInside)
            }
            
        }
        
    }
    
    @objc func endGuide(){
        self.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension S_AppGuideView:UIScrollViewDelegate{
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let  page:CGFloat = scrollView.contentOffset.x/kScreenWidth
        
        var tempImageView:UIImageView = UIImageView(frame: CGRect(x: kScreenWidth/2-31, y: kScreenHeight-150, width: 1, height: 10))
        for i in 0...2{
            let pageImageView = self.viewWithTag(100+i) as! UIImageView
            pageImageView.frame = CGRect(x: tempImageView.right+6, y: tempImageView.y, width: 10, height: 10)
            if(CGFloat(i)==page){
                pageImageView.width = 18
                pageImageView.image = UIImage.init(named: "rectangle")
            }else{
                pageImageView.image = UIImage.init(named: "circle")
            }
            tempImageView = pageImageView
        }
        print()
    }
}
