//
//  PrivacyAgreementView.swift
//  swiftBase
//
//  Created by Book on 2023/3/22.
//

import UIKit

class PrivacyAgreementView: UIView {

    var animateView:UIView!
    
    var contentLabel:YYLabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.settingUpSubViews()

    }
    
    
    func settingUpSubViews(){
        
        self.animateView = UIView.init(frame: CGRect(x: 0, y: 0, width: 275, height: 300))
        self.animateView.layer.cornerRadius = 16
        self.animateView.layer.masksToBounds = true
        self.animateView.backgroundColor = UIColor.white
        self.addSubview(self.animateView)
        
        

        
        let titleLabel = UILabel.init(frame: CGRect(x: 16, y: 24, width: self.animateView.width-32, height: 22))
        titleLabel.font = UIFont.semiboldFontOfSize(size: 16)
        titleLabel.text = "用户协议与隐私政策";
        titleLabel.textColor = MainTextColor
        titleLabel.textAlignment = .center;
        self.animateView.addSubview(titleLabel)
        

        contentLabel = YYLabel.init(frame: CGRect(x: titleLabel.left, y: titleLabel.bottom+12, width: titleLabel.width, height: 140))
        contentLabel.font = UIFont.regularFontOfSize(size: 14)
        contentLabel.textColor = kColorWithHex(0x333333);
        contentLabel.textAlignment = .left;
        contentLabel.numberOfLines = 0;
        self.animateView.addSubview(contentLabel)
        
        let contentString:String = "感谢您选择START APP 为了更好的保障您的个人权益，在您使用我们的产品前，请务必审慎阅读《用户协议》与《隐私条款》，以帮助您了解我们对您个人信息的处理情况以及您享有的相关权利。"
        let protocolString = "《用户协议》"
        let privacyString = "《隐私条款》"
        
        let attrStr = NSMutableAttributedString.init(string: contentString)
        
        attrStr.addAttributes([NSAttributedString.Key.foregroundColor:kColorWithHex(0x333333),NSAttributedString.Key.font:UIFont.regularFontOfSize(size: 14)], range: NSRange(location: 0, length: contentString.count))
        
        let rangePrivacy = NSRange(contentString.range(of: privacyString)!, in: contentString) // NSRange?

        let rangeProtocol = NSRange(contentString.range(of: protocolString)!, in: contentString) // NSRange?

        attrStr.addAttribute(NSAttributedString.Key.link, value: "UserAgreement://", range: rangeProtocol)
        attrStr.addAttribute(NSAttributedString.Key.link, value: "UserPrivacy://", range: rangePrivacy)

        attrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: BlueTextColor, range: rangeProtocol)
        attrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: BlueTextColor, range: rangePrivacy)
        
        attrStr.yy_setTextHighlight(rangeProtocol, color: BlueTextColor, backgroundColor: UIColor.clear) { UIView, NSAttributedString, NSRange, CGRect in
            
//            let simple = S_SimpleWebViewController()
//            simple.urlString = S_ProjectConfig.sharedInstance.H5DomainURL.appending(UserProtocol)
//            simple.isPresent = true
//            let baseNavi = BaseNavigationController.init(rootViewController: simple)
//            baseNavi.modalPresentationStyle = .fullScreen
//            UIViewController.current().present(baseNavi, animated: true)

        }
        attrStr.yy_setTextHighlight(rangePrivacy, color: BlueTextColor, backgroundColor: UIColor.clear) { UIView, NSAttributedString, NSRange, CGRect in
            
//            let simple = S_SimpleWebViewController()
//            simple.urlString = S_ProjectConfig.sharedInstance.H5DomainURL.appending(UserPrivacy)
//            simple.isPresent = true
//            let baseNavi = BaseNavigationController.init(rootViewController: simple)
//            baseNavi.modalPresentationStyle = .fullScreen
//            UIViewController.current().present(baseNavi, animated: true)

        }

        contentLabel.attributedText = attrStr


        let cancelButton = UIButton.init(frame: CGRect(x: 56, y: self.animateView.height-35-10, width: self.animateView.width-56*2, height: 35))
        cancelButton.setTitle("不同意", for: .normal)
        cancelButton.setTitleColor(SubTextColor, for: .normal)
        cancelButton.titleLabel?.font = UIFont.regularFontOfSize(size: 12)
        self.animateView .addSubview(cancelButton)
        cancelButton.addTarget(self, action: #selector(nb_cancelViewAction), for: .touchUpInside)

        
        let sureButton = UIButton.init(frame: CGRect(x: cancelButton.left, y: cancelButton.top-10-40, width: cancelButton.width, height: 40))
        sureButton.setTitle("同意并继续", for: .normal)
        sureButton.setTitleColor(UIColor.white, for: .normal)
        sureButton.titleLabel?.font = UIFont.regularFontOfSize(size: 16)
        self.animateView .addSubview(sureButton)
        sureButton.addTarget(self, action: #selector(dismissViewAction), for: .touchUpInside)
        sureButton.backgroundColor = UIColor.init(patternImage: UIImage.createImageWithSize(imageSize: sureButton.size, colorsArray: [kColorWithHex(0x2F63F8),kColorWithHex(0xE30B9A)]))
        sureButton.layer.cornerRadius = 20
        sureButton.clipsToBounds = true
        
//        self.animateView.height = sureButton.bottom+16;
            
        self.animateView.center = self.center;


        

        
        
        
        
    }
    
    @objc
    func nb_cancelViewAction(){
        
        let  window:UIWindow = keyWindow();
        
        UIView.animate(withDuration: 0.5) {
            window.alpha = 0;
            window.frame = CGRect(x: window.bounds.size.width/2, y: window.bounds.size.height/2, width: window.bounds.size.width, height: 0.5)
        }completion: { Bool in
            exit(0);

        }
    }
    
    @objc
    func dismissViewAction(){
        
        UIView.animate(withDuration: 0.45) {
            self.backgroundColor = UIColor.init(white: 0, alpha: 0)
            self.animateView.transform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
            self.animateView.alpha = 0.1;
        } completion: { Bool in
            if Bool == true{
                UserDefaults.standard.set(true, forKey: FirstAgreementKey)
                self.removeFromSuperview()
            }
        }
    }


    @objc
    func clickProtocol(){
        
    }
    
    @objc
    func privacy(){
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
